---
title: Overclocking Raspberry Pi 5
description: Tingkatkan kinerja Raspberry Pi 5 Anda melalui overclocking yang terukur. Artikel ini membahas setting config.txt, pemantauan suhu, pengujian stabilitas, dan cara memperbaiki jika terjadi crash atau overheating.
categories: [Cloud & On-Premise, Raspberry Pi]
tags: [raspberry pi]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

### 1.1 Latar Belakang

Overclocking adalah teknik meningkatkan frekuensi kerja komponen perangkat keras di atas spesifikasi pabrik untuk memperoleh peningkatan kinerja komputasi. Pada Raspberry Pi 5, overclocking dapat memberikan peningkatan kinerja hingga 25% untuk tugas-tugas yang membutuhkan komputasi intensif.

### 1.2 Ruang Lingkup

Dokumen ini mencakup prosedur overclocking untuk CPU (Central Processing Unit) dan GPU (Graphics Processing Unit) pada Raspberry Pi 5 menggunakan metode `over_voltage_delta` yang mempertahankan fitur Dynamic Voltage and Frequency Scaling (DVFS).

> Overclocking dilakukan sepenuhnya atas risiko pengguna. Konsekuensi yang mungkin terjadi meliputi:
- Peningkatan suhu operasional
- Potensi pengurangan umur komponen
- Ketidakstabilan sistem (crash, freeze, data corruption)
- Pembatalan garansi perangkat
{: .prompt-danger}

## Prasyarat Sistem

### 2.1 Persyaratan Perangkat Keras

| Komponen  | Spesifikasi Minimum                        | Rekomendasi                                       |
| :-------- | :----------------------------------------- | :------------------------------------------------ |
| Pendingin | Heatsink pasif                             | Active Cooler resmi Raspberry Pi                  |
| Catu Daya | 5V/3A (15W) USB-C                          | 5V/5A (27W) USB-C (Raspberry Pi 27W Power Supply) |
| Sistem    | Raspberry Pi 5 dengan kipas yang berfungsi | Dilengkapi thermal paste berkualitas              |

### 2.2 Persyaratan Perangkat Lunak

Pastikan sistem operasi dalam kondisi terbaru:
```bash
sudo apt update && sudo apt upgrade -y
```

Verifikasi model perangkat (harus mengembalikan "Raspberry Pi 5"):
```bash
cat /proc/device-tree/model
```

### 2.3 Peringatan Suhu Operasional

- Suhu normal idle: 40-50°C
- Suhu normal beban: 60-75°C
- Ambang batas throttling: 85°C (sistem mulai menurunkan kinerja)
- Ambang batas shutdown: 85°C+

> Pastikan suhu ruangan sejuk dan terdapat sirkulasi udara yang memadai di sekitar perangkat.
{: .prompt-tip}

## Target Overclocking

Tabel berikut menunjukkan target overclocking yang umumnya stabil untuk Raspberry Pi 5:

| Komponen                              | Frekuensi Default  | Target Overclock   | Keterangan       |
| :------------------------------------ | :----------------- | :----------------- | :--------------- |
| CPU Clock                             | 2.4 GHz (2400 MHz) | 3.0 GHz (3000 MHz) | Peningkatan ~25% |
| GPU Clock                             | 800 MHz            | 1.0 GHz (1000 MHz) | Peningkatan ~25% |
| Voltage offset (`over_voltage_delta`) | -                  | +50.000 µV         | Setara +0,05V    |

> Keberhasilan mencapai frekuensi 3.0 GHz bergantung pada kualitas individu chip (silicon lottery). Beberapa unit mungkin hanya stabil di 2,8 GHz atau 2,9 GHz.
{: .prompt-info}

## Prosedur Konfigurasi

### 4.1 Lokasi File Konfigurasi

Pada Raspberry Pi OS versi Trixie (2026 ke atas), file konfigurasi boot berada di:

```bash
/boot/firmware/config.txt
```

> Versi sebelumnya menggunakan `/boot/config.txt`{: .filepath}. Pastikan menggunakan path yang benar sesuai versi OS Anda.
{: .prompt-info}

### 4.2 Membuka File Konfigurasi

```bash
sudo nano /boot/firmware/config.txt
```

### 4.3 Konfigurasi Overclocking

Tambahkan blok konfigurasi berikut di bagian akhir file.

```
[all]
over_voltage_delta=50000
arm_freq=3000
gpu_freq=1000
```

### 4.4 Penjelasan Parameter

| Parameter | Nilai | Fungsi |
| :-------- | :---- | :----- ||
| `over_voltage_delta` | `50000` | Menambahkan offset voltase 50.000 µV (+0,05V) ke default. Metode ini mempertahankan DVFS sehingga voltase masih dapat turun saat idle. |
| `arm_freq`           | `3000`  | Menetapkan frekuensi maksimum CPU dalam MHz.                                                                                           |
| `gpu_freq`           | `1000`  | Menetapkan frekuensi maksimum GPU (dan V3D) dalam MHz.                                                                                 |

### 4.5 Menyimpan dan Keluar

1. Tekan `Ctrl + X` untuk keluar dari editor
2. Tekan `Y` untuk mengonfirmasi penyimpanan
3. Tekan `Enter` untuk mengonfirmasi nama file

### 4.6 Melakukan Reboot

```bash
sudo reboot
```

Sistem akan melakukan boot ulang dengan konfigurasi overclocking yang baru.

---

## Verifikasi dan Pengujian

### 5.1 Verifikasi Frekuensi Maksimum

Setelah sistem reboot, verifikasi bahwa overclocking berhasil diterapkan. Periksa frekuensi maksimum CPU (harus mengembalikan 3000000):
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq
```

Output yang diharapkan: `3000000` (3,0 GHz)

### 5.2 Verifikasi Frekuensi Aktual (Real-time)

Pantau frekuensi CPU saat ini (akan bervariasi sesuai beban):
```bash
watch -n 1 "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq"
```

Tekan `Ctrl + C` untuk keluar dari mode monitoring.

### 5.3 Memantau Suhu

Periksa suhu CPU saat ini:
```bash
vcgencmd measure_temp
```

Output contoh: `temp=52.3'C`

Pantau suhu secara real-time (setiap 2 detik):
```bash
watch -n 2 vcgencmd measure_temp
```

### 5.4 Pengujian Kestabilan dengan Stressberry

Stressberry adalah utility yang dirancang khusus untuk menguji stabilitas overclocking pada Raspberry Pi.

Install pip jika belum tersedia:
```bash
sudo apt install python3-pip -y
```

Install stressberry:
```
pip3 install stressberry
```

Jalankan stress test selama 10 menit (600 detik):
```bash
stressberry-run -d 600 overclock_test
```

Hasil pengujian disimpan sebagai `overclock_test.png`. Buka file tersebut untuk melihat grafik suhu dan frekuensi. Kriteria lulus uji:
- Tidak ada crash, freeze, atau reboot selama pengujian
- Suhu tidak melebihi 85°C (throttling terjadi di atas suhu ini)
- Tidak ada pesan error pada terminal

### 5.5 Metode Pengujian Alternatif

Uji dengan stress:
```bash
sudo apt install stress -y
stress --cpu 4 --timeout 300s && vcgencmd measure_temp
```

## Troubleshooting

### 6.1 Sistem Tidak Bisa Boot setelah Overclocking

**Gejala:** Raspberry Pi tidak menyala normal, lampu indikator berkedip tidak sesuai pola normal.

**Solusi:** Nonaktifkan overclocking dengan metode Safe Mode:
1. Cabut kabel power
2. Tekan dan tahan tombol Shift pada keyboard
3. Sambil menahan Shift, hubungkan kembali kabel power
4. Lepaskan Shift setelah LED berkedip
5. Sistem akan boot dengan konfigurasi default (tanpa overclocking)
6. Edit ulang `config.txt` untuk menurunkan frekuensi

### 6.2 Sistem Mengalami Freeze atau Crash saat Beban Berat

**Gejala:** Sistem tiba-tiba freeze, reboot sendiri, atau keluar error saat menjalankan aplikasi berat.

**Penyebab:** Frekuensi terlalu tinggi untuk chip tertentu, atau voltase kurang.

**Solusi:**

| Langkah | Tindakan                                                                                |
| :------ | :-------------------------------------------------------------------------------------- |
| 1       | Turunkan `arm_freq` menjadi `2900` (2,9 GHz)                                            |
| 2       | Jika masih tidak stabil, turunkan lagi menjadi `2800` (2,8 GHz)                         |
| 3       | Atau naikkan `over_voltage_delta` menjadi `55000` atau `60000` (hati-hati dengan panas) |

### 6.3 Suhu Terlalu Tinggi (Melebihi 85°C)

**Gejala:** Performa turun drastis, kipas bekerja sangat cepat, sistem mungkin mati sendiri.

**Solusi:**
- Pastikan menggunakan Active Cooler resmi Raspberry Pi
- Periksa apakah thermal paste masih baik
- Pastikan tidak ada yang menghalangi aliran udara
- Turunkan frekuensi CPU menjadi 2,8 GHz atau 2,7 GHz
- Pasang heatsink tambahan jika perlu

### 6.4 Overclock Tidak Berpengaruh (Frekuensi Masih Default)

**Gejala:** `cpuinfo_max_freq` masih menunjukkan 2400000.

**Solusi:**
- Periksa path file `config.txt` (`/boot/firmware/config.txt` vs `/boot/config.txt`)
- Pastikan tidak ada baris lain yang menimpa pengaturan (misalnya `[all]` di bawah `[pi5]`)
- Pastikan file tersimpan dengan benar sebelum reboot
- Cek apakah ada file `config.txt` duplikat di lokasi yang salah

## Referensi

### A. Parameter Overclocking Lengkap

| Parameter            | Rentang Nilai | Deskripsi                                            |
| :------------------- | :------------ | :--------------------------------------------------- |
| `arm_freq`           | 1500 - 3400   | Frekuensi CPU dalam MHz                              |
| `gpu_freq`           | 500 - 1100    | Frekuensi GPU dalam MHz                              |
| `over_voltage_delta` | 0 - 100000    | Offset voltase dalam µV (1.000 µV = 1 mV)            |
| `force_turbo`        | 0 atau 1      | 1 = memaksa frekuensi maksimum terus-menerus (panas) |

### B. Perbandingan Frekuensi

| Model          | Default CPU | Overclock Stabil | Default GPU | Overclock Stabil |
| :------------- | :---------- | :--------------- | :---------- | :--------------- |
| Raspberry Pi 4 | 1.5 GHz     | ~2.147 GHz       | 500 MHz     | ~750 MHz         |
| Raspberry Pi 5 | 2.4 GHz     | ~3.0 GHz         | 800 MHz     | ~1.0 GHz         |

### C. Sumber Daya Tambahan

- [Raspberry Pi 5 Datasheet](https://datasheets.raspberrypi.com/rpi5/raspberry-pi-5-product-brief.pdf)

