---
title: Membuat NAT Router Menggunakan ESP32-DevKitC-V4
description: Mempelajari cara mengonfigurasi NAT router menggunakan ESP32-DevKitC-V4 untuk menyediakan koneksi internet yang aman dan efisien.
categories: [no categories]
tags: [microcontroller]
author: rical
last_modified_at: 2026-06-01
---

## Gambaran Umum
Dokumentasi ini menjelaskan langkah-langkah untuk mengonfigurasi dan menggunakan [ESP32-DevKitC-V4](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32/esp32-devkitc/user_guide.html) sebagai NAT *router*. Proses ini mencakup instalasi perangkat lunak yang diperlukan, *flashing firmware*, dan konfigurasi jaringan untuk menyediakan koneksi internet yang aman dan efisien.

## Instalasi esptool
Sebelum memulai, disarankan untuk menggunakan lingkungan [virtual Python (venv)](https://docs.ricalnet.my.id/posts/python-virtual-environment/) untuk mengelola dependensi. Langkah-langkah instalasi **esptool** adalah sebagai berikut:

1. Instal pyserial dengan perintah:
   ```bash
   pip install pyserial
   ```

2. Clone repositori esptool dari GitHub:
   ```bash
   git clone https://github.com/espressif/esptool && cd esptool
   ```

3. Instal esptool dengan menjalankan:
   ```bash
   python3 setup.py install
   ```

## Instalasi ESP32_NAT_Router
Untuk menginstal ESP32_NAT_Router, lakukan langkah-langkah berikut:

1. Clone repositori ESP32_NAT_Router:
   ```bash
   git clone https://github.com/martin-ger/esp32_nat_router.git
   ```

2. Masuk ke direktori repositori:
   ```bash
   cd esp32_nat_router
   ```

### Flashing
Untuk melakukan *flashing* pada *board* ESP32-DevKitC-V4, ikuti langkah-langkah berikut:

1. Masuk ke *download mode* dengan menahan tombol `Boot` dan menekan tombol `en`.
2. Jalankan perintah berikut di terminal:
   ```bash
   esptool.py --chip esp32 --port /dev/ttyUSB0 \
   --before default_reset --after hard_reset write_flash \
   -z --flash_mode dio --flash_freq 40m --flash_size detect \
   0x1000 build/esp32/bootloader.bin \
   0x8000 build/esp32/partitions.bin \
   0x10000 build/esp32/firmware.bin
   ```

> Sesuaikan parameter `--chip` dan `--port` sesuai dengan konfigurasi perangkat. Untuk informasi lebih lanjut, lihat dokumentasi resmi [Espressif](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/api-guides/usb-serial-jtag-console.html#uploading-the-application).
{: .prompt-tip}

### Konfigurasi ESP32_NAT_Router
Setelah *flashing* selesai, lakukan konfigurasi sebagai berikut:

1. Sambungkan ke jaringan Wi-Fi yang bernama **ESP32_NAT_Router**.
2. Akses antarmuka web *router* melalui alamat `http://192.168.4.1`.
3. Pada bagian **STA Settings (uplink Wi-Fi network)**, masukkan informasi jaringan Wi-Fi yang ingin digunakan beserta kata sandinya, kemudian klik **Connect**.
4. Di bagian **AP Settings**, masukkan nama **SSID** dan biarkan kolom **Password** kosong.

Setelah konfigurasi, lakukan pengujian koneksi dengan perintah:
```bash
ping 8.8.8.8
```
Jika `ping` berhasil, maka ESP32 telah berhasil dikonfigurasi untuk mengakses internet.

## Uji Coba Keamanan
Setelah konfigurasi selesai, lakukan uji coba untuk memastikan keamanan dan kinerja NAT router yang telah dibuat. Salah satu cara untuk melakukan pengujian ini adalah dengan menggunakan [Wireshark](https://www.wireshark.org/), sebuah alat analisis jaringan yang memungkinkan pengguna untuk menangkap dan menganalisis paket data yang melintasi jaringan.

## Referensi
- [YouTube: Build a Hackable Router with a $5 ESP32](https://www.youtube.com/watch?v=41Lymi6rXA8)