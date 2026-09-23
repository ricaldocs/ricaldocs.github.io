---
title: Memperbaiki Masalah Driver Adaptor WiFi USB Archer T2U V3 pada Kali Linux
description: Panduan mengatasi masalah driver adaptor WiFi USB TP-Link Archer T2U V3 pada sistem Kali Linux. Meliputi identifikasi dan penghapusan driver lama yang bermasalah, instalasi driver terbaru dari repositori GitHub, proses restart sistem, verifikasi fungsionalitas, serta troubleshooting lanjutan untuk memastikan kompatibilitas perangkat keras dan perangkat lunak.
categories: 
tags: [linux, adaptor wifi]
author: rical
last_modified_at: 2026-06-01
---

## Prasyarat

- Sistem Kali Linux dengan akses internet (melalui koneksi alternatif)
- Hak akses administratif (sudo)
- Kemampuan dasar menggunakan terminal

## Langkah 1: Menghapus Driver Lama yang Bermasalah

Langkah awal pemecahan masalah melibatkan identifikasi dan penghapusan driver yang tidak kompatibel atau bermasalah.

1. **Periksa Driver yang Terinstal Saat Ini:**

   Gunakan perintah berikut untuk memeriksa driver yang terinstal:

   ```bash
   sudo dkms status
   ```

2. **Hapus Driver yang Bermasalah:**

   Setelah mengidentifikasi driver yang bermasalah, hapus dengan mengganti `old-driver-name` dengan pengenal driver yang sesuai:

   ```bash
   sudo dkms remove -m old-driver-name --all
   ```

## Langkah 2: Menginstal Driver yang Diperbarui

Setelah menghapus driver lama, lanjutkan dengan menginstal driver yang diperbarui yang menyediakan dukungan tepat untuk adaptor WiFi.

1. **Kloning Repositori Driver:**

   Jalankan perintah berikut untuk mengkloning repositori driver yang diperlukan:

   ```bash
   git clone https://github.com/morrownr/8821au-20210708.git
   ```

2. **Masuk ke Direktori Repositori:**

   Pindah ke direktori repositori yang telah dikloning:

   ```bash
   cd 8821au-20210708
   ```

3. **Jalankan Instalasi Driver:**

   Jalankan skrip instalasi dengan hak akses tinggi:

   ```bash
   sudo ./install-driver.sh
   ```

   > Selama proses instalasi, Anda mungkin diminta untuk memodifikasi pengaturan konfigurasi. Disarankan untuk mempertahankan konfigurasi default kecuali diperlukan kustomisasi tertentu. Sistem akan membutuhkan reboot setelah instalasi berhasil diselesaikan.
   {: .prompt-info}

## Langkah 3: Restart Sistem

Setelah menyelesaikan instalasi driver, restart sistem untuk menerapkan semua perubahan:

```bash
sudo reboot
```

## Verifikasi

Setelah sistem restart, verifikasi fungsionalitas adaptor menggunakan:

```bash
iwconfig
# atau
sudo dkms status
```

## Pemecahan Masalah Lanjutan

Jika masalah masih berlanjut setelah mengikuti langkah-langkah ini, pertimbangkan:

- Memastikan adaptor terhubung dengan benar ke port USB
- Memeriksa masalah kompatibilitas perangkat keras
- Memverifikasi kompatibilitas versi kernel
- Berkonsultasi dengan [Forum Komunitas Kali Linux](https://forums.kali.org/) untuk dukungan tambahan
