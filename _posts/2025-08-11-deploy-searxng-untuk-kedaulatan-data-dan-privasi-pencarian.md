---
title: Deploy SearXNG untuk Kedaulatan Data dan Privasi Pencarian
description: Tingkatkan privasi online Anda dengan memandu sendiri mesin pencari SearXNG menggunakan Podman. Panduan langkah demi langkah ini mencakup instalasi, dua metode deployment (dengan Caddy untuk pemula), manajemen kontainer, dan pembaruan sistem. Bebas dari pelacakan dan sensor.
categories: [Digital Independence, Search Engine]
tags: [self-hosted, podman, searxng]
author: rical
last_modified_at: 2026-09-05
---

## Apa itu SearXNG dan Mengapa Perlu?

### Konsep Dasar

SearXNG adalah metasearch engine open-source yang mengagregasi hasil pencarian dari berbagai mesin pencari (Google, Bing, DuckDuckGo, dll.) tanpa melacak atau memprofilkan pengguna. Ini adalah fork dari SearX yang lebih modern dan aktif dikembangkan.

```
┌─────────────────────────────────────────────────────────────┐
│                    SEARXNG META SEARCH                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  🔍 Search Query: "self-hosted privacy"              │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                │
│                            ▼                                │
│  ┌──────────┐  ┌──────────┐  ┌─────────────┐  ┌──────────┐  │
│  │  Google  │  │  Bing    │  │  DuckDuckGo │  │  Qwant   │  │
│  └────┬─────┘  └────┬─────┘  └──────┬──────┘  └────┬─────┘  │
│       │             │             │                │        │
│       └─────────────┼─────────────┼────────────────┘        │
│                     │             │                         │
│                     ▼             ▼                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Aggregated Results (No Tracking, No Profiling)      │   │
│  │  ├── Result 1: How to self-host...                   │   │
│  │  ├── Result 2: Best privacy tools...                 │   │
│  │  ├── Result 3: Self-hosted vs cloud...               │   │
│  │  └── Result 4: ...                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Keunggulan SearXNG

| Keunggulan            | Penjelasan                                                         |
| --------------------- | ------------------------------------------------------------------ |
| Privasi Terjaga       | Tidak ada pelacakan, profiling, atau penyimpanan riwayat pencarian |
| Agregasi Multi-Engine | Menggabungkan hasil dari 70+ mesin pencari                         |
| Kustomisasi           | Pilih engine mana yang digunakan, urutan, dan filter               |
| Open Source           | Kode sumber terbuka dan transparan                                 |
| Self-Hosted           | Infrastruktur sendiri, kendali penuh                               |
| Tanpa Iklan           | Tidak ada iklan yang disisipkan                                    |

### Arsitektur dengan Podman

```
┌─────────────────────────────────────────────────────────┐
│                     Host System                         │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────┐  │
│  │              SearXNG Container                    │  │
│  │  ┌────────────────────────────────────────────┐   │  │
│  │  │  SearXNG Server (Python)                   │   │  │
│  │  │  Port: 8888 (Web UI)                       │   │  │
│  │  └────────────────────────────────────────────┘   │  │
│  │                        │                          │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │  Valkey/Redis (Cache)                       │  │  │
│  │  │  Port: 6379 (internal)                      │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  Volumes:                                         │  │
│  │  - ./searxng:/etc/searxng (konfigurasi)           │  │
│  │  - searxng-data:/var/cache/searxng (cache)        │  │
│  └───────────────────────────────────────────────────┘  │
│                           │                             │
│                   ┌───────▼───────┐                     │
│                   │  Port 8888    │                     │
│                   │  (Web UI)     │                     │
│                   └───────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

## Prasyarat

### Spesifikasi Sistem

| Komponen | Minimum                    | Rekomendasi            |
| -------- | -------------------------- | ---------------------- |
| Sistem   | Debian 11+ / Ubuntu 22.04+ | Debian 12+             |
| CPU      | 1 core                     | 2 core                 |
| RAM      | 256 MB                     | 512+ MB                |
| Storage  | 500 MB                     | 2+ GB                  |
| Podman   | 5.4+                       | Latest                 |
| Port     | 8888 (Web UI)              | -                      |
| Domain   | -                          | Untuk HTTPS (opsional) |

## 1. Clone Repository

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

Repository ini berisi semua konfigurasi `podman-compose` yang sudah teruji untuk setiap layanan, termasuk SearXNG dengan Valkey/Redis untuk caching.

## 2. Instal Podman

### Instalasi Otomatis

```bash
./install-podman-on-debian.sh
```

Apa yang dilakukan script ini?
- Menginstal Podman dan podman-compose
- Mengkonfigurasi rootless podman
- Menyiapkan alias `dipen`

### Verifikasi Instalasi

```bash
podman --version
podman-compose --version
dipen version
```

## 3. Konfigurasi SearXNG

### Buat File `.env`

```bash
dipen env searxng
```

File `.env` akan terbuka di editor. Sesuaikan.

## 4. Jalankan SearXNG

### Start Container

```bash
dipen up searxng
```

Apa yang terjadi di balik layar:

1. Podman menarik image `searxng/searxng:latest`
2. Podman menarik image `valkey/valkey:alpine`
3. Membuat volume: `searxng-data` dan `valkey-data`
4. Membuat network: `searxng`
5. Menjalankan Valkey/Redis terlebih dahulu (dependency)
6. Menjalankan SearXNG dengan:
   - Port mapping: `127.0.0.1:8888:8080`
   - Volume untuk konfigurasi dan cache

### Monitor Startup

```bash
dipen logs searxng
dipen ps searxng
```

Output yang diharapkan:

```
CONTAINER ID  IMAGE                             COMMAND               CREATED         STATUS                   PORTS                     NAMES
fd9a5e7aa247  docker.io/valkey/valkey:alpine    valkey-server --s...  36 seconds ago  Up 36 seconds (healthy)  6379/tcp                  searxng-redis
094ff67a4e1a  docker.io/searxng/searxng:latest                        35 seconds ago  Up 35 seconds (healthy)  127.0.0.1:8888->8080/tcp  searxng
```

## 5. Akses SearXNG

### Buka Search Engine

Buka browser dan akses:

```
http://localhost:8888
```

## 6. Keamanan dan Privasi

### Mengapa SearXNG Aman?

| Fitur Keamanan | Penjelasan                                          |
| -------------- | --------------------------------------------------- |
| No Logging     | Tidak menyimpan riwayat pencarian atau IP user      |
| No Cookies     | Tidak menggunakan tracking cookies                  |
| HTTPS Support  | Mendukung HTTPS untuk komunikasi terenkripsi        |
| Open Source    | Kode dapat diaudit publik                           |
| Disconnect     | Query dilakukan dari server Anda, bukan dari client |

## 7. Monitoring dan Maintenance

### Update SearXNG

```bash
dipen update searxng
```

## Kesimpulan

### Manfaat yang Didapatkan

| Manfaat         | Penjelasan                         |
| --------------- | ---------------------------------- |
| Privasi Terjaga | Pencarian tanpa pelacakan          |
| Multi-Engine    | Akses ke 70+ search engine         |
| Tanpa Iklan     | Search results bersih              |
| Kendali Penuh   | Pilih engine, filter, dan tampilan |
| Open Source     | Transparan dan bebas               |

## Referensi dan Sumber Daya Tambahan

- [GitHub Repository: Digital Independence](https://github.com/ricalnet/digital-independence)
- [SearXNG Official Documentation](https://docs.searxng.org/)
- [SearXNG GitHub](https://github.com/searxng/searxng)
- [Valkey/Redis Documentation](https://valkey.io/)