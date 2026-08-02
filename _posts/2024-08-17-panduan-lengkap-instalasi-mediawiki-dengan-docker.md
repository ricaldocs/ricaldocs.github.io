---
title: Panduan Lengkap Instalasi MediaWiki dengan Docker
description: Tutorial teknis instalasi MediaWiki menggunakan Docker di lingkungan Linux. Panduan langkah demi langkah untuk mengelola wiki pribadi dengan konfigurasi optimal dan keamanan terjamin.
categories: [Digital Independence, Wiki]
tags: [mediawiki, docker]
author: rical
last_modified_at: 2026-07-05
---

## Pendahuluan

MediaWiki adalah platform wiki open-source yang powerful, digunakan oleh Wikipedia dan ribuan organisasi di seluruh dunia. Dalam era digital independence, memiliki wiki pribadi memberikan kontrol penuh atas pengetahuan dan dokumentasi Anda. Panduan ini akan memandu Anda menginstal MediaWiki menggunakan Docker—pendekatan yang menjamin konsistensi, kemudahan pemeliharaan, dan portabilitas tinggi.

### Mengapa Menggunakan Docker untuk MediaWiki?

Docker menyediakan lingkungan kontainer yang terisolasi untuk MediaWiki beserta dependensinya (PHP, web server, database). Keuntungan utama:

- Berjalan identik di semua sistem operasi yang mendukung Docker
- Tidak ada konflik dengan aplikasi lain di server
- Update cukup dengan pull image baru dan restart
- Kembali ke versi sebelumnya dengan satu perintah
- Mudah menambahkan komponen tambahan seperti cache atau load balancer

## 1. Instalasi Docker

Docker adalah prerequisite mutlak sebelum menjalankan MediaWiki. Ricalnet menyediakan script instalasi otomatis yang telah teruji di berbagai distribusi Linux.

### Clone Repository dan Instalasi Otomatis

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

### Instalasi Docker Engine

**Untuk Debian:**
```bash
./install-docker-engine-on-debian.sh
```

**Untuk Ubuntu:**
```bash
./install-docker-engine-on-ubuntu.sh
```

#### Apa yang Dilakukan Script Instalasi?
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

## 2. Masuk ke Direktori dan Environment

Masuk ke direktori `wiki` dan sesuaikan variabel `.env`.

```bash
cd wiki
cp .env.example .env
nano .env
```

### Membuat Password

Sebelum menjalankan container, buat password untuk admin panel:

```bash
openssl rand --hex 32
```

Salin output-nya, lalu tempelkan sebagai nilai `MYSQL_ROOT_PASSWORD` di file `.env`. Contoh:

```yaml
MYSQL_ROOT_PASSWORD=a1b2c3d4e5f67890abcdef1234567890
```

## 3. Konfigurasi dan Menjalankan Container

### 3.1 Persiapan File Konfigurasi

Sebelum menjalankan container, Anda perlu mengomentari binding `LocalSettings.php` di file `docker-compose.yaml`. Ini diperlukan karena file konfigurasi belum ada pada instalasi pertama.

Edit docker-compose.yaml:

```bash
nano docker-compose.yaml
```

Cari dan comment baris ini (tambahkan `#` di awal):

```yaml
# - ${LOCALSETTINGS_PATH:-./LocalSettings.php}:/var/www/html/LocalSettings.php
```

### 3.2 Menjalankan Container

```bash
docker compose up -d
```

Penjelasan perintah:
- `docker compose`: Menggunakan Docker Compose untuk mengelola multi-container
- `up`: Memulai container yang didefinisikan di docker-compose.yaml
- `-d`: Detached mode—menjalankan container di background

Saat perintah dijalankan, Docker Compose akan:

1. Jika image belum ada, Docker akan menarik (pull) image MediaWiki dan MariaDB dari Docker Hub
2. Membuat jaringan internal antar container
3. Menyiapkan volume persistent untuk penyimpanan data database
4. Container MariaDB akan start dengan konfigurasi dari `.env`
5. Container MediaWiki akan start, menunggu database siap

Untuk melihat log real-time:

```bash
docker compose logs -f
```

## 4. Setup Awal MediaWiki

### 4.1 Akses Installer

Buka browser dan akses:

```
http://localhost:8002/
```

Jika menggunakan server remote, ganti `localhost` dengan alamat IP server:
```
http://192.168.x.x:8002/
```

### 4.2 Proses Instalasi Wizard

MediaWiki akan menampilkan installer wizard dengan langkah-langkah:

1. **Pilih Bahasa**: Pilih bahasa yang diinginkan (Indonesia/English)
2. **Verifikasi Environment**: Installer akan memeriksa semua requirement
3. **Koneksi Database**: Isi informasi database sesuai .env:
   - Database type: MySQL
   - Database host: `database` (nama service di docker-compose)
   - Database name: sesuai `MYSQL_DATABASE`
   - Username: sesuai `MYSQL_USER`
   - Password: sesuai `MYSQL_PASSWORD`
4. **Konfigurasi Situs**: 
   - Nama situs
   - Logo (opsional)
   - Hak akses (publik/private)
5. **Buat Akun Admin**: Username, password, dan email

### 4.3 Simpan `LocalSettings.php`

Setelah instalasi selesai, MediaWiki akan menghasilkan file `LocalSettings.php`. 
> Jangan tutup browser sebelum menyimpan file ini!
{: .prompt-warning}

Installer akan menampilkan file tersebut dalam textarea. Lakukan:

1. Copy seluruh isi `LocalSettings.php`
2. Simpan di direktori current dengan nama `LocalSettings.php`
3. Verifikasi file telah tersimpan dengan benar

### 4.4 Aktivasi Konfigurasi Persisten

Setelah menyimpan `LocalSettings.php`, aktivasikan binding di docker-compose:

Edit `docker-compose.yaml` dan uncomment baris `LocalSettings.php`:

```yaml
- ${LOCALSETTINGS_PATH:-./LocalSettings.php}:/var/www/html/LocalSettings.php
```

Restart container:

```bash
docker compose down
docker compose up -d
docker compose logs -f
```

> Tanpa binding, `LocalSettings.php` hanya ada di dalam container. Jika container dihapus atau di-restart, konfigurasi akan hilang dan Anda harus setup ulang. Dengan binding, file konfigurasi disimpan di host dan tetap ada bahkan jika container di-recreate.
{: .prompt-info}

## 5. Maintenance dan Update

### Update MediaWiki

```bash
docker compose pull
docker compose down
docker compose up -d
```

## 6. Referensi dan Sumber Daya

- [Digital Independence](https://github.com/ricalnet/digital-independence)
- [Panduan Implementasi Hidden Service Tor](https://docs.ricalnet.my.id/posts/panduan-implementasi-hidden-service-tor/)
- [Dokumentasi Resmi MediaWiki](https://www.mediawiki.org/wiki/MediaWiki)
- [Dokumentasi Docker](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [MediaWiki Docker Image](https://hub.docker.com/_/mediawiki)

## Kesimpulan

Dengan mengikuti panduan ini, Anda telah berhasil menginstal MediaWiki menggunakan Docker. MediaWiki yang sudah berjalan dapat dikembangkan lebih lanjut dengan berbagai ekstensi, skin, dan integrasi lainnya sesuai kebutuhan komunitas atau organisasi Anda.