---
title: Panduan Instalasi dan Konfigurasi Calibre-Web
description: Langkah mudah install Calibre-Web di Linux. Artikel ini mencakup persyaratan sistem, cara menjalankan server, dan login pertama untuk mengelola database perpustakaan digital Anda.
categories: [Digital Independence, Library]
tags: [self-hosted, docker, calibre]
author: rical
last_modified_at: 2026-03-14
---

## Pendahuluan
Calibre-Web adalah aplikasi web yang menyediakan antarmuka bersih untuk menjelajah, membaca, dan mengunduh buku elektronik dari koleksi perpustakaan Calibre yang sudah ada. Aplikasi ini ditulis dalam bahasa pemrograman Python dan dikembangkan sebagai alternatif berbasis web dari aplikasi desktop Calibre. Calibre-Web mempertahankan struktur database Calibre sambil menawarkan aksesibilitas melalui peramban web.

## Persyaratan Sistem
### Perangkat Lunak
- **Python**: Versi 3.7 atau lebih baru
- **Imagemagick**: Diperlukan untuk ekstraksi sampul buku dari format EPUB
- **Ghostscript**: Diperlukan untuk pengguna Windows dalam ekstraksi sampul dari PDF
- **Alat Opsional**:
  - Program desktop Calibre untuk konversi dan pengeditan metadata
  - Kepubify untuk dukungan perangkat Kobo

## Instalasi

### Persiapan Sistem
Perbarui sistem dan instal paket dependensi yang diperlukan:
```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y git python3 python3-pip python3-setuptools build-essential python3-dev python3-venv unrar
```

### Unduh dan Siapkan Calibre-Web
1. Klon repositori Calibre-Web:
   ```bash
   git clone https://github.com/janeczku/calibre-web.git && cd calibre-web
   ```

2. Buat lingkungan virtual Python:
   ```bash
   python3 -m venv venv
   ```

3. Aktifkan lingkungan virtual:
   ```bash
   source venv/bin/activate
   ```

4. Instal dependensi Python:
   ```bash
   pip3 install -U -r requirements.txt
   ```

   ```bash
   pip install calibreweb
   ```

### Menjalankan Calibre-Web
Jalankan layanan dengan perintah:
```bash
cps
```

## Penggunaan

1. Akses Calibre-Web: 
   - Buka peramban web dan akses:
     ```
     http://localhost:8083
     ```
     > **Login Awal** <br> Nama Pengguna: admin <br> Kata Sandi: admin123
     {: .prompt-tip}

   - Untuk katalog OPDS:
     ```
     http://localhost:8083/opds
     ```

2. Penyiapan Database:
   - Unduh contoh database dari:
     ```
     https://github.com/janeczku/calibre-web/raw/master/library/metadata.db
     ```
   - Pindahkan file database ke lokasi aman di luar folder `calibre-web`{: .filepath}

3. Konfigurasi Database:
   - Pada antarmuka admin, atur `Location of Calibre database` ke jalur folder yang berisi `metadata.db`{: .filepath}
   - Klik "Simpan" untuk menerapkan perubahan

4. Lakukan konfigurasi melalui halaman admin dengan mengacu pada `Basic Configuration` dan `UI Configuration`.

## Pranala Luar
- [Situs Web Resmi Calibre](https://calibre-ebook.com/)
- [Repositori resmi Calibre-Web](https://github.com/janeczku/calibre-web)
- [Docker Command Reference](https://ricaldocs.github.io/posts/docker-command-reference/)