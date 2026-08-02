---
title: Cara Install /e/OS di Xiaomi POCO F4 (munch)
description: Panduan teknis langkah-demi-langkah install /e/OS di POCO F4. Lengkap dengan prasyarat, update firmware, flashing recovery, dan sideload ROM untuk privasi maksimal.
categories: [Digital Independence, Android]
tags: [android]
author: rical
last_modified_at: 2026-07-23
---

## Pendahuluan

/e/OS adalah sistem operasi berbasis Android yang sepenuhnya open-source dan berfokus pada privasi pengguna. Dikembangkan oleh komunitas /e/ Foundation, OS ini hadir tanpa layanan Google (Google-free) dan menggantinya dengan aplikasi serta layanan dari ekosistem /e/Cloud. Dengan menghilangkan trackers dan memberikan kontrol penuh atas data pribadi, /e/OS menjadi pilihan ideal bagi pengguna yang menginginkan smartphone cerdas tanpa mengorbankan privasi mereka.

Dokumen ini menyediakan panduan teknis langkah-demi-langkah untuk melakukan instalasi sistem operasi /e/OS pada perangkat Xiaomi POCO F4 (dengan kode perangkat: `munch`). Prosedur ini mencakup pembaruan firmware perangkat serta pemasangan image sistem /e/OS. Instalasi ini bertujuan untuk menggantikan sistem operasi bawaan pabrik dengan /e/OS yang berfokus pada privasi dan keterbukaan.

> Proses ini akan menghapus semua data yang tersimpan di perangkat. Pastikan untuk melakukan pencadangan (backup) data pribadi Anda sebelum melanjutkan.
{: .prompt-warning}

## Prasyarat

Sebelum memulai instalasi, pastikan persyaratan berikut telah terpenuhi:

| **Kategori** | **Persyaratan** | | :------------------- | :--------------------------------------------------------------------------------------------------------------------------------- |
| Perangkat             | Xiaomi POCO F4 dengan status **bootloader tidak terkunci (unlocked)**.                                                           |
| Komputer              | Komputer dengan sistem operasi Windows, macOS, atau Linux. |
| Koneksi Internet      | Koneksi stabil untuk mengunduh berkas yang diperlukan. |
| Driver dan Alat Bantu | - Driver USB untuk perangkat Xiaomi/Android telah terinstal dengan benar di komputer.<br>- Alat platform-tools dari Android SDK (ADB dan Fastboot) telah tersedia dan dapat diakses melalui terminal atau command prompt di komputer Anda. |

## Unduh Berkas yang Diperlukan

1. **/e/OS Build:** [Unduh image sistem /e/OS untuk POCO F4](https://images.ecloud.global/community/munch). Carilah berkas dengan nama yang mengandung `community-munch`. Anda akan memerlukan:
  - Berkas `e-*.zip` (paket instalasi utama /e/OS).
  - Berkas `recovery-*.zip` (misalnya, `recovery-IMG-e-<version>-<android_version>-<date>-community-munch.zip`)

2. Unduh firmware resmi untuk POCO F4. Penggunaan firmware yang sesuai sangat penting untuk memastikan kompatibilitas perangkat keras.
  - **Perhatikan tipe perangkat Anda**
    - Untuk POCO F4 Global, disarankan untuk menggunakan Firmware versi **[OS1.0.2.0.ULMMIXM](https://cdnorg.d.miui.com/OS1.0.2.0.ULMMIXM/miui_MUNCHGlobal_OS1.0.2.0.ULMMIXM_9849ffd45c_14.0.zip)**.
    
      > Firmware dapat diperoleh dari sumber terpercaya seperti basis data firmware Xiaomi. Berkas yang diunduh biasanya bernama `miui_MUNCH...zip`.
      {: .prompt-tip}

## Prosedur Pembaruan Firmware

Langkah ini bertujuan untuk memastikan perangkat menjalankan versi firmware yang direkomendasikan sebelum menginstal /e/OS.

### 4.1 Mengekstrak Firmware

Gunakan alat `payload-dumper-go` untuk mengekstrak partisi firmware dari berkas ZIP Xiaomi.

1.  Unduh `payload-dumper-go` dari [halaman rilis resmi](https://github.com/ssut/payload-dumper-go/releases/latest).
2.  Ekstrak alat tersebut dan jalankan perintah berikut di terminal, gantilah `miui_*.zip` dengan nama berkas firmware yang telah diunduh:
    ```bash
    payload-dumper-go -o . miui_*.zip
    ```
    Perintah ini akan mengekstrak berkas-berkas `*.img` (seperti `abl.img`, `xbl.img`, dll.) ke direktori yang sama.
    
    > Direktori `/tmp`{: .filepath} kehabisan ruang saat menjalankan `payload-dumper-go`. Alihkan direktori temporary ke lokasi lain yang memiliki ruang cukup:
    ```bash
    export TMPDIR=$(pwd)
    ./payload-dumper-go -o . miui_*.zip
    ```
    {: .prompt-tip}

### 4.2 Memasang Firmware

1.  Matikan perangkat POCO F4.
2.  Boot perangkat ke mode `Fastboot` dengan menekan dan menahan tombol `Volume Bawah (-)` dan `Power` secara bersamaan hingga logo "FASTBOOT" muncul, lalu lepaskan kedua tombol. Hubungkan perangkat ke komputer menggunakan kabel USB.
3.  Buka terminal atau command prompt di komputer Anda dan navigasikan ke direktori yang berisi berkas-berkas `*.img` hasil ekstraksi firmware.
4.  Jalankan serangkaian perintah berikut satu per satu. Setiap perintah akan mem-flash partisi yang sesuai. Tunggu hingga setiap perintah selesai sebelum melanjutkan ke perintah berikutnya.

    ```bash
    fastboot flash abl_ab abl.img
    fastboot flash aop_ab aop.img
    fastboot flash bluetooth_ab bluetooth.img
    fastboot flash cmnlib_ab cmnlib.img
    fastboot flash cmnlib64_ab cmnlib64.img
    fastboot flash devcfg_ab devcfg.img
    fastboot flash dsp_ab dsp.img
    fastboot flash featenabler_ab featenabler.img
    fastboot flash hyp_ab hyp.img
    fastboot flash imagefv_ab imagefv.img
    fastboot flash keymaster_ab keymaster.img
    fastboot flash modem_ab modem.img
    fastboot flash qupfw_ab qupfw.img
    fastboot flash tz_ab tz.img
    fastboot flash uefisecapp_ab uefisecapp.img
    fastboot flash xbl_ab xbl.img
    fastboot flash xbl_config_ab xbl_config.img
    ```

    > Keberhasilan setiap perintah ditandai dengan keluaran `OKAY` di terminal.
    {: .prompt-info}

5.  Setelah semua partisi selesai di-flash, reboot perangkat untuk keluar dari mode fastboot.
    ```bash
    fastboot reboot
    ```
    Perangkat akan menyala normal. Anda dapat mematikannya kembali untuk melanjutkan ke proses instalasi /e/OS.

## Prosedur Instalasi /e/OS

### 5.1 Pemrograman Partisi melalui Fastboot

Tahap ini dilakukan dengan perangkat dalam mode Fastboot untuk memasang image `recovery` dan `vendor_boot` khusus dari /e/OS.

1.  Boot perangkat ke mode `Fastboot` seperti yang dijelaskan pada [langkah 4.2](https://ricaldocs.github.io/posts/eos/#42-memasang-firmware).
2.  Buka terminal di komputer dan navigasikan ke direktori yang berisi berkas-berkas image /e/OS yang telah diunduh.
3.  Lakukan pemuatan partisi `boot` dengan image `recovery`:
    ```bash
    fastboot flash boot recovery-e-...-community-munch.img
    ```
    > Gantilah `recovery-e-...img` dengan nama berkas recovery yang sebenarnya.
    {: .prompt-tip}

4.  Inisiasi ulang bootloader:
    ```bash
    fastboot reboot bootloader
    ```
5.  Lakukan pemuatan partisi `vendor_boot`:
    ```bash
    fastboot flash vendor_boot vendor_boot-e-...-community-munch.img
    ```
    > Gantilah `vendor_boot-e-...img` dengan nama berkas vendor_boot yang sebenarnya.
    {: .prompt-tip}

6.  Inisiasi ulang perangkat ke mode recovery yang baru saja di-flash:
    ```bash
    fastboot reboot recovery
    ```
    Perangkat akan boot dan menampilkan antarmuka **/e/OS Recovery**.

### 5.2 Instalasi melalui Antarmuka Recovery

#### 5.2.1 Inisialisasi Perangkat (Factory Reset)

Lakukan penghapusan data pabrik untuk memastikan instalasi yang bersih.

1.  Pada menu utama recovery, gunakan tombol volume untuk navigasi dan tombol daya untuk memilih.
2.  Pilih opsi `Factory reset`.
3.  Pilih opsi `Format data / Factory reset`.
4.  Konfirmasi dengan memilih `Format data`.
5.  Tunggu hingga proses selesai. Indikasi kemajuan akan terlihat di pojok kiri bawah layar. Setelah selesai, Anda akan kembali ke menu `Factory Reset`.

#### 5.2.2 Proses Sideload

1.  Dari menu utama recovery, pilih `Apply Update`.
2.  Pilih `Apply update from ADB`. Perangkat kini dalam mode sideload dan siap menerima berkas.
3.  Pada komputer, jalankan perintah berikut di terminal:
    ```bash
    adb -d sideload e-....zip
    ```
    > Gantilah `e-....zip` dengan nama lengkap berkas paket instalasi /e/OS yang telah diunduh).
    {: .prompt-tip}

4.  Proses pengiriman akan dimulai. Kemajuan akan terlihat di layar perangkat. Mohon ditunggu, proses mungkin terlihat berhenti sementara di angka tertentu (misalnya, 47%).
5.  Setelah selesai, terminal komputer akan menampilkan pesan `Total xfer: 1.00x`, dan layar perangkat akan menampilkan `Script succeeded result was [1.000000]`, yang menandakan instalasi berhasil.

## Verifikasi dan Inisialisasi Sistem

1.  Kembali ke menu utama recovery.
2.  Pilih opsi `Reboot system now`.
3.  Sistem akan melakukan inisialisasi ulang. Proses booting pertama kali dapat memakan waktu sekitar 5 hingga 10 menit. Harap bersabar.
4.  Setelah proses booting selesai, layar selamat datang (wizard) /e/OS akan tampil. Ikuti petunjuk di layar untuk melakukan konfigurasi awal perangkat.

**Keberhasilan:** Perangkat Anda kini telah berhasil melakukan booting ke sistem operasi /e/OS dan siap untuk digunakan.