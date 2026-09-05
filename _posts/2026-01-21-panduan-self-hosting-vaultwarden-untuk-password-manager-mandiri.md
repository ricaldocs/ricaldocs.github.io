---
title: Panduan Self-Hosting Vaultwarden untuk Password Manager Mandiri
description: Pelajari cara menginstal Vaultwarden secara mandiri dengan Podman. Tutorial ini memandu Anda langkah demi langkah menyiapkan password manager open-source yang aman dengan kontrol data penuh.
categories: [Digital Independence, Password Manager]
tags: [self-hosted, linux, vaultwarden, podman]
author: rical
last_modified_at: 2026-08-05
---

## Apa itu Vaultwarden dan Mengapa Perlu?

### Konsep Dasar

Vaultwarden adalah implementasi open-source dari server Bitwarden yang ditulis dalam Rust. Ini adalah alternatif yang lebih ringan dan efisien dari server Bitwarden resmi, dengan kompatibilitas penuh terhadap semua client Bitwarden (browser extension, mobile app, desktop app).

```
┌──────────────────────────────────────────────────────────┐
│                    VAULTWARDEN SERVER                    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────────┐  │
│  │  🔐 Password Manager                               │  │
│  │  ├── Login Credentials (1,234 items)               │  │
│  │  ├── Secure Notes (56 items)                       │  │
│  │  ├── Credit Cards (12 items)                       │  │
│  │  ├── Identities (5 items)                          │  │
│  │  └── Attachments (89 items)                        │  │
│  ├────────────────────────────────────────────────────┤  │
│  │  🔑 Security Features                              │  │
│  │  ├── End-to-End Encryption                         │  │
│  │  ├── Two-Factor Authentication (2FA)               │  │
│  │  ├── Emergency Access                              │  │
│  │  └── Password Generator                            │  │
│  └────────────────────────────────────────────────────┘  │
│                                                          │
│  Users: 5 │ Organizations: 2 │ Collections: 8            │
└──────────────────────────────────────────────────────────┘
```

### Keunggulan Vaultwarden

| Keunggulan           | Penjelasan                                             |
| -------------------- | ------------------------------------------------------ |
| Kompatibel Bitwarden | Mendukung semua client Bitwarden resmi                 |
| Ringan & Efisien     | Ditulis dalam Rust, memory footprint kecil (~10-20 MB) |
| Fitur Lengkap        | Organisasi, koleksi, attachment, 2FA, emergency access |
| Gratis Selamanya     | Tidak ada batasan pengguna atau fitur                  |
| Self-Hosted          | Data tetap di infrastruktur Anda                       |
| Audit Log            | Log aktivitas pengguna untuk keamanan                  |

### Arsitektur dengan Podman

```
┌─────────────────────────────────────────────────────────┐
│                     Host System                         │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐   │
│  │              Vaultwarden Container               │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  Vaultwarden Server (Rust)                  │ │   │
│  │  │  Port: 8000 (HTTP API)                      │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  │                        │                         │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  Redis (Session & Cache)                    │ │   │
│  │  │  Port: 6379 (internal)                      │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  │                                                  │   │
│  │  Volumes:                                        │   │
│  │  - vaultwarden_data:/data/                       │   │
│  │  - redis_data:/data (Redis)                      │   │
│  └──────────────────────────────────────────────────┘   │
│                            │                            │
│                    ┌───────▼───────┐                    │
│                    │  Port 8000    │                    │
│                    │  (API Web)    │                    │
│                    └───────────────┘                    │
└─────────────────────────────────────────────────────────┘
```

## Prasyarat

### Spesifikasi Sistem

| Komponen | Minimum                    | Rekomendasi            |
| -------- | -------------------------- | ---------------------- |
| Sistem   | Debian 11+ / Ubuntu 22.04+ | Debian 13+             |
| CPU      | 1 core                     | 2 core                 |
| RAM      | 256 MB                     | 512+ MB                |
| Storage  | 500 MB                     | 2+ GB                  |
| Podman   | 5.4+                       | Latest                 |
| Port     | 8000 (HTTP API)            | -                      |
| Domain   | -                          | Untuk HTTPS (opsional) |

## 1. Clone Repository

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

Repository ini berisi semua konfigurasi `podman-compose` yang sudah teruji untuk setiap layanan, termasuk Vaultwarden dengan Redis untuk session management.

## 2. Instal Podman

### Instalasi Otomatis

```bash
./install-podman-on-debian.sh
```

Apa yang dilakukan script ini?
- Menginstal Podman dan podman-compose
- Mengkonfigurasi rootless podman
- Menyiapkan alias `dipen`
- Menambahkan registry `docker.io`

### Verifikasi Instalasi

```bash
podman --version
podman-compose --version
dipen version
```

## 3. Konfigurasi Vaultwarden

### Buat File `.env`

```bash
dipen env vaultwarden
```

File `.env` akan terbuka di editor. Sesuaikan.

## 4. Jalankan Vaultwarden

### Start Container

```bash
dipen up vaultwarden
```

Apa yang terjadi di balik layar:

1. Podman menarik image `vaultwarden/server:alpine`
2. Podman menarik image `redis:alpine`
3. Membuat volume: `vaultwarden_data` dan `redis_data`
4. Membuat network: `vaultwarden_network`
5. Menjalankan Redis terlebih dahulu (dependency)
6. Menjalankan Vaultwarden dengan:
   - Port mapping: `127.0.0.1:8000:80`
   - Redis untuk session storage
   - Read-only filesystem untuk keamanan

### Monitor Startup

```bash
dipen logs vaultwarden
dipen ps vaultwarden
```

Output yang diharapkan:

```
CONTAINER ID  IMAGE                                COMMAND               CREATED      STATUS                PORTS                   NAMES
e10fe884bed5  docker.io/library/redis:alpine       redis-server --sa...  8 hours ago  Up 8 hours (healthy)  6379/tcp                vaultwarden_redis
8ec9e8716630  docker.io/vaultwarden/server:alpine  /start.sh             8 hours ago  Up 8 hours (healthy)  127.0.0.1:8000->80/tcp  vaultwarden
```

## 5. Monitoring dan Maintenance

### Update Vaultwarden

```bash
dipen update vaultwarden
```

## Kesimpulan

### Ringkasan Implementasi

### Manfaat yang Didapatkan

| Manfaat          | Penjelasan                   |
| ---------------- | ---------------------------- |
| Kendali Penuh    | Data password di server Anda |
| Gratis Selamanya | Tidak ada biaya langganan    |
| Keamanan Tinggi  | End-to-end encryption, 2FA   |
| Multi-Device     | Akses dari semua perangkat   |
| Berbagi Aman     | Organisasi dan koleksi       |

## Referensi dan Sumber Daya Tambahan

- [GitHub Repository: Digital Independence](https://github.com/ricalnet/digital-independence)
- [Vaultwarden Official Documentation](https://github.com/dani-garcia/vaultwarden/wiki)
- [Bitwarden Client Apps](https://bitwarden.com/download/)
- [Podman Documentation](https://podman.io/docs/)