---
title: Instalasi Scrcpy di Linux untuk Mirroring Layar Android Tanpa Root
description: Panduan lengkap instalasi Scrcpy di Linux untuk menampilkan dan mengendalikan perangkat Android dari PC melalui USB atau TCP/IP. Dilengkapi langkah-langkah instalasi ADB, dependensi, serta opsi tambahan seperti pengaturan bitrate dan resolusi layar.
categories: [Digital Independence, Android]
tags: [android, scrcpy]
author: rical
last_modified_at: 2026-06-01
---

Scrcpy bekerja dengan memanfaatkan [Android Debug Bridge](https://ricaldocs.github.io/posts/daftar-perintah-lengkap-adb-dan-fastboot/) (ADB) untuk mentransmisikan video dan audio dari perangkat Android ke komputer. Aplikasi ini mendukung berbagai fitur interaksi, termasuk pengendalian perangkat melalui keyboard dan mouse komputer, transfer file, serta pengaturan resolusi layar. Keunggulan utama Scrcpy terletak pada efisiensi sumber daya dan kompatibilitasnya dengan berbagai sistem operasi, termasuk Linux, Windows, dan macOS.

## Prasyarat

1. **Perangkat Android** dengan versi Android 5.0 atau lebih baru.
2. **Aktifkan Mode Pengembang** dan **USB Debugging** pada perangkat Android.
3. **Komputer** dengan sistem operasi Linux, Windows, atau macOS.
4. **Driver ADB** terinstal pada komputer.

## Instalasi pada Sistem Linux

### Langkah 1: Instal Android Debug Bridge (ADB)
```bash
sudo apt update && sudo apt install -y adb android-tools-adb android-tools-fastboot
```

### Langkah 2: Instal Dependensi Scrcpy
```bash
sudo apt install ffmpeg libsdl2-2.0-0 adb wget \
                 gcc git pkg-config meson ninja-build libsdl2-dev \
                 libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
                 libswresample-dev libusb-1.0-0 libusb-1.0-0-dev
```

### Langkah 3: Clone dan Instal Scrcpy dari Repository
```bash
git clone https://github.com/Genymobile/scrcpy && cd scrcpy
```

```bash
./install_release.sh
```

### Pembaruan dan Uninstall
- Untuk memperbarui ke versi terbaru:
  ```bash
  git pull
  ```

  ```bash
  ./install_release.sh
  ```

- Untuk menghapus instalasi:
  ```bash
  sudo ninja -Cbuild-auto uninstall
  ```

## Penggunaan

1. Hubungkan perangkat Android ke komputer menggunakan kabel USB.
2. Aktifkan **Transfer File** atau **PTP** pada notifikasi USB di perangkat.
3. Jalankan Scrcpy melalui terminal:
   ```bash
   scrcpy
   ```
4. Layar perangkat Android akan muncul di komputer, dan pengendalian dapat dilakukan menggunakan mouse dan keyboard.

## Opsi Tambahan

Scrcpy mendukung berbagai argumen command-line untuk menyesuaikan pengalaman penggunaan, seperti:
- `--bit-rate`: Mengatur kualitas bitrate video.
- `--max-size`: Membatasi resolusi tampilan.
- `--turn-screen-off`: Mematikan layar perangkat Android selama sesi.
- `--stay-awake`: Mencegah perangkat masuk ke mode tidur.

## Referensi

- [Repositori Resmi Scrcpy di GitHub](https://github.com/Genymobile/scrcpy)

## Lihat Juga

- [Praktik Terbaik Menjaga Privasi di Android](https://ricaldocs.github.io/posts/praktik-terbaik-menjaga-privasi-android/)
- [Panduan Instalasi MicroG di Android untuk Pemula dan Pengguna Advanced](https://ricaldocs.github.io/posts/panduan-instalasi-microg-di-android-untuk-pemula-dan-pengguna-advanced/)