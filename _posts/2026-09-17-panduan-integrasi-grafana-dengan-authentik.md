---
title: Panduan Integrasi Grafana dengan Authentik
description: Panduan integrasi Grafana dengan Authentik untuk SSO menggunakan OAuth2/OpenID Connect. Mencakup konfigurasi OAuth provider, application entitlements, environment variables, front-channel logout, dan verifikasi login SSO pada self-hosted Grafana.
categories: [Digital Independence, SSO]
tags: [self-hosted, sso, authentik, grafana]
author: rical
last_modified_at: 2026-09-17
---

## Pendahuluan

Integrasi Grafana dengan Authentik memungkinkan autentikasi terpusat menggunakan protokol OAuth2/OpenID Connect (OIDC). Pendekatan ini menghilangkan kebutuhan kredensial terpisah di Grafana, sekaligus memungkinkan kontrol akses berbasis peran (RBAC) melalui entitlement Authentik. Artikel ini membahas langkah konfigurasi secara teknis, termasuk alasan di balik setiap parameter.

## 1. Konfigurasi di Authentik

### 1.1 Membuat Application

Navigasi ke Applications > Applications > New Application. Configure the Application:

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-05-37.webp>)

| Parameter          | Nilai     | Keterangan                                                                                                                          |
| ------------------ | --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Application Name   | `Grafana` | Nama aplikasi yang ditampilkan di dashboard Authentik.                                                                              |
| Slug               | `grafana` | Slug digunakan sebagai identifier unik di URL OAuth2 (`/application/o/grafana/`).                                                   |
| Policy Engine Mode | `ANY`     | Mode `ANY` berarti kebijakan akses akan dievaluasi secara OR; pengguna cukup memenuhi salah satu kebijakan untuk mendapatkan akses. |

### 1.2 Memilih Provider

Pilih OAuth/OpenID Provider.

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-06-32.webp>)

### 1.3 Konfigurasi OAuth2 Provider

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-10-13.webp>)

| Parameter          | Nilai                                                                     | Keterangan                                                                                                                                                   |
| ------------------ | ------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Provider Name      | `Provider for Grafana`                                                    | Nama identitas provider di Authentik.                                                                                                                        |
| Authorization Flow | `default-provider-authorization-implicit-consent (Authorize Application)` | Menentukan bagaimana persetujuan pengguna diproses. Mode implicit consent mempercepat login karena tidak memerlukan halaman persetujuan eksplisit.           |
| Client Type        | `Confidential`                                                            | Digunakan karena Grafana berjalan di server yang aman dan dapat menyimpan `Client Secret` dengan aman. Tipe `Public` tidak cocok untuk aplikasi server-side. |
| Client ID          | Auto-generated                                                            | Di-generate otomatis oleh Authentik. Catat untuk konfigurasi Grafana.                                                                                        |
| Client Secret      | Auto-generated                                                            | Di-generate otomatis oleh Authentik. Catat untuk konfigurasi Grafana.                                                                                        |

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-10-56.webp>)

| Parameter            | Nilai                                                                           | Keterangan                                                                                                                                |
| -------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Redirect URIs/Origin | `Strict` \| `Authorization` \| `https://grafana.domain.com/login/generic_oauth` | Endpoint callback Grafana. Authentik hanya mengizinkan redirect ke URI terdaftar (strict matching) untuk mencegah open redirect attack.   |
| Logout URI           | `https://grafana.domain.com/logout`                                             | Endpoint logout Grafana yang dipanggil setelah session Authentik berakhir.                                                                |
| Logout Method        | `Front-channel`                                                                 | Front-channel logout mengirim permintaan logout melalui browser pengguna, memastikan session di Grafana dan Authentik berakhir bersamaan. |

Pada Selected scopes, tambahkan `authentik default OAuth Mapping: Application Entitlements`. Scope ini memungkinkan Grafana menerima informasi entitlement dari Authentik, yang nantinya dipetakan ke role Grafana.

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-12-25.webp>)

Klik Create Application.

### 1.4 Membuat Entitlement

Navigasi ke Applications > Pilih aplikasi Grafana yang telah dibuat > Application entitlements > Create entitlement.

Buat tiga entitlement berikut:

- `Grafana Admins`
- `Grafana Editors`
- `Grafana Viewers`

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-16 23-16-21.webp>)

Bind entitlement ke group atau user yang sesuai.

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-17 00-10-15.webp>)

Entitlement berfungsi sebagai abstraksi role. Pengguna yang tergabung dalam group tertentu akan otomatis mendapatkan entitlement, yang kemudian dikirim ke Grafana melalui token OIDC.

## 2. Konfigurasi Grafana

### 2.1 Akses Environment Monitoring

```bash
dipen env monitoring
```

Perintah ini membuka file `.env` untuk stack monitoring.

### 2.2 Sesuaikan Variabel Environment

Edit file `.env` dan sesuaikan parameter berikut:

```yaml
GF_AUTH_GENERIC_OAUTH_ENABLED=false
GF_AUTH_GENERIC_OAUTH_NAME=authentik
GF_AUTH_GENERIC_OAUTH_CLIENT_ID=
GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=
GF_AUTH_GENERIC_OAUTH_SCOPES="openid profile email entitlements"
GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://authentik.domain.com/application/o/authorize/
GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://authentik.domain.com/application/o/token/
GF_AUTH_GENERIC_OAUTH_API_URL=https://authentik.domain.com/application/o/userinfo/
GF_AUTH_SIGNOUT_REDIRECT_URL=https://authentik.domain.com/application/o/<application_slug>/end-session/
GF_AUTH_OAUTH_AUTO_LOGIN=false
```

### 2.3 Terapkan Perubahan

```bash
dipen fresh monitoring
```

Perintah ini me-restart stack monitoring dengan konfigurasi baru.

### 2.4 Verifikasi

Buka halaman login Grafana. Tombol Sign in with SSO akan muncul.

![alt text](<../assets/img/posts/2026-09-16-panduan-integrasi-grafana-dengan-authentik/Screenshot From 2026-09-17 00-16-29.webp>)

## Kesimpulan

Integrasi ini memanfaatkan OAuth2/OIDC untuk autentikasi terpusat dan entitlement untuk manajemen role. Dengan konfigurasi yang tepat, pengguna dapat login ke Grafana menggunakan kredensial Authentik, sementara hak akses dikelola secara terpusat melalui group di Authentik. Pendekatan ini meningkatkan keamanan dan menyederhanakan administrasi pengguna.