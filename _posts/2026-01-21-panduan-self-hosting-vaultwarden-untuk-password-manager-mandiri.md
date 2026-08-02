---
title: Panduan Self-Hosting Vaultwarden untuk Password Manager Mandiri
description: Pelajari cara menginstal Vaultwarden secara mandiri dengan Docker. Tutorial ini memandu Anda langkah demi langkah menyiapkan password manager open-source yang aman dengan kontrol data penuh.
categories: [Digital Independence, Password Manager]
tags: [self-hosted, linux, vaultwarden]
author: rical
last_modified_at: 2026-07-01
---

## Pendahuluan

Kata sandi menjadi fondasi perlindungan data pribadi dan profesional. Namun, mempercayakan seluruh kredensial Anda kepada pihak ketiga menimbulkan pertanyaan mendasar: siapa yang benar-benar memiliki kendali atas data Anda?

Vaultwarden menawarkan solusi elegan untuk dilema ini. Sebagai implementasi alternatif dari Bitwarden yang ditulis dalam Rust, Vaultwarden menghadirkan server password manager yang ringan, cepat, dan kompatibel penuh dengan klien Bitwarden resmi. Keunggulan utamanya adalah kemampuan self-hosting, memberikan Anda kontrol absolut atas infrastruktur penyimpanan kata sandi.

### Mengapa Self-Hosting Vaultwarden?

| Aspek            | Layanan Cloud                       | Self-Hosting Vaultwarden           |
| ---------------- | ----------------------------------- | ---------------------------------- |
| Kepemilikan Data | Data di server pihak ketiga         | Data sepenuhnya di server Anda     |
| Biaya            | Langganan bulanan/tahunan           | Gratis (hanya biaya infrastruktur) |
| Privasi          | Bergantung pada kebijakan penyedia  | Privasi total, tanpa pihak ketiga  |
| Kontrol          | Terbatas pada fitur yang disediakan | Penuh, termasuk backup dan migrasi |
| Ketersediaan     | Bergantung pada layanan penyedia    | Bergantung pada infrastruktur Anda |

Dengan Vaultwarden, Anda tidak hanya menghemat biaya langganan, tetapi juga membangun fondasi keamanan digital yang benar-benar mandiri—sesuai dengan prinsip Digital Independence.

## Langkah 1: Clone Repository dan Instalasi Otomatis

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

## Langkah 2: Instalasi Docker Engine

**Untuk Debian:**
```bash
./install-docker-engine-on-debian.sh
```

**Untuk Ubuntu:**
```bash
./install-docker-engine-on-ubuntu.sh
```

### Apa yang Dilakukan Script Instalasi?
Script ini mengotomatiskan proses yang biasanya memakan waktu dan rawan kesalahan:
1. Update package repository sistem
2. Install dependencies (ca-certificates, curl, gnupg, lsb-release)
3. Tambahkan GPG key resmi Docker untuk verifikasi keamanan
4. Konfigurasi repository Docker agar menggunakan paket resmi
5. Install Docker Engine, CLI, dan Containerd
6. Tambahkan user saat ini ke group docker (menghindari penggunaan `sudo` setiap kali)

> Docker menyediakan isolasi lingkungan yang sempurna untuk SearXNG. Dengan kontainer, Anda mendapatkan:
- Berjalan identik di semua sistem
- Tidak ada konflik dengan aplikasi lain di server
- Cukup pull image baru dan restart kontainer untuk update
- Kembali ke versi sebelumnya dengan satu perintah
{: .prompt-info}

## Langkah 3: Persiapan Konfigurasi Vaultwarden

Berpindah ke direktori Vaultwarden untuk memulai konfigurasi aplikasi:

```bash
cd vaultwarden
```

### Membuat File Konfigurasi dari Template

```bash
cp .env.example .env
```

File `.env` adalah jantung konfigurasi Vaultwarden. Dengan menyalin dari template, Anda memastikan semua variabel yang diperlukan tersedia. Tidak ada variabel yang terlewatkan yang dapat menyebabkan kegagalan fungsi aplikasi.

### Konfigurasi Variabel Lingkungan

Buka file `.env` dengan editor teks (nano, vim, atau editor lain) dan sesuaikan variabel berikut:

```
DOMAIN=https://your-domain.com
SIGNUPS_ALLOWED=false
ADMIN_TOKEN=your-strong-secret-token-here
```

## Langkah 4: Deploy Vaultwarden dengan Docker Compose

Docker Compose adalah alat orkestrasi yang memungkinkan Anda mendefinisikan dan menjalankan multi-container Docker applications. Dalam kasus Vaultwarden, compose file mengatur container utama dan dependensinya.

### Menjalankan Container

```bash
docker compose up -d
```

Parameter `-d` (detach) menjalankan container di latar belakang, memungkinkan Anda tetap menggunakan terminal untuk tugas lain.

## Langkah 5: Mengakses Vaultwarden

Dengan container berjalan, Vaultwarden dapat diakses melalui:

### Akses Lokal (Untuk Testing)
```
http://127.0.0.1:8000
```

### Akses Publik (Setelah Reverse Proxy)
```
https://your-domain.com
```

Untuk akses publik, Anda perlu mengkonfigurasi reverse proxy (Nginx, Apache, atau Caddy) yang akan:
1. Menerima request HTTPS dari port 443
2. Meneruskannya ke container Vaultwarden di port 8000
3. Menambahkan header yang diperlukan (Host, X-Forwarded-For, X-Forwarded-Proto)

## Langkah 6: Konfigurasi Admin Panel

Setelah akses berhasil, lakukan setup admin:

1. Buka `https://your-domain.com/admin`
2. Masukkan `ADMIN_TOKEN` yang telah Anda konfigurasi

### Tugas Admin Awal yang Direkomendasikan:

1. Disable signup (jika belum):
   - Buka "Settings" → "General settings"
   - Pastikan "Allow new signups" = true atau ceklis

2. Buat akun:
   - Kembali ke halaman awal
   - Klik "Create User"
   - Isi email dan password

## Kesimpulan

Anda telah berhasil menginstal Vaultwarden—password manager self-hosted yang memberikan Anda kendali penuh atas keamanan digital. Dengan mengikuti panduan ini, Anda telah:

1. Memahami filosofi di balik self-hosting dan Docker
2. Mengimplementasikan infrastruktur container yang scalable
3. Mengonfigurasi aplikasi sesuai kebutuhan spesifik
4. Mengamankan instalasi dengan praktik terbaik keamanan

Ke depannya, pertimbangkan untuk:
- Mengeksplorasi integrasi dengan klien Bitwarden di mobile dan desktop
- Mengkonfigurasi monitoring dengan Prometheus dan Grafana
- Membangun pipeline backup otomatis ke lokasi remote
- Mengimplementasikan disaster recovery plan

Selamat menikmati kemerdekaan digital Anda! 🔐

## Referensi dan Sumber Daya

- [Digital Independence Repository](https://github.com/ricalnet/digital-independence)
- [Panduan Implementasi Hidden Service Tor](https://ricaldocs.github.io/posts/panduan-implementasi-hidden-service-tor/)
- [Dokumentasi Resmi Vaultwarden](https://github.com/dani-garcia/vaultwarden/wiki)
- [Bitwarden Client Apps](https://bitwarden.com/download/)
- [Docker Documentation](https://docs.docker.com/)
- [Let's Encrypt untuk HTTPS](https://letsencrypt.org/)