---
title: Panduan Instalasi dan Konfigurasi Calibre-Web
description: Langkah mudah install Calibre-Web di Linux. Artikel ini mencakup persyaratan sistem, cara menjalankan server, dan login pertama untuk mengelola database perpustakaan digital Anda.
categories: [Digital Independence, Library]
tags: [self-hosted, docker, calibre]
author: rical
last_modified_at: 2026-03-14
---

## Pendahuluan

Calibre-Web adalah aplikasi web yang menyediakan antarmuka bersih untuk menjelajah, membaca, dan mengunduh buku elektronik dari koleksi perpustakaan Calibre yang sudah ada. Aplikasi ini ditulis dalam Python dan dikembangkan sebagai alternatif berbasis web dari aplikasi desktop Calibre.

Mengapa Calibre-Web?

| Keunggulan           | Penjelasan                             |
| -------------------- | -------------------------------------- |
| Akses dari mana saja | Cukup browser, tanpa instalasi desktop |
| Ringan               | Berjalan di Raspberry Pi sekalipun     |
| Multi-user           | Dukungan akun dengan hak akses berbeda |
| OPDS support         | Baca di perangkat e-reader (Kobo, dll) |

Calibre-Web mempertahankan struktur database Calibre (file `metadata.db`) sambil menawarkan aksesibilitas melalui peramban web. Database Calibre adalah file SQLite yang berisi semua metadata buku (judul, penulis, sampul, sinopsis, dll), sementara file buku (EPUB, PDF, dll) disimpan di folder yang sama.

## Persyaratan Sistem

### Perangkat Lunak

| Komponen        | Fungsi                              | Mengapa Diperlukan                              |
| --------------- | ----------------------------------- | ----------------------------------------------- |
| Python 3.7+     | Runtime aplikasi                    | Calibre-Web ditulis dalam Python                |
| Imagemagick     | Ekstraksi sampul dari EPUB          | Menghasilkan thumbnail cover untuk tampilan web |
| Ghostscript     | Ekstraksi sampul dari PDF (Windows) | Alternatif untuk format PDF                     |
| Calibre Desktop | Konversi dan metadata (opsional)    | Untuk fungsionalitas konversi format buku       |
| Kepubify        | Dukungan Kobo (opsional)            | Mengoptimalkan EPUB untuk perangkat Kobo        |

### Spesifikasi Minimum

| Komponen | Minimum               | Catatan                                 |
| -------- | --------------------- | --------------------------------------- |
| RAM      | 512 MB                | Cukup untuk penggunaan pribadi          |
| Storage  | 1 GB + ukuran koleksi | Database kecil, buku yang memakan ruang |
| CPU      | Single core           | Tidak berat kecuali untuk konversi      |

## Instalasi

### Persiapan Sistem

Update sistem dan instal dependensi:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git python3 python3-pip python3-setuptools build-essential python3-dev python3-venv unrar
```

| Paket                            | Fungsi                      | Mengapa                                                        |
| -------------------------------- | --------------------------- | -------------------------------------------------------------- |
| `git`                            | Mengunduh source code       | Repositori Calibre-Web di GitHub                               |
| `python3`, `python3-pip`         | Runtime dan package manager | Menjalankan aplikasi dan menginstal dependensi                 |
| `python3-venv`                   | Lingkungan virtual          | Mengisolasi dependensi Python agar tidak bentrok dengan sistem |
| `build-essential`, `python3-dev` | Build tools                 | Beberapa dependensi Python perlu dikompilasi                   |
| `unrar`                          | Ekstrak file RAR            | Buku kadang dalam format RAR                                   |

### Unduh dan Siapkan Calibre-Web

#### 1. Clone repositori:

```bash
git clone https://github.com/janeczku/calibre-web.git
cd calibre-web
```

Dengan git, Anda bisa `git pull` untuk update di kemudian hari.

#### 2. Buat lingkungan virtual Python:

```bash
python3 -m venv venv
```

Lingkungan virtual mengisolasi dependensi Calibre-Web dari sistem utama. Ini mencegah konflik versi paket Python.

#### 3. Aktifkan lingkungan virtual:

```bash
source venv/bin/activate
```

Setelah diaktifkan, prompt terminal akan berubah menunjukkan `(venv)`.

#### 4. Instal dependensi:

```bash
pip3 install -U -r requirements.txt
```

```bash
pip install calibreweb
```

| Perintah           | Fungsi                                        |
| ------------------ | --------------------------------------------- |
| `-U`               | Upgrade ke versi terbaru jika sudah terinstal |
| `requirements.txt` | Daftar semua dependensi yang dibutuhkan       |

> Gunakan `pip3` untuk memastikan Python 3, bukan Python 2 yang sudah usang.
{: .prompt-info}

### Menjalankan Calibre-Web

```bash
cps
```

Apa yang terjadi saat `cps` dijalankan?
1. Server web mulai di port 8083 (default)
2. Membaca konfigurasi dari file `config.py` atau `config` folder
3. Jika pertama kali, membuat file konfigurasi default
4. Menunggu koneksi dari browser

## Penggunaan

### 1. Akses Calibre-Web

Buka browser dan akses:

```
http://localhost:8083
```

> Login Awal
>
> | Field | Nilai |
> |-------|-------|
> | Username | `admin` |
> | Password | `admin123` |
>
> Mengapa harus login? Calibre-Web memiliki sistem autentikasi untuk membatasi akses, terutama jika diakses dari internet.
{: .prompt-tip}

OPDS Catalog (untuk e-reader):
```
http://localhost:8083/opds
```
OPDS (Open Publication Distribution System) adalah format feed untuk katalog buku digital. Perangkat seperti Kobo atau aplikasi pembaca eBook bisa menggunakan endpoint ini untuk menyinkronkan koleksi.

### 2. Penyiapan Database

Calibre-Web membutuhkan file database Calibre (`metadata.db`).

Mengunduh contoh database:

```bash
wget https://github.com/janeczku/calibre-web/raw/master/library/metadata.db
```

Atau Anda bisa menggunakan database dari instalasi Calibre desktop Anda (biasanya di `~/Calibre Library/metadata.db`).

Pindahkan ke lokasi aman:
```bash
mv metadata.db ~/calibre-library/
```

> Mengapa harus di luar folder `calibre-web`? Agar tidak terhapus saat update kode. Folder aplikasi dan folder data dipisahkan untuk alasan keamanan dan kemudahan backup.
{: .prompt-warning}

### 3. Konfigurasi Database

Melalui antarmuka admin:

1. Login sebagai admin
2. Buka Admin → Basic Configuration → Calibre Database
3. Pada Location of Calibre database, isi dengan jalur folder yang berisi `metadata.db`

Contoh:
```
/home/user/calibre-library/
```

4. Klik Simpan

> Struktur folder Calibre:
> ```
> /home/user/calibre-library/
> ├── metadata.db          # Database SQLite (semua metadata)
> ├── Penulis A/           # Folder berdasarkan penulis
> │   └── Judul Buku/      # Folder per buku
> │       ├── cover.jpg    # Sampul
> │       ├── metadata.opf # Metadata dalam format OPF
> │       └── buku.epub    # File buku
> └── ...
> ```
>
> Calibre-Web membaca struktur ini dan menampilkannya sebagai antarmuka web.
{: .prompt-info}

### 4. Konfigurasi Tambahan

Setelah database terhubung, lakukan konfigurasi melalui halaman admin:

| Konfigurasi           | Fungsi                                      | Lokasi Menu                   |
| --------------------- | ------------------------------------------- | ----------------------------- |
| Basic Configuration   | Setting umum, port, log                     | Admin → Basic Configuration   |
| UI Configuration      | Tampilan, bahasa, tema                      | Admin → UI Configuration      |
| User Management       | Tambah/hapus user, atur hak akses           | Admin → User Management       |
| Feature Configuration | Aktif/nonaktifkan fitur (upload, edit, dll) | Admin → Feature Configuration |

## Tips Penggunaan

1. Pengguna dan Hak Akses
- Default: admin (superuser)
- Tambahkan user biasa untuk keluarga/rekan
- Atur akses baca/tulis per user

2. Upload Buku
- Aktifkan di Feature Configuration
- User dengan hak upload bisa menambah buku melalui web

3. Konversi Format
- Memerlukan Calibre desktop terinstal
- Edit metadata juga memerlukan Calibre

4. Backup Data
- Backup `metadata.db` dan folder buku secara teratur
- Folder aplikasi `calibre-web` bisa di-`git pull` tanpa kehilangan data

## Ringkasan Perintah

| Langkah            | Perintah                                                         |
| ------------------ | ---------------------------------------------------------------- |
| Update sistem      | `sudo apt update && sudo apt upgrade -y`                         |
| Install dependensi | `sudo apt install -y git python3 python3-pip python3-venv unrar` |
| Clone repositori   | `git clone https://github.com/janeczku/calibre-web.git`          |
| Masuk folder       | `cd calibre-web`                                                 |
| Buat venv          | `python3 -m venv venv`                                           |
| Aktifkan venv      | `source venv/bin/activate`                                       |
| Install dependensi | `pip install calibreweb`                                         |
| Jalankan server    | `cps`                                                            |
| Akses web          | `http://localhost:8083`                                          |

## Pranala Luar

- [Situs Web Resmi Calibre](https://calibre-ebook.com/)
- [Repositori Resmi Calibre-Web](https://github.com/janeczku/calibre-web)
- [Docker Command Reference](https://ricaldocs.github.io/posts/docker-command-reference/)