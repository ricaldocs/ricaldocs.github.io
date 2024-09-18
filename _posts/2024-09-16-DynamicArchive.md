---
title: DynamicArchive
description: Arsipkan folder menjadi file dengan enkripsi untuk meningkatkan keamanan backup menggunakan DynamicArchive.
categories: [Cybersecurity,  rical_net, Linux, Privacy]
tags: [cybersecurity, rical_net, privacy, linux, open source]
author: rical
---

DynamicArchive berfungsi untuk mengarsipkan folder menjadi file terkompresi dengan fitur enkripsi, serta mengekstrak file terkompresi yang telah dienkripsi. Alat ini dirancang untuk memberikan kemudahan dalam pengelolaan arsip, sambil menambahkan lapisan keamanan melalui [*symmetric encryption*](https://ricaldocs.github.io/posts/gnu-privacy-guard/#asymmetric--symmetric).

## Dukungan Format
- [x] [Tar](https://id.wikipedia.org/wiki/Tar_(komputasi))
- [x] [ZIP](https://id.wikipedia.org/wiki/ZIP_(format_berkas))
- [x] [7-Zip](https://id.wikipedia.org/wiki/7-Zip)
- [x] gz

## Fitur

1. Mengarsipkan folder menjadi file yang terenskripsi dengan [GnuPG](https://ricaldocs.github.io/posts/gnu-privacy-guard/).
2. Mengekstrak file yang terenskripsi.

## Prasyarat

- Bash or Zsh

## Penggunaan

Untuk menjalankan alat ini, cukup jalankan perintah berikut di terminal:

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
5. Mengarsipkan folder menjadi file 7z (encrypted)
6. Mengekstrak file 7z yang terenskripsi
7. Mengarsipkan folder menjadi file gz (encrypted)
8. Mengekstrak file gz yang terenskripsi

Silakan pilih opsi dengan memasukkan angka yang sesuai (1, 2, 3, 4, 5, 6, 7, atau 8).

## Langkah-langkah
Pilih opsi untuk mengarsipkan folder menjadi file (encrypted):
- Masukkan jalur folder yang ingin diarsipkan (misal: `/home/user/backup`).
- Masukkan nama file output (misal: `backup.tar`).
- Skrip akan membuat file dan mengenkripsinya menggunakan [GnuPG](https://ricaldocs.github.io/posts/gnu-privacy-guard/) yang akan menghasilkan output `backup.tar.gpg`.

Pilih opsi untuk mengekstrak file yang terenskripsi:
- Masukkan nama file yang terenskripsi (misal: `backup.tar.gpg`).
- Skrip akan mendekripsi dan mengekstrak file tersebut.

## Validasi Nama File
DynamicArchive akan melakukan validasi pada nama file output untuk memastikan hanya karakter alfanumerik, titik, garis bawah, dan tanda hubung yang diperbolehkan.

## Penanganan Kesalahan
Alat ini juga dilengkapi dengan penanganan kesalahan yang memberikan umpan balik kepada pengguna jika terjadi kesalahan, seperti folder tidak ditemukan atau gagal dalam proses enkripsi/dekripsi.

## Lisensi
DynamicArchive dirilis di bawah [lisensi MIT](https://github.com/risnandapascal/DynamicArchive/blob/main/LICENSE.md).

## Source Code
[rical_net](https://github.com/risnandapascal/DynamicArchive)

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)







