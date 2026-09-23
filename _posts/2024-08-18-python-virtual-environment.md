---
title: Python Virtual Environment
description: Membuat lingkungan virtual di Python untuk mempermudah proses developments.
categories: [no categories]
tags: [python, python venv]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Python Virtual Environment adalah alat yang digunakan untuk membuat lingkungan terisolasi untuk proyek pengembangan Python. Ini mempermudah manajemen dependensi dan versi paket, sehingga menghindari konflik antara proyek yang berbeda.

## Prasyarat
Sebelum melanjutkan ke langkah-langkah konfigurasi, pastikan bahwa [Python](https://www.python.org/) telah diinstal di sistem.

## Memeriksa Versi Python
Untuk memeriksa versi Python yang terinstal, masukkan perintah berikut ke terminal:

```bash
python3 --version
```

## Instalasi venv
Untuk menginstal paket `venv`, gunakan perintah berikut:

```bash
sudo apt install python3-venv
```

Setelah itu, buat folder untuk proyek, misalnya:

```bash
mkdir projects
```

Kemudian, buat lingkungan virtual dengan menjalankan perintah:

```bash
python3 -m venv projects/
```

### Mengaktifkan Lingkungan Virtual
Untuk mengaktifkan lingkungan virtual, gunakan perintah berikut:

```bash
source projects/bin/activate
```

Setelah diaktifkan, prompt terminal akan menunjukkan nama *virtual environment*, menandakan bahwa `venv` sudah siap digunakan.

### Menonaktifkan Lingkungan Virtual
Untuk menonaktifkan lingkungan virtual, gunakan perintah:

```bash
deactivate
```

## Lingkungan Virtual di Android
Untuk pengguna Android, unduh aplikasi [Termux](https://f-droid.org/en/packages/com.termux/) dan instal melalui pengelola file.

Setelah instalasi, gunakan perintah berikut untuk memperbarui paket:

```bash
pkg update && pkg upgrade -y
```

Kemudian, pasang Python dengan perintah:

```bash
pkg install python && python --version
```

Untuk membuat lingkungan virtual, gunakan perintah:

```bash
python3 -m venv venv
```

Aktifkan lingkungan virtual dengan perintah:

```bash
source venv/bin/activate
```

Setelah diaktifkan, prompt terminal akan menunjukkan nama *virtual environment*, menandakan bahwa `venv` sudah siap digunakan.

Terakhir, untuk memasang modul, gunakan perintah:

```bash
pip install nama_modul
```
