---
title: Bypass Xiaomi Bootloader Restrictions
description: Unlock bootloader HyperOS tanpa menggunakan Mi Community.
categories: [Digital Independence, Android]
tags: [android]
author: rical
last_modified_at: 2026-06-01
---

> Panduan ini menjelaskan cara membuka kunci *bootloader* HyperOS pada perangkat Xiaomi tanpa menggunakan Mi Community. Proses ini hanya berlaku untuk perangkat Xiaomi dengan versi global dan memerlukan sistem operasi Windows.
{: .prompt-info}

> File dan alat yang digunakan dalam panduan ini BUKAN dibuat oleh penulis, melainkan oleh beberapa pengembang yang kompeten. Penulis tidak bertanggung jawab atas segala kerusakan yang mungkin terjadi pada perangkat, termasuk tetapi tidak terbatas pada *brick*, kerusakan kartu SD, dan lain-lain.
{: .prompt-danger}

## Persyaratan
Sebelum memulai, silakan periksa [persyaratan pembukaan kunci](https://github.com/MlgmXyysd/Xiaomi-HyperOS-BootLoader-Bypass/#-Unlocking-requirements).

## Konfigurasi Pengaturan pada Perangkat Xiaomi
1. Buka aplikasi **Pengaturan** di ponsel Xiaomi.
2. Navigasikan ke: **My phone** > **OS version** dan ketuk beberapa kali hingga muncul pesan "you are a developer".
3. Masuk ke **Additional settings** > ** Developer Options**.
4. Di dalam ** Developer Options**, aktifkan opsi berikut:
   - **OEM Unlocking**
   - **USB Debugging**
   - **USB Debugging (Security Settings)**
5. Pastikan telah masuk dengan akun Xiaomi yang valid.

## Instalasi PHP
1. Unduh file PHP dari [tautan ini](/assets/posts/php.zip).
2. Ekstrak file tersebut ke direktori `C:\php`{: .filepath}.

## Instalasi Aplikasi Pengaturan
1. Unduh file [Settings.apk](https://drive.proton.me/urls/X4189HG8H0#XiHXwaww6p3k).
2. Instal aplikasi tersebut di perangkat menggunakan pengelola file.

## Eksekusi Proses Pembukaan Kunci
1. Hubungkan ponsel Anda ke PC menggunakan kabel USB.
2. Arahkan ke direktori `C:\php`{: .filepath} dan jalankan file `Bypass.cmd`.
3. Pada ponsel, centang opsi `always allow USB debugging from this computer` dan tekan OK.
4. Tunggu dan ikuti petunjuk yang diberikan oleh skrip.
5. Setelah proses `successful binding`, unduh [Official Unlock Tool](https://en.miui.com/unlock/index.html) dan lakukan proses pembukaan kunci *bootloader* seperti biasa.

Penulis berhasil membuka kunci *bootloader* perangkat Xiaomi tanpa menggunakan Mi Community dan tanpa waktu tunggu 168 jam.