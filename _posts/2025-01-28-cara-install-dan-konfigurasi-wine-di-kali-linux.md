---
title: Cara Install & Konfigurasi Wine di Kali Linux
description: Panduan lengkap instalasi Wine dan Winetricks di Kali Linux untuk menjalankan aplikasi serta game Windows. Dilengkapi cara mount ISO, konfigurasi winecfg, dan tips optimasi performa.
categories: [no categories]
tags: [linux, wine]
author: rical
last_modified_at: 2026-06-01
---

## Pengenalan Wine
Wine (Wine Is Not an Emulator) merupakan lapisan kompatibilitas yang memungkinkan eksekusi aplikasi Windows pada sistem operasi berbasis Linux, termasuk Kali Linux. Berbeda dengan pendekatan virtualisasi atau emulasi, Wine beroperasi dengan menerjemahkan panggilan API Windows menjadi panggilan sistem POSIX secara native, sehingga menghilangkan overhead performa dan konsumsi memori yang umum terjadi pada metode konvensional. Mekanisme ini memungkinkan integrasi aplikasi Windows secara seamless dalam desktop environment Linux.

## Proses Instalasi Wine pada Kali Linux
Untuk melakukan instalasi Wine pada Kali Linux, eksekusi perintah berikut melalui terminal:

```bash
sudo apt install wine -y
```

Setelah proses instalasi dasar selesai, verifikasi versi Wine yang terpasang. Untuk mendukung eksekusi aplikasi 32-bit, diperlukan paket tambahan `wine32`. Sebelum instalasi, tambahkan arsitektur 32-bit ke dalam sistem dengan perintah:

```bash
sudo dpkg --add-architecture i386
```

Perbarui repositori sistem untuk mengakomodasi perubahan arsitektur:

```bash
sudo apt update
```

Lanjutkan dengan instalasi paket 32-bit:

```bash
sudo apt install wine32 -y
```

Durasi instalasi bervariasi tergantung kondisi jaringan dan spesifikasi sistem. Setelah komplet, konfirmasi restart beberapa library dengan memilih opsi "Yes". Disarankan untuk melakukan restart sistem setelah proses selesai.

### Konfigurasi Wine
Inisialisasi konfigurasi Wine melalui perintah:

```bash
winecfg
```

Antarmuka konfigurasi memungkinkan penyesuaian berbagai parameter termasuk versi Windows target, pengaturan Libraries, Graphics, Audio, dan Drives. Untuk penggunaan standar, konfigurasi default dapat dipertahankan.

## Eksekusi Aplikasi Windows pada Kali Linux
Jalankan aplikasi Windows melalui terminal dengan sintaks:

```bash
wine nama_aplikasi.exe
```

Untuk eksekusi file `.exe` melalui antarmuka grafis, tentukan Wine sebagai handler default dengan membuat symbolic link:

```bash
sudo ln -s /usr/share/doc/wine/examples/wine.desktop /usr/share/applications
```

Setelah itu, atur asosiasi file `.exe` melalui menu "Open With" dengan memilih "Wine Windows Program Loader".

Wine membuat struktur direktori virtual di `~/.wine` yang meniru sistem file Windows untuk keperluan instalasi dan penyimpanan data aplikasi.

### Mounting Image ISO Game Windows
Untuk mengakses konten image ISO game Windows, ikuti prosedur berikut:

#### 1. Mounting Image ISO
Buat direktori tujuan mounting:

```bash
mkdir ~/iso_mount
```

Lakukan mounting image ISO ke direktori target:

```bash
sudo mount -o loop /path/ke/game.iso ~/iso_mount
```

#### 2. Eksekusi Instalator/Game
Jalankan file executable melalui Wine, contoh untuk installer:

```bash
wine ~/iso_mount/setup.exe
```

#### 3. Unmount Image ISO
Setelah selesai, lepaskan mounting point:

```bash
sudo umount ~/iso_mount
```

## Winetricks: Komponen Pendukung
Winetricks menyediakan kumpulan script untuk menginstal berbagai dependensi Windows tambahan seperti library, runtime, dan komponen sistem.

Instalasi paket melalui perintah:

```bash
sudo apt install winetricks -y
```

Akses antarmuka Winetricks melalui:

```bash
winetricks
```