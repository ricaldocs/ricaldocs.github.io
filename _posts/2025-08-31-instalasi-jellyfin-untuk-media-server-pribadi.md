---
title: Instalasi Jellyfin untuk Media Server Pribadi
description: Panduan lengkap instalasi Jellyfin media server menggunakan Podman. Tutorial self-hosted untuk streaming film, musik, dan foto tanpa biaya langganan.
categories: [Digital Independence, Multimedia]
tags: [self-hosted, podman, jellyfin]
author: rical
last_modified_at: 2026-09-05
---

## Apa itu Jellyfin dan Mengapa Perlu?

### Konsep Dasar

Jellyfin adalah media server open-source yang memungkinkan Anda mengorganisir, mengelola, dan melakukan streaming koleksi media (film, musik, foto) ke berbagai perangkat. Sebagai alternatif gratis untuk Plex dan Emby, Jellyfin memberikan kendali penuh atas data dan infrastruktur Anda.

```
┌─────────────────────────────────────────────────────────────┐
│                    JELLYFIN MEDIA SERVER                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   Movies     │    │   TV Shows   │    │   Music      │   │
│  │   🎬 245     │    │   📺 67      │    │   🎵 1,234   │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   Photos     │    │  Live TV     │    │  Continue    │   │
│  │   📸 890     │    │   📡 12      │    │   ▶️ 5       │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│                                                             │
│  [Search]  [Library]  [Admin]  [Profile]                    │
└─────────────────────────────────────────────────────────────┘
```

### Keunggulan Jellyfin vs Alternatif

| Fitur                | Jellyfin | Plex            | Emby            |
| -------------------- | -------- | --------------- | --------------- |
| Open Source          | ✅ Ya     | ❌ Tidak         | ❌ Tidak         |
| Gratis               | ✅ Ya     | ❌ Berbayar      | ❌ Berbayar      |
| Self-Hosted          | ✅ Ya     | ⚠️ Terbatas      | ✅ Ya            |
| Hardware Transcoding | ✅ Ya     | ✅ Ya (Berbayar) | ✅ Ya (Berbayar) |
| Kendali Data         | ✅ Penuh  | ❌ Pihak Ketiga  | ⚠️ Terbatas      |
| Offline Access       | ✅ Ya     | ✅ Ya            | ✅ Ya            |
| Plugins              | ✅ Ya     | ✅ Ya            | ✅ Ya            |

### Arsitektur dengan Podman

```
┌─────────────────────────────────────────────────────────────┐
│                     Host System                             │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Jellyfin Container                      │   │
│  │  ┌──────────────────────────────────────────────┐    │   │
│  │  │  Jellyfin Server (dotnet)                    │    │   │
│  │  │  Port: 8096 (HTTP) / 8920 (HTTPS)            │    │   │
│  │  └──────────────────────────────────────────────┘    │   │
│  │                                                      │   │
│  │  Volumes:                                            │   │
│  │  - ./config:/config (konfigurasi)                    │   │
│  │  - ./cache:/cache (thumbnail, metadata)              │   │
│  │  - ./media:/media (koleksi media)                    │   │
│  │  - /dev/dri:/dev/dri (hardware acceleration)         │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                │
│                    ┌───────▼───────┐                        │
│                    │  Port 8096    │                        │
│                    │  (Web UI)     │                        │
│                    └───────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

## Prasyarat

### Spesifikasi Sistem

| Komponen | Minimum                    | Rekomendasi    |
| -------- | -------------------------- | -------------- |
| Sistem   | Debian 11+ / Ubuntu 22.04+ | Debian 13+     |
| CPU      | 2 core                     | 4+ core        |
| RAM      | 1 GB                       | 4+ GB          |
| Storage  | 10 GB + Media              | 50+ GB + Media |
| Podman   | 5.4+                       | Latest         |
| Port     | 8096 (HTTP), 8920 (HTTPS)  | -              |

## 1. Clone Repository

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

Repository ini berisi semua konfigurasi `podman-compose` yang sudah teruji untuk setiap layanan, termasuk Jellyfin dengan optimasi hardware transcoding.

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

## 3. Konfigurasi Jellyfin

### Buat Direktori Data

```bash
cd jellyfin
mkdir -p cache config media
ls -la
# Output: cache/  config/  media/  compose.yaml  .env.example
```

Fungsi direktori:

| Direktori | Fungsi                                   | Ukuran Est.        |
| --------- | ---------------------------------------- | ------------------ |
| `config/` | Konfigurasi Jellyfin, database, metadata | 100 MB - 1 GB      |
| `cache/`  | Thumbnail, image cache, transcode cache  | 500 MB - 10 GB     |
| `media/`  | Koleksi media (film, TV, musik, foto)    | Tergantung koleksi |

### Buat File `.env`

```bash
dipen env jellyfin
```

File `.env` akan terbuka di editor. Sesuaikan.

## 4. Jalankan Jellyfin

### Start Container

```bash
dipen up jellyfin
```

Apa yang terjadi di balik layar:

1. Podman menarik image `jellyfin/jellyfin:latest`
2. Membuat volume bind mount untuk config, cache, media
3. Me-mount device `/dev/dri` untuk hardware transcoding
4. Menjalankan container dengan port mapping `8096:8096` dan `8920:8920`
5. Container berjalan sebagai user `1000:1000`

### Monitor Startup

```bash
dipen logs jellyfin
dipen ps jellyfin
```

Output yang diharapkan:

```
CONTAINER ID  IMAGE                                 COMMAND     CREATED         STATUS                   PORTS                                           NAMES
d4a6e8e6481f  docker.io/jellyfin/jellyfin:10.11.11              36 seconds ago  Up 36 seconds (healthy)  0.0.0.0:8096->8096/tcp, 0.0.0.0:8920->8920/tcp  jellyfin
```

## 5. Akses dan Setup Awal Jellyfin

### Buka Jellyfin

Buka browser dan akses:

```
http://<IP-Server>:8096
```

Contoh: `http://192.168.0.50:8096`

## 6. Monitoring dan Maintenance

### Update Jellyfin

```bash
dipen update jellyfin
```

## Kesimpulan

### Manfaat yang Didapatkan

| Manfaat          | Penjelasan                              |
| ---------------- | --------------------------------------- |
| Kendali Penuh    | Semua data media di server Anda         |
| Gratis Selamanya | Tidak ada biaya langganan               |
| Multi-Device     | Akses dari smartphone, TV, laptop, dll. |
| Transcoding      | Play file di perangkat apa pun          |
| Metadata Rich    | Poster, deskripsi, rating otomatis      |

## Referensi dan Sumber Daya Tambahan

- [GitHub Repository: Digital Independence](https://github.com/ricalnet/digital-independence)
- [Dokumentasi Resmi Jellyfin](https://jellyfin.org/docs/)
- [Dokumentasi Podman](https://podman.io/docs/)