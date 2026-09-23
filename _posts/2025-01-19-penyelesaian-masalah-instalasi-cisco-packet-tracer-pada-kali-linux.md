---
title: Penyelesaian Masalah Instalasi Cisco Packet Tracer pada Kali Linux
description: Panduan mengatasi kendala instalasi Cisco Packet Tracer di lingkungan Kali Linux.
categories: [Cisco Packet Tracer]
tags: [cisco packet tracer, linux]
author: rical
last_modified_at: 2026-06-01
---

## Permasalahan Instalasi Cisco Packet Tracer pada Kali Linux
Pengguna melaporkan kegagalan dalam proses instalasi Cisco Packet Tracer setelah melakukan instalasi baru Kali Linux. Padahal sebelumnya, aplikasi dapat berjalan dengan baik pada versi Debian terdahulu. Saat ini, pengguna mengalami error yang konsisten selama proses instalasi.

### Dependensi yang Bermasalah
Terdapat dua dependensi yang tidak dapat terinstalasi secara otomatis:

1. **libxcb-xinerama0-dev**
2. **libgl1-mesa-glx**

## Langkah Penyelesaian

### 1. Instalasi Paket `libxcb-xinerama0-dev`

Untuk mengatasi dependensi pertama, jalankan perintah berikut melalui terminal:

```bash
sudo apt install libxcb-xinerama0-dev
```

Proses ini umumnya berhasil dan dependensi pertama akan terinstalasi dengan sempurna.

### 2. Instalasi Paket `libgl1-mesa-glx`

Untuk dependensi kedua, diperlukan instalasi manual melalui paket DEB. Unduh paket yang sesuai dari:

[Situs Paket Debian - libgl1-mesa-glx](https://packages.debian.org/bookworm/amd64/libgl1-mesa-glx/download)

- Pilih arsitektur yang sesuai dengan sistem
- Klik salah satu mirror untuk mengunduh file berekstensi `.deb`

### 3. Instalasi Paket yang Diunduh

Setelah proses unduh selesai, jalankan perintah berikut melalui terminal (ganti `dependency_name.deb` dengan nama file yang sebenarnya):

```bash
sudo dpkg -i dependency_name.deb
```

Alternatif lain, pengguna dapat menggunakan package manager untuk melakukan instalasi.

### 4. Instalasi Cisco Packet Tracer

Setelah semua dependensi terpenuhi, lakukan instalasi Cisco Packet Tracer dengan perintah (ganti `packet_tracer.deb` dengan nama file instalasi yang sesuai):

```bash
sudo dpkg -i packet_tracer.deb
```

Dengan mengikuti langkah-langkah di atas, proses instalasi Cisco Packet Tracer pada Kali Linux diharapkan dapat berjalan dengan lancar. Dokumen ini diharapkan dapat menjadi referensi bagi pengguna yang mengalami permasalahan serupa.

> Beberapa versi Kali Linux mungkin memerlukan penanganan dependensi tambahan tergantung konfigurasi sistem.
{: .prompt-info}