---
title: Panduan Integrasi Technitium DNS dengan Authentik
description: Panduan lengkap integrasi Technitium DNS dengan Authentik via OAuth2/OpenID Connect untuk SSO terpusat, scope mapping, entitlement, dan pemetaan grup.
categories: [Digital Independence, SSO]
tags: [self-hosted, sso, dns, privacy, authentik]
author: rical
last_modified_at: 2026-10-28
---

## 1. Buat Scope Mapping di Authentik

Scope mapping mendefinisikan klaim (claims) tambahan yang dikirim IdP ke aplikasi klien. Technitium membutuhkan informasi peran (role) pengguna untuk memetakan ke grup lokal, sehingga kita perlu menyuntikkan klaim `roles` ke dalam scope `profile`.

Langkah:

1. Buka Customization > Property Mappings > New Property Mapping.
2. Pilih Scope Mapping.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-34-51.webp>)

3. Isi detail berikut:
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-37-30.webp>)
   - Mapping Name: `Technitium DNS roles`
   - Scope name: `profile`
   - Expression:

   ```python
   return {
      "roles": [
         entitlement.name
         for entitlement in request.user.app_entitlements(provider.application)
      ],
   }
   ```

Mengapa langkah ini penting? Expression di atas mengiterasi seluruh entitlement yang dimiliki pengguna pada aplikasi provider terkait, lalu mengembalikan daftar nama entitlement sebagai klaim `roles`. Technitium akan membaca klaim ini untuk menentukan grup lokal pengguna. Tanpa mapping ini, Technitium tidak menerima informasi peran dan pemetaan grup tidak akan berfungsi.

## 2. Buat Application di Authentik

Application merepresentasikan Technitium sebagai klien OAuth2 di Authentik.

Langkah:

1. Buka Applications > Applications > New Application.
2. Isi:
   - Application Name: `Technitium DNS`
   - Slug: `technitium`
   - Policy engine mode: `ANY`
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-39-12.webp>)

3. Pilih Provider: OAuth/OpenID Provider.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-39-40.webp>)

Konfigurasi Provider:

![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-40-41.webp>)

![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-42-41.webp>)

| Field | Nilai | Keterangan |
|---|---|---|
| Provider name | `Provider for Technitium` | Nama identifier provider di Authentik. |
| Authorization Flow | `default-provider-authorization-implicit-consent (Authorize Application)` | Flow consent implisit; pengguna tidak diminta menyetujui ulang setiap login. |
| Client Type | `Confidential` | Technitium berjalan di server dan dapat menyimpan client secret secara aman, sehingga flow confidential (bukan public/PKCE) yang tepat. |
| Client ID dan Secret | Ter-generate otomatis | Catat nilai keduanya untuk digunakan di sisi Technitium. |
| Redirect URIs/Origins (RegEx) | `Strict Authorization https://technitium.domain.com/sso/callback` | Pastikan URL persis sesuai endpoint callback Technitium; ketidakcocokan menyebabkan error `redirect_uri_mismatch`. |

Advanced protocol settings:

- Pada bagian Scope, hapus `email` dan tambahkan `Technitium DNS roles` yang telah dibuat pada langkah 1.
  ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-44-19.webp>)

- Klik Create Application.

Mengapa langkah ini penting? Scope menentukan klaim apa saja yang dikirim dalam ID token. Menghapus `email` mengurangi data yang terekspos (prinsip least privilege), sementara menambahkan scope kustom memastikan klaim `roles` tersedia bagi Technitium.

## 3. Buat Application Entitlements di Authentik

Entitlement adalah mekanisme Authentik untuk menyatakan bahwa seorang pengguna berhak atas peran tertentu dalam suatu aplikasi. Entitlement inilah yang dibaca oleh expression pada langkah 1.

Langkah:

1. Buka aplikasi Technitium yang baru dibuat.
2. Masuk ke tab Application Entitlements > Create entitlement.
3. Isi nama: `Technitium Admins`.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-48-45.webp>)

4. Expand dan Bind existing group/user yang berhak menjadi admin Technitium.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-50-24.webp>)

Mengapa langkah ini penting? Hanya pengguna yang ter-bind pada entitlement ini yang akan memiliki `Technitium Admins` di dalam klaim `roles`. Ini menjadi sumber kebenaran (source of truth) untuk otorisasi, terpisah dari autentikasi.

## 4. Konfigurasi Technitium DNS

Sisi klien (Technitium) perlu dikonfigurasi agar mempercayai Authentik sebagai IdP.

Langkah:

1. Buka Administration > Single Sign-On (SSO).
2. Centang Enable SSO.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-52-51.webp>)

   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 22-54-34.webp>)

3. Isi:
   - Issuer: `https://authentik.domain.com/application/o/<application_slug>/` — gunakan slug aplikasi (`technitium`) pada URL issuer. URL ini harus dapat di-resolve oleh server Technitium untuk mengambil metadata OIDC (`.well-known/openid-configuration`).
   - Scopes: tambahkan `openid` dan `profile`.

4. Centang Allow new user sign up — memungkinkan pembuatan user lokal otomatis saat login pertama via SSO.
5. Centang Allow sign up only for mapped users — membatasi pembuatan akun hanya untuk pengguna yang klaim `roles`-nya cocok dengan pemetaan grup. Ini mencegah siapa pun yang berhasil autentikasi di Authentik membuat akun Technitium secara sembarangan.
6. Group map: atur remote group ke `Technitium Admins` dan local group sesuai kebutuhan (misalnya grup admin lokal Technitium).
7. Save Config.

Mengapa langkah ini penting? Parameter `Issuer` menjadi acuan discovery endpoint OIDC. Kombinasi dua opsi sign-up di atas menerapkan kontrol otorisasi berlapis: autentikasi berhasil belum tentu berhak membuat akun — kecuali perannya terpetakan.

## 5. Verifikasi

1. Logout dari Technitium, lalu buka halaman login.
2. Pilih Login with OpenID Connect.
   ![alt text](<../assets/img/posts/2026-10-28-panduan-integrasi-technitium-dns-dengan-authentik/Screenshot From 2026-10-28 23-27-58.webp>)

3. Anda akan diarahkan ke Authentik untuk autentikasi, kemudian kembali ke Technitium.
4. Pastikan pengguna dengan entitlement `Technitium Admins` mendapatkan grup lokal yang benar.

Dengan konfigurasi ini, Technitium DNS menggunakan Authentik sebagai IdP tunggal, sementara otorisasi peran dikelola secara terpusat melalui entitlement — memisahkan autentikasi dari otorisasi dan menyederhanakan manajemen akses.