---
title: Cara Install Homarr di Docker, Dashboard Server Modern dan Rapi
description: Panduan lengkap instalasi Homarr menggunakan Docker dan Docker Compose. Homarr adalah dashboard sederhana namun powerful untuk mengelola layanan server Anda dengan tampilan yang terorganisir.
categories: [Digital Independence, Dashboard]
tags: [self-hosted, docker, homarr]
author: rical
last_modified_at: 2026-07-02
---

Homarr adalah dashboard yang ringan dan dapat dikustomisasi untuk mengelola semua layanan self-hosted Anda dalam satu tampilan. Artikel ini akan memandu Anda langkah demi langkah dalam memasang Homarr menggunakan Docker dan Docker Compose.

![alt text](../assets/img/posts/2026-03-14-cara-install-homarr-di-docker-dashboard-server-modern-dan-rapi/dashboard.jpg)

## 1. Instalasi Docker

Docker adalah prerequisite mutlak sebelum menjalankan Homarr. Ricalnet menyediakan script instalasi otomatis yang telah teruji di berbagai distribusi Linux.

### Clone Repository dan Instalasi Otomatis

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

### Instalasi Docker Engine

Untuk Debian:
```bash
./install-docker-engine-on-debian.sh
```

Untuk Ubuntu:
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

## 2. Instalasi Homarr

Setelah Docker siap, kita akan membuat direktori proyek dan file `docker-compose.yml` untuk Homarr.

### Masuk ke Direktori dan Environment

Masuk ke direktori `homarr` dan sesuaikan variabel `.env`.

```bash
cd homarr
cp .env.example .env
nano .env
```

> Isi nilai `SECRET_ENCRYPTION_KEY`. **Anda wajib menggantinya dengan kunci acak yang unik** untuk keamanan instalasi Anda. Kunci ini digunakan untuk mengenkripsi data sensitif. Anda dapat menghasilkan kunci baru dengan perintah berikut:
```bash
openssl rand -hex 32
```
Salin keluaran perintah tersebut dan gunakan sebagai nilai `SECRET_ENCRYPTION_KEY`.
{: .prompt-tip}

### Menjalankan Homarr

Setelah file konfigurasi siap, jalankan container Homarr di latar belakang:

```bash
docker compose up -d
docker compose logs -f
```

Perintah ini akan mengunduh image Homarr (jika belum ada) dan menjalankan container sesuai konfigurasi.

### Mengakses Homarr

Homarr akan berjalan pada port `7575` di alamat IP server Anda. Buka browser dan akses:

```
http://127.0.0.1:7575
```

Anda akan disambut dengan halaman setup awal Homarr.

## 3. Catatan Penting dan Pemeliharaan

### Isu Jaringan dengan Docker Compose

Secara default, Docker Compose membuat jaringan internal untuk stack-nya. Beberapa integrasi (khususnya seperti Dash.) mungkin tidak berfungsi jika menggunakan hostname internal karena klien di luar jaringan tidak mengenali nama tersebut. Disarankan untuk menggunakan alamat IP langsung atau hostname yang dikenal di jaringan lokal. Alternatifnya, buatlah catatan DNS dengan nama host yang sama dengan nama layanan di compose agar dapat diakses dari luar.

### Memperbarui Homarr

Untuk memperbarui Homarr ke versi terbaru, ikuti langkah-langkah berikut:

1. Masuk ke direktori yang berisi `docker-compose.yml`:
   ```bash
   cd homarr
   ```

2. Hentikan container yang sedang berjalan:
   ```bash
   docker compose down
   ```

3. Tarik image terbaru:
   ```bash
   docker compose pull
   ```

4. Jalankan kembali container:
   ```bash
   docker compose up -d
   ```

5. (Opsional) Hapus image lama yang tidak terpakai:
   ```bash
   docker image prune
   ```
   > Perintah ini akan menghapus image yang tidak digunakan, termasuk image Homarr versi lama. Perintah ini juga menghapus image lain yang tidak terpakai, bukan hanya Homarr.
   {: .prompt-warning}

### Otomatisasi Pembaruan dengan Watchtower

Jika Anda ingin proses pembaruan berjalan otomatis, Anda dapat menggunakan [Watchtower](https://github.com/containrrr/watchtower). Watchtower akan memantau container yang berjalan dan memperbaruinya secara berkala ke image terbaru. Konfigurasi Watchtower berada di luar cakupan artikel ini, namun dapat dengan mudah ditambahkan sebagai container terpisah.

## Kesimpulan

Homarr kini telah terpasang dan siap digunakan. Dashboard ini akan membantu Anda mengatur akses cepat ke berbagai layanan self-hosted dengan tampilan yang rapi dan mudah dikustomisasi. Pastikan untuk selalu menjaga keamanan dengan menggunakan kunci enkripsi yang kuat dan melakukan pembaruan secara berkala.