---
title: DynamicArchive
description: Arsipkan folder menjadi file dengan enkripsi untuk meningkatkan keamanan backup menggunakan DynamicArchive.
categories: [Cybersecurity,  rical_net, Linux, Privacy]
tags: [cybersecurity, rical_net, privacy, linux, open source]
author: rical
---

DynamicArchive berfungsi untuk mengarsipkan folder menjadi file terkompresi (tar atau zip) dengan fitur enkripsi, serta mengekstrak file terkompresi yang telah dienkripsi. Alat ini dirancang untuk memberikan kemudahan dalam pengelolaan arsip, sambil menambahkan lapisan keamanan melalui [*symmetric encryption*](https://ricaldocs.github.io/posts/gnu-privacy-guard/#asymmetric--symmetric).

## Fitur

1. Mengarsipkan folder menjadi file tar yang terenskripsi.
2. Mengekstrak file tar yang terenskripsi.
3. Mengarsipkan folder menjadi file zip yang terenskripsi.
4. Mengekstrak file zip yang terenskripsi.

## Prasyarat

- Bash or Zsh
- [GnuPG](https://ricaldocs.github.io/posts/gnu-privacy-guard/)
- Zip dan Unzip (untuk opsi zip)

## Penggunaan

Untuk menjalankan skrip ini, cukup jalankan perintah berikut di terminal:

```bash
git clone https://github.com/risnandapascal/DynamicArchive.git && cd DynamicArchive
```

```bash
sudo ./requirements.sh
```

```bash
./dynamic_archive.sh
```

## Menu Pilihan
Setelah menjalankan skrip, kita akan melihat menu pilihan sebagai berikut:
1. Mengarsipkan folder menjadi file tar (encrypted)
2. Mengekstrak file tar yang terenskripsi
3. Mengarsipkan folder menjadi file zip (encrypted)
4. Mengekstrak file zip yang terenskripsi

Silakan pilih opsi dengan memasukkan angka yang sesuai (1, 2, 3, atau 4).

## Langkah-langkah
### TAR
Gunakan opsi `1` untuk mengarsipkan folder menjadi file tar (encrypted):
- Masukkan jalur folder yang ingin diarsipkan (misal: `/home/user/backup`).
- Masukkan nama file output (misal: `backup.tar`).
- Skrip akan membuat file tar dan mengenkripsinya menggunakan [GnuPG](https://ricaldocs.github.io/posts/gnu-privacy-guard/) yang akan menghasilkan output `backup.tar.gpg`.

Gunakan opsi `2` untuk mengekstrak file tar yang terenskripsi:
- Masukkan nama file tar yang terenskripsi (misal: `backup.tar.gpg`).
- Skrip akan mendekripsi dan mengekstrak file tersebut.

### ZIP
Gunakan opsi `3` untuk mengarsipkan folder menjadi file zip (encrypted):
- Masukkan jalur folder yang ingin diarsipkan.
- Masukkan nama file output (misal: `backup.zip`).
- Skrip akan membuat file zip dan mengenkripsinya menggunakan [GnuPG](https://ricaldocs.github.io/posts/gnu-privacy-guard/) yang akan menghasilkan output `backup.zip.gpg`.

Gunakan opsi `4` untuk mengekstrak file zip yang terenskripsi:
- Masukkan nama file zip yang terenskripsi (misal: `backup.zip.gpg`).
- Skrip akan mendekripsi dan mengekstrak file tersebut.

## Validasi Nama File
DynamicArchive akan melakukan validasi pada nama file output untuk memastikan hanya karakter alfanumerik, titik, garis bawah, dan tanda hubung yang diperbolehkan.

## Penanganan Kesalahan
Alat ini juga dilengkapi dengan penanganan kesalahan yang memberikan umpan balik kepada pengguna jika terjadi kesalahan, seperti folder tidak ditemukan atau gagal dalam proses enkripsi/dekripsi.

## Lisensi
DynamicArchive dirilis di bawah [lisensi MIT](https://github.com/risnandapascal/DynamicArchive/blob/main/LICENSE.md).

## Source Code
[DynamicArchive](https://github.com/risnandapascal/DynamicArchive)

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)







