---
title: Membangun Infrastruktur Digital Mandiri dari Nol
description: Panduan lengkap membangun infrastruktur digital mandiri dengan self-hosting 20+ alat open-source seperti Ollama, Immich, Nextcloud, & Vaultwarden via Docker. Privasi 100% di tangan Anda.
categories: [Digital Independence]
tags: [self-hosted, docker, podman, privacy]
author: rical
last_modified_at: 2026-09-02
pin: true
image:
  path: /assets/img/posts/2026-04-03-membangun-infrastruktur-digital-mandiri-dari-nol/thumbnail.png
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
---

## 📌 Ikhtisar

> GitHub Repository: [https://github.com/ricalnet/digital-independence](https://github.com/ricalnet/digital-independence)

Digital Independence adalah kumpulan konfigurasi `podman-compose` siap pakai untuk menjalankan berbagai layanan mandiri di infrastruktur Anda sendiri. Proyek ini memberdayakan individu dan organisasi kecil untuk:

- Menghilangkan akses pihak ketiga dan penambangan data
- Menjaga semuanya tetap dalam infrastruktur Anda
- Menikmati kebebasan untuk beralih, mengubah, atau mengganti layanan
- Menghilangkan biaya berlangganan berulang
- Membangun keterampilan DevOps dan administrasi sistem yang berharga

## 🏗️ Dukungan Arsitektur

Semua layanan dalam repositori ini dibuat dan diuji untuk dua arsitektur CPU utama secara langsung:

| Arsitektur | Platform / Perangkat | Status |
|------------|----------------------|--------|
| `linux/amd64` | Desktop Intel/AMD, server, VPS (x86_64) | ✅ Didukung Penuh |
| `linux/arm64` | Raspberry Pi 4/5, Apple M1/M2/M3, AWS Graviton, server berbasis ARM | ✅ Didukung Penuh |

Meskipun repositori belum diuji pada ARM 32-bit (`arm/v7`) untuk semua layanan (karena beberapa aplikasi yang lebih berat memerlukan 64-bit), seluruh katalog 100% kompatibel dengan `amd64` dan `arm64`.

## ✨ Layanan yang Tersedia

### 🔐 Keamanan

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🛡️ | **Wazuh** | `wazuh/` | 443 | ✅ Ya | Stabil |
| 🛡️ | **Pi-hole** | `pi-hole/` | 53, 8080 | ✅ Ya | Stabil |
| 🔐 | **Vaultwarden** | `vaultwarden/` | 8000 | ✅ Ya | Stabil |
| 🔑 | **Authentik** | `authentik/` | 9000, 9443 | ✅ Ya | Stabil |

### 🤖 AI

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🤖 | **Open WebUI** | `open-webui/` | 3000 | ✅ Ya | Stabil |

> Open WebUI dikonfigurasi untuk bekerja dengan Ollama. Anda perlu mengatur `OLLAMA_BASE_URL` di file `.env`.
{: .prompt-tip}

### 🖥️ Manajemen & Pemantauan

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 📊 | **Dashdot** | `dashdot/` | 3001 | ❌ Tidak | Stabil |
| 🗂️ | **Homarr** | `homarr/` | 7575 | ✅ Ya | Stabil |
| 🔔 | **ntfy** | `ntfy/` | 8010 | ✅ Ya | Stabil |
| ⏱️ | **Uptime Kuma** | `uptime-kuma/` | 9442 | ❌ Tidak | Stabil |
| 🐳 | **Portainer** | `portainer/` | 9444 | ❌ Tidak | Stabil |

### 💬 Komunikasi (Matrix)

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 📨 | **Synapse** | `synapse/` | 8008, 8448 | ✅ Ya | Stabil |
| 💬 | **Element Web** | `element-web/` | 8009 | ❌ Tidak | Stabil |
| 📨 | **Jembatan Mautrix** | `synapse/mautrix/` | - | ✅ Ya | Stabil |

> Jembatan Mautrix (Telegram & WhatsApp) sekarang digabungkan dalam `synapse/mautrix/` dengan satu `compose.yaml` yang mengelola kedua jembatan secara bersamaan. Templat konfigurasi tersedia di `synapse/templates/`.
{: .prompt-info}

### 🌐 Pencarian & Terjemahan

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🌐 | **LibreTranslate** | `libretranslate/` | 5001 | ❌ Tidak | Stabil |
| 🔍 | **SearXNG** | `searxng/` | 8888 | ✅ Ya | Stabil |

### 📁 Media & Konten

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🖼️ | **Immich** | `immich-app/` | 2283 | ✅ Ya | Stabil |
| 🎵 | **Navidrome** | `navidrome/` | 4533 | ⚠️ Opsional | Stabil |
| ☁️ | **Nextcloud** | `nextcloud/` | 5000 | ✅ Ya | Stabil |
| 🎥 | **Jellyfin** | `jellyfin/` | 8096, 8920 | ⚠️ Opsional | Stabil |

### 🔗 Manajemen Tautan

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🔗 | **YOURLS** | `yourls/` | 8001 | ✅ Ya | Stabil |
| 🔗 | **LinkStack** | `linkstack/` | 8003 | ✅ Ya | Stabil |

### 📚 Pengetahuan & Publikasi

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 📚 | **MediaWiki** | `wiki/` | 8002 | ✅ Ya | Stabil |

### 🐘 Media Sosial

| Ikon | Layanan | Direktori | Port | .env Diperlukan | Status |
|------|---------|-----------|------|---------------|--------|
| 🐘 | **Mastodon** | `mastodon/` | 4000, 4001 | ✅ Ya (2 file)* | Stabil |

> Mastodon memerlukan `.env` (untuk Podman) dan `.env.production` (untuk konfigurasi Mastodon)
{: .prompt-info}

> Port yang tercantum adalah port default pada host. Beberapa layanan hanya terikat ke `127.0.0.1` (localhost) untuk alasan keamanan. Ubah konfigurasi di `compose.yaml` setiap layanan untuk mengikat ke `0.0.0.0` atau mengubah port.
{: .prompt-tip}

> Semua layanan dikonfigurasi untuk menggunakan tag gambar `latest` secara default. Untuk lingkungan stabil, **sangat disarankan** untuk menetapkan tag versi spesifik di file `.env` atau `compose.yaml` Anda untuk menghindari perubahan mendadak yang tidak diharapkan dari pembaruan otomatis.
{: .prompt-tip}

### Konfigurasi Jembatan Mautrix

Jembatan Mautrix sekarang digabungkan dalam satu direktori `synapse/mautrix/` dengan satu `compose.yaml`:

```bash
synapse/mautrix/
├── compose.yaml
├── mautrix-telegram-data/
└── mautrix-whatsapp-data/
```

Templat konfigurasi terletak di `synapse/templates/`:
- `config.mautrix-telegram.yaml` → Salin ke `synapse/mautrix/mautrix-telegram-data/config.yaml`
- `config.mautrix-whatsapp.yaml` → Salin ke `synapse/mautrix/mautrix-whatsapp-data/config.yaml`

Tidak seperti dokumentasi resmi, kedua jembatan sekarang dikelola bersama dalam satu file compose. Ini menyederhanakan manajemen dan memastikan kedua jembatan selalu sinkron.

## 📋 Prasyarat

Sebelum memulai, pastikan sistem Anda memenuhi persyaratan berikut:

| Persyaratan | Versi Minimum | Catatan |
|-------------|----------------|---------|
| Podman | 5.4+ | Diperlukan untuk semua operasi kontainer |
| podman-compose | v1.3+ | Diperlukan untuk operasi compose |
| Git | Terbaru | Untuk mengkloning repositori |
| Sistem Operasi | Linux / macOS / WSL2 | Windows WSL2 direkomendasikan |
| `curl` atau `wget` | Terbaru | Untuk pengecekan kesehatan dan unduhan |

### Dependensi Opsional

- `whiptail` atau `dialog` – Untuk menu interaktif di `sovereign.sh`
- `jq` – Untuk parsing JSON dalam skrip otomatisasi

## 🚀 Memulai

### 1. Kloning Repositori

```bash
cd ~/
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

### 2. Instal Podman dan podman-compose

Jika Podman belum terinstal, gunakan skrip instalasi yang disediakan:

Untuk Debian:
```bash
./install-podman-on-debian.sh
```

### 3. Persiapan File Environment

Beberapa layanan memerlukan file konfigurasi `.env`. Setiap layanan yang membutuhkan `.env` menyertakan templat `.env.example`:

```bash
# Contoh untuk Authentik
cp authentik/.env.example authentik/.env
nano authentik/.env   # sesuaikan sesuai kebutuhan

# Contoh untuk Immich
cp immich-app/.env.example immich-app/.env
nano immich-app/.env   # sesuaikan sesuai kebutuhan
```

Generator Kata Sandi Cepat:
```bash
# Hasilkan kata sandi aman
openssl rand -base64 32

# Hasilkan beberapa kata sandi sekaligus
for i in {1..5}; do openssl rand -base64 32; done
```

### 4. Buat Jaringan Eksternal

Beberapa layanan memerlukan jaringan yang dibuat sebelumnya:

```bash
# Untuk Synapse dan jembatan Mautrix
podman network create matrix-network
```

### 5. Kelola Layanan

Gunakan skrip `sovereign.sh` untuk memulai, menghentikan, dan mengelola semua layanan (lihat bagian berikutnya).

## ⚙️ Menggunakan `sovereign.sh`

`sovereign.sh` adalah alat baris perintah yang kuat yang dirancang untuk menyederhanakan manajemen semua layanan dalam satu perintah.

### Menu Interaktif (Termudah untuk Pemula)

```bash
./sovereign.sh -i
```

Atau jalankan tanpa argumen:

```bash
./sovereign.sh
```

### Contoh Perintah Cepat

| Tujuan | Perintah |
|--------|----------|
| Mulai satu layanan | `./sovereign.sh portainer` |
| Mulai semua layanan | `./sovereign.sh -a up` |
| Hentikan layanan | `./sovereign.sh -d portainer` |
| Mulai ulang layanan | `./sovereign.sh -r portainer vaultwarden` |
| Perbarui gambar dan mulai ulang | `./sovereign.sh recycle synapse` |
| Perbarui tanpa waktu henti | `./sovereign.sh update immich` |
| Simulasikan perintah (dry-run) | `./sovereign.sh -n up portainer` |
| Lihat log layanan | `./sovereign.sh logs portainer` |
| Periksa status layanan | `./sovereign.sh ps` |
| Kelola jembatan Mautrix | `./sovereign.sh synapse-mautrix` |

### Panduan Bantuan Lengkap

```bash
./sovereign.sh -h
```

```bash
Digital Independence by Ricalnet
SOVEREIGN.SH v2.0.0 (Podman)

USAGE:
    ./sovereign.sh [OPTIONS] [ACTION] [SERVICE...]

OPTIONS:
    -h, --help              Show this help message
    -l, --list              List all available services
    -a, --all               Run action on all services
    -d, --down              Stop and remove containers (ACTION)
    -r, --restart           Restart services (ACTION)
    -p, --pull              Pull latest images before action
    -b, --build             Build images before action
    -v, --verbose           Show detailed output
    -i, --interactive       Interactive checkbox menu
    -n, --dry-run           Show what would be executed (no changes)
    -s, --sudo              Use sudo for podman commands
    --no-color              Disable colored output

ACTIONS:
    up                      Start services (default)
    down                    Stop and remove services
    restart                 Restart services
    logs                    Show logs (last 50 lines)
    ps                      Show container status
    prune                   Clean up unused resources (podman system prune)

COMBINED ACTIONS:
    recycle                 PULL → DOWN → UP (full refresh with new images)
    update                  PULL → UP (update without downtime)
    fresh                   DOWN → UP (recreate without pull)

EXAMPLES:
    ./sovereign.sh portainer                                    # Start portainer
    ./sovereign.sh -a up                                        # Start all services
    ./sovereign.sh -d portainer                                 # Stop portainer
    ./sovereign.sh -r portainer vaultwarden                     # Restart services
    ./sovereign.sh --pull --all up                              # Update all services
    ./sovereign.sh recycle synapse                              # Full refresh synapse
    ./sovereign.sh recycle synapse synapse-mautrix              # Refresh synapse + mautrix
    ./sovereign.sh fresh immich                                 # Recreate immich only
    ./sovereign.sh -n up portainer                              # Dry run
    ./sovereign.sh -i                                           # Interactive mode

SERVICE NAMING:
    • Main services: use service name directly
    • Mautrix bridges: synapse-mautrix (includes both Telegram & WhatsApp)

RECYCLE SEQUENCE:
    1. PULL  → Download latest images (container still running)
    2. DOWN  → Stop and remove old container
    3. UP    → Start new container with fresh image and config
```

## 🌐 Mengekspos Layanan ke Internet

Secara default, layanan hanya dapat diakses dari localhost. Untuk mengaksesnya dengan aman dari internet, repositori ini mendukung dua pendekatan:

### 🧅 Tor Hidden Service (.onion)

Akses anonim melalui jaringan Tor, ideal untuk privasi maksimum.

- [Panduan Implementasi Layanan Tersembunyi Tor](https://docs.ricalnet.my.id/posts/panduan-implementasi-hidden-service-tor/)
- Manfaat: Tidak perlu nama domain, anonimitas sejati, tahan terhadap sensor

### ☁️ Cloudflare Tunnel

Akses melalui Cloudflare tanpa membuka port firewall.

- [Panduan Konfigurasi Terowongan Cloudflare](https://docs.ricalnet.my.id/posts/panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/)
- Manfaat: Perlindungan DDoS, SSL bawaan, tidak memerlukan IP publik

## 🔒 Panduan Keamanan & Pemeliharaan

Untuk menjaga sistem Anda tetap aman dan stabil, ikuti rekomendasi berikut:

### Pengaturan Awal

- Ubah semua kata sandi default segera di file `.env`
- Gunakan rahasia yang kuat dan unik untuk setiap layanan
- Ikat ke localhost (127.0.0.1) kecuali Anda memerlukan akses eksternal
- Atur izin file yang tepat: `chmod 600 .env` untuk file sensitif

### Pemeliharaan Berkelanjutan

- Data kontainer disimpan di direktori lokal atau volume Podman
- Gunakan opsi `--pull` untuk mendapatkan tambalan keamanan dan pembaruan
- Baca changelog upstream sebelum peningkatan versi utama
- Pantau log untuk aktivitas mencurigakan: `./sovereign.sh logs [layanan]`
- Aktifkan pengecekan kesehatan dan pemantauan dengan Uptime Kuma

## 💾 Pencadangan & Pemulihan

Lindungi data Anda dengan solusi pencadangan yang kuat menggunakan [Chantik](https://github.com/ricalnet/chantik) – alat Perlindungan Cadangan terautentikasi ChaCha20 yang dirancang khusus untuk lingkungan Podman.

## 🤖 Skrip Otomatisasi

Repositori ini menyertakan skrip otomatisasi untuk pemeliharaan terjadwal. Skrip terletak di `automation-scripts/` dan dapat dikonfigurasi melalui cron job.

### 📅 Pembaruan Mingguan

Secara otomatis menarik gambar terbaru dan memperbarui layanan tanpa waktu henti.

```bash
# Salin dan konfigurasi file konfigurasi
cp automation-scripts/weekly-updates/weekly_updates.conf.example automation-scripts/weekly-updates/weekly_updates.conf
nano automation-scripts/weekly-updates/weekly_updates.conf
```

### 🔄 Daur Ulang Bulanan

Melakukan refresh penuh (pull → down → up) pada layanan yang dipilih untuk memastikan kontainer segar.

```bash
# Salin dan konfigurasi file konfigurasi
cp automation-scripts/monthly-recycle/monthly_recycle.conf.example automation-scripts/monthly-recycle/monthly_recycle.conf
nano automation-scripts/monthly-recycle/monthly_recycle.conf
```

### 📊 Pemantauan CPU & Memori

Repositori ini menyertakan skrip pemantauan untuk melacak penggunaan sumber daya:

```bash
# Pemantauan CPU
cp automation-scripts/cpu-monitor/cpu_monitor.example.conf automation-scripts/cpu-monitor/cpu_monitor.conf
nano automation-scripts/cpu-monitor/cpu_monitor.conf

# Pemantauan Memori
cp automation-scripts/memory-monitor/memory_monitor.example.conf automation-scripts/memory-monitor/memory_monitor.conf
nano automation-scripts/memory-monitor/memory_monitor.conf
```

### ⏰ Menyiapkan Cron Job

Tambahkan entri ini ke crontab Anda untuk pemeliharaan otomatis:

```bash
crontab -e
```

```
# NextCloud cron - setiap 5 menit (background jobs)
*/5 * * * * podman exec -u www-data nextcloud_app php -f /var/www/html/cron.php

# Pi-hole gravity update - setiap hari jam 1 pagi (update blocklist)
0 1 * * * podman exec pihole pihole -f

# System cleanup - setiap Minggu jam 2 pagi (bersihkan log & cache)
0 2 * * 0 /path/to/digital-independence/automation-scripts/cleanup-system/cleanup_system.sh

# Weekly updates - setiap hari Minggu jam 3 pagi
0 3 * * 0 /path/to/digital-independence/automation-scripts/weekly-updates/weekly_updates.sh

# Monthly recycle - setiap tanggal 1 jam 6 pagi
0 6 1 * * /path/to/digital-independence/automation-scripts/monthly-recycle/monthly_recycle.sh

# Weekly system update - setiap hari Minggu jam 9 pagi
0 9 * * 0 /path/to/digital-independence/automation-scripts/system-update/system_update.sh
```

> Ganti `/path/to/digital-independence/` dengan jalur sebenarnya tempat Anda mengkloning repositori.
{: .prompt-tip}

### Konfigurasi Skrip

| Skrip | File Konfigurasi | Tujuan |
|--------|-------------|---------|
| `weekly_updates.sh` | `weekly_updates.conf` | Daftar layanan untuk diperbarui mingguan |
| `monthly_recycle.sh` | `monthly_recycle.conf` | Daftar layanan untuk didaur ulang bulanan |
| `cpu_monitor.sh` | `cpu_monitor.conf` | Ambang batas pemantauan penggunaan CPU |
| `memory_monitor.sh` | `memory_monitor.conf` | Ambang batas pemantauan penggunaan memori |

Skrip secara otomatis mencatat outputnya ke direktori `logs/` untuk pemantauan dan pemecahan masalah.

## 🤝 Berkontribusi

Berikut adalah beberapa area di mana Anda dapat membantu:

- Menambahkan konfigurasi untuk layanan baru
- Memperbaiki bug atau meningkatkan fitur di `sovereign.sh`
- Melengkapi atau meningkatkan dokumentasi
- Menguji pada berbagai platform (ARM, x86, dll.)

Silakan buka [Isu](https://github.com/ricalnet/digital-independence/issues) atau kirim [PR](https://github.com/ricalnet/digital-independence/pulls).