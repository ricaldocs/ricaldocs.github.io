---
title: Panduan Konfigurasi PlatformIO untuk ESP32 dengan Sensor Ultrasonik HC-SR04
description: Tutorial implementasi sistem pengukur tinggi badan anak menggunakan ESP32 dan sensor ultrasonik dengan PlatformIO. Pelajari konfigurasi lingkungan, filter data, kalibrasi, dan deployment firmware secara profesional.
categories: [no categories]
tags: [internet of things, platformio, microcontroller]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Dokumentasi ini menjelaskan implementasi sistem pengukur tinggi badan anak menggunakan ESP32 DevKitC v4 dan sensor ultrasonik HC-SR04. Sistem ini menggunakan filter moving average dan median untuk stabilisasi data, dilengkapi dengan validasi, kalibrasi, dan output JSON untuk integrasi sistem.

## 1. Persiapan Lingkungan Pengembangan

### 1.1 Membuat Virtual Environment Python

Virtual environment Python memastikan isolasi dependensi proyek untuk menghindari konflik versi package.

```bash
python3 -m venv venv
```

### 1.2 Mengaktifkan Virtual Environment

Aktifkan environment sebelum menjalankan perintah PlatformIO:

```bash
source venv/bin/activate
```

### 1.3 Instalasi PlatformIO

PlatformIO adalah framework cross-platform untuk pengembangan embedded systems dan IoT.

```bash
pip install platformio
```

## 2. Inisialisasi Proyek ESP32

### 2.1 Membuat Direktori Proyek

```bash
mkdir sok-anak-hw && cd sok-anak-hw
```

### 2.2 Inisialisasi PlatformIO untuk ESP32

```bash
pio init --board esp32dev
```

Perintah ini menghasilkan struktur proyek:
- `platformio.ini` - File konfigurasi utama
- `src/` - Direktori source code
- `lib/` - Library eksternal
- `include/` - Header files (opsional)
- `test/` - Unit tests (opsional)

## 3. Struktur Proyek PlatformIO

```
sok-anak-hw
├── include
│   └── README
├── lib
│   └── README
├── platformio.ini
├── src
│   └── main.cpp
└── test
    └── README
```

## 4. Spesifikasi Hardware

| Komponen             | Spesifikasi        |
| -------------------- | ------------------ |
| **Board**            | ESP32 DevKitC v4   |
| **MCU**              | ESP32-WROOM-32     |
| **Sensor**           | HC-SR04 Ultrasonic |
| **Pin Trigger**      | GPIO23             |
| **Pin Echo**         | GPIO22             |
| **Tombol Kalibrasi** | GPIO19             |
| **LED Status**       | GPIO2 (onboard)    |

## 5. Implementasi Kode Sensor Ultrasonik

### 5.1 Membuat File Source Utama

```bash
nano src/main.cpp
```

### 5.2 Kode Program Lengkap

[main.cpp](https://github.com/Sok-Anak/sok-anak-hw/blob/main/ultrasonic/src/main.cpp)

## 6. Build dan Upload Program

### 6.1 Clean Build Project

```bash
pio run --target clean
```

### 6.2 Build dan Upload Project

```bash
pio run --target upload
```

PlatformIO akan otomatis:
1. Mengunduh dependensi yang diperlukan
2. Mengompilasi source code
3. Mengupload firmware ke ESP32

## 7. Troubleshooting Upload

### 7.1 Identifikasi Port Serial

```bash
ls /dev/ttyUSB*
```

### 7.2 Upload dengan Port Spesifik

```bash
pio run --target upload --upload-port /dev/ttyUSB0
```

## 8. Serial Monitoring

### 8.1 Membuka Serial Monitor

```bash
pio device monitor
```

### 8.2 Serial Monitor dengan Baudrate Khusus

```bash
pio device monitor -b 115200
```

## 9. Mode Download untuk ESP32 DevKitC v4

### Prosedur Masuk Mode Download Manual:

1. **Tahan tombol BOOT** pada ESP32
2. **Tekan dan lepas tombol EN** (reset)
3. **Lepas tombol BOOT**

> ESP32 DevKitC v4 memerlukan prosedur ini karena tidak memiliki auto-reset circuit untuk programming.
{: .prompt-info}

## 10. Dependencies dan Library

Proyek ini menggunakan [library berikut](https://github.com/Sok-Anak/sok-anak-hw/blob/main/ultrasonic/platformio.ini).

## Kesimpulan

Dokumentasi ini memberikan panduan lengkap untuk mengembangkan sistem pengukur tinggi badan berbasis ESP32 dengan PlatformIO. Implementasi mencakup filter data, sistem kalibrasi, validasi, dan output multiple format. PlatformIO menyederhanakan workflow development dengan manajemen dependensi otomatis dan toolchain terintegrasi.