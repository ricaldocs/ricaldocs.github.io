---
title: Menerapkan 2FA dengan USB Flash Drive Menggunakan pam_usb di Linux
description: Panduan teknis lengkap implementasi two-factor authentication menggunakan USB flash drive sebagai token hardware dengan PAM (Pluggable Authentication Modules) di Linux. Mencakup instalasi, konfigurasi, mode autentikasi, dan pertimbangan keamanan kritis untuk lingkungan produksi.
categories: [Cybersecurity, Privacy]
tags: [pam_usb, usb drive, privacy, linux]
author: rical
last_modified_at: 2026-07-23
---

## Pendahuluan

Ancaman siber semakin canggih, mengandalkan password saja sebagai satu-satunya lapisan keamanan sudah tidak lagi cukup. Serangan phishing, keylogger, dan credential stuffing terus meningkat. Di sinilah konsep two-factor authentication (2FA) menjadi sangat relevan.

`pam_usb` adalah modul PAM (Pluggable Authentication Modules) yang memungkinkan kita menggunakan USB flash drive biasa sebagai token autentikasi hardware. Dengan pendekatan ini, akses ke sistem Linux tidak hanya bergantung pada sesuatu yang diketahui (password), tetapi juga sesuatu yang dimiliki (USB flash drive fisik), menciptakan lapisan keamanan yang jauh lebih kuat.

### Mengapa Pendekatan Ini Penting untuk Keamanan?

1. Meskipun password pengguna berhasil dicuri, penyerang tetap tidak bisa mengakses sistem tanpa memiliki flash drive fisik yang sudah terdaftar.
2. Secara default, `pam_usb` menggunakan sistem one-time pad. Setiap kali autentikasi berhasil, kunci di dalam flash drive diperbarui, sehingga data yang sama tidak pernah digunakan dua kali. Ini membuat serangan replay attack menjadi tidak efektif.
3. Memerlukan keberadaan perangkat fisik, sehingga menambah dimensi keamanan yang tidak bisa dieksploitasi secara jarak jauh melalui serangan siber biasa.

### Peringatan Keamanan Kritis (Wajib Dibaca)

Sebelum melanjutkan, penting untuk menyadari beberapa risiko keamanan yang terkait dengan implementasi ini:

1. Jika flash drive jatuh ke tangan yang salah dan Anda menggunakan mode autentikasi tanpa password, maka siapa pun yang memiliki drive tersebut bisa mengakses sistem Anda. Selalu pertimbangkan untuk menggunakan mode 2FA penuh (password + token).
2. Beberapa versi `pam_usb` di bawah 0.9.0 memiliki kerentanan yang diketahui, termasuk [CVE-2026-47274](https://nvd.nist.gov/vuln/detail/CVE-2026-47274) terkait Uncontrolled Search Path dan [CVE-2026-44712](https://nvd.nist.gov/vuln/detail/CVE-2026-44712) terkait Command Injection. **Pastikan Anda menggunakan versi terbaru untuk menghindari eksploitasi ini.**
3. Saat konfigurasi, sistem akan menawarkan opsi untuk menambahkan pengguna ke grup `input`. **Hindari ini jika memungkinkan**, karena memberikan akses baca ke semua perangkat input (termasuk keyboard), yang secara efektif setara dengan kemampuan keylogger. Gunakan metode alternatif yang direkomendasikan jika tersedia.

## Prasyarat

Sebelum memulai, pastikan Anda memiliki:

- Sistem Linux dengan hak akses root atau `sudo`.
- Flash drive USB yang akan dijadikan token (kosongkan atau backup datanya terlebih dahulu).
- Koneksi internet untuk mengunduh dependensi dan kode sumber.
- Versi `pam_usb` terbaru untuk memastikan patch keamanan terbaru terpasang.

## Instalasi

Proses instalasi `pam_usb` saat ini lebih baik dilakukan melalui kompilasi dari sumber, karena tidak semua repositori distribusi menyediakan paket terbaru.

### 1. Instal Dependensi

Pertama, instal paket-paket yang diperlukan untuk proses kompilasi. Perintah di bawah ini untuk distribusi berbasis Debian/Ubuntu:

```bash
sudo apt install libxml2-dev libpam0g-dev libudisks2-dev libglib2.0-dev libevdev-dev pkg-config gir1.2-udisks-2.0 python3 python3-gi
```

Untuk distribusi berbasis Red Hat/Fedora, gunakan:

```bash
sudo dnf install libxml2-devel pam-devel libudisks2-devel glib2-devel libevdev-devel python3-gobject
```

### 2. Kompilasi dan Instalasi `pam_usb`

```bash
git clone https://github.com/mcdope/pam_usb.git
cd pam_usb
make
sudo make install
```

> Perintah `make install` akan menyalin modul PAM ke direktori yang sesuai dan membuat file konfigurasi di `/etc/security/pam_usb.conf`{: .filepath}.
{: .prompt-info}

## Konfigurasi Dasar

### 1. Menambahkan Perangkat USB

Hubungkan flash drive ke komputer, lalu jalankan perintah berikut untuk mendaftarkannya:

```bash
sudo pamusb-conf --add-device [YOUR_DEVICE_NAME]
```

> Ganti `[YOUR_DEVICE_NAME]` dengan nama yang Anda inginkan, misalnya `my-key` atau `security-token`.
{: .prompt-tip}

Sistem akan mendeteksi perangkat yang terhubung dan menampilkan daftar. Pilih nomor yang sesuai dengan flash drive Anda (contoh output):

```
Please select the device you wish to add.
1)  SK128 ([REDACTED])
2)  T-FORCE 256GB ([REDACTED])  
3) VendorCo ProductCode ([REDACTED]) <-- Pilih ini

3
[0-2]: Which volume would you like to use for storing data ?
* Using "/dev/sdb1 (UUID: [REDACTED])" (only option)

Name		: VendorCo ProductCode
Vendor		: [REDACTED]
Model		: [REDACTED]
Serial		: [REDACTED]
UUID		: [REDACTED]

Save to /etc/security/pam_usb.conf? [Y/n]
y
Done.
```

Perangkat ini akan menyimpan data one-time pad yang diperlukan untuk autentikasi.

### 2. Mendaftarkan Pengguna

Setelah perangkat terdaftar, daftarkan pengguna yang diizinkan untuk menggunakan token tersebut:

```bash
sudo pamusb-conf --add-user [YOUR_USERNAME]
```

```
Which device would you like to use for authentication ?
* Using "VendorCo ProductCode" (only option)

User		: [YOUR_USERNAME]
Device		: [YOUR_DEVICE_NAME]

Save to /etc/security/pam_usb.conf? [Y/n]
y
Done.
```

### 3. Verifikasi Konfigurasi

Sebelum mengaktifkan modul PAM, verifikasi bahwa semuanya berjalan dengan benar:

```bash
pamusb-check [YOUR_USERNAME]
```

Output yang diharapkan:

```
* Authentication request for user "[YOUR_USERNAME]" (pamusb-check)
* Searching for "[YOUR_DEVICE_NAME]" in the hardware database...
* Authentication device "[YOUR_DEVICE_NAME]]" is connected.
* Performing one time pad verification...
* Regenerating new pads...
* Access granted.
```

Jika muncul pesan `Access granted`, berarti konfigurasi dasar berhasil.

## Integrasi dengan PAM

Ini adalah langkah paling krusial. Pastikan untuk membuat backup sebelum mengubah file konfigurasi PAM. Kesalahan di sini bisa mengunci akses ke sistem Anda.

```bash
sudo cp /etc/pam.d/common-auth /etc/pam.d/common-auth.backup
```

### Memilih Mode Autentikasi

Ada tiga pendekatan utama yang bisa dipilih sesuai kebutuhan keamanan:

#### Mode 1: Two-Factor Authentication (Rekomendasi)

Mewajibkan kedua faktor: flash drive dan password. Ini adalah konfigurasi paling aman.

Edit `/etc/pam.d/common-auth`{: .filepath} dan letakkan konfigurasi ini di awal:

```
auth required pam_usb.so
auth required pam_unix.so nullok_secure
```

Dengan `required`, PAM akan memproses kedua modul. Autentikasi hanya berhasil jika keduanya lulus.

#### Mode 2: USB Sebagai Alternatif (Sufficient)

Flash drive saja sudah cukup. Jika token gagal, sistem akan meminta password.

```
auth sufficient pam_usb.so
auth required pam_unix.so nullok_secure
```

Mode ini menawarkan kenyamanan (tidak perlu mengetik password saat token terpasang), namun kurang aman karena token menjadi single point of failure.

#### Mode 3: Mode Tambahan (Additional)

Memerlukan token dan password, namun urutan pemrosesan berbeda. Cocok untuk skenario spesifik.

```
auth required pam_usb.so
auth required pam_unix.so nullok_secure
```

### Hasil Akhir Konfigurasi

Setelah diedit, file `/etc/pam.d/common-auth`{: .filepath} Anda akan terlihat seperti ini:

```
# /etc/pam.d/common-auth
# --- START OF CUSTOM AUTHENTICATION ---
auth    required                        pam_usb.so
# --- END OF CUSTOM AUTHENTICATION ---

auth    [success=1 default=ignore]      pam_unix.so nullok
auth    requisite                       pam_deny.so
auth    required                        pam_permit.so
```

## Troubleshooting Umum

### 1. `pamusb-check` Hanya Bekerja dengan `sudo`

Jika `pamusb-check` tidak bisa mengakses file di USB tanpa hak akses root, buat grup khusus dan berikan izin yang sesuai:

```bash
sudo groupadd pamusb
sudo usermod -aG pamusb [YOUR_USERNAME]
```

Kemudian, di direktori root USB, ubah kepemilikan:

```bash
sudo chown -R [YOUR_USERNAME]:pamusb .pamusb
sudo chmod -R g+rwx .pamusb
```

### 2. Aplikasi Tertentu Tidak Menggunakan `pam_usb`

Beberapa aplikasi (seperti `su`) mungkin memiliki file konfigurasi PAM terpisah. Jika Anda ingin `pam_usb` berlaku untuk aplikasi tersebut, tambahkan baris yang sama ke `/etc/pam.d/su`{: .filepath}.

### 3. Remote Desktop (RDP) Tidak Bekerja

`pam_usb` secara default memiliki deteksi untuk sesi remote. Jika Anda menggunakan RDP dan ingin tetap menggunakan token, pastikan konfigurasi `remote_desktop_check` sudah diatur dengan benar. Ikuti petunjuk yang muncul saat menjalankan `pamusb-conf --add-user`.

## Pertimbangan Keamanan Akhir

1. Untuk lingkungan produksi atau sistem yang menyimpan data sensitif, wajib menggunakan mode yang mewajibkan password dan token.
2. Kerentanan serius seperti [CVE-2026-44712](https://nvd.nist.gov/vuln/detail/CVE-2026-44712) (Command Injection) dan [CVE-2026-47274](https://nvd.nist.gov/vuln/detail/CVE-2026-47274) (PATH Manipulation) telah ditemukan pada versi sebelumnya. Selalu periksa dan gunakan versi terbaru.
3. Perlakukan flash drive ini seperti kunci fisik. Simpan di tempat aman dan pertimbangkan untuk memiliki backup token.
4. Selalu simpan backup file `/etc/pam.d/common-auth`{: .filepath} dan `/etc/security/pam_usb.conf`{: .filepath} di lokasi yang aman.

Dengan implementasi yang tepat, `pam_usb` memberikan peningkatan keamanan yang signifikan untuk sistem Linux Anda, menambah lapisan pertahanan yang sulit ditembus oleh penyerang jarak jauh maupun lokal.

## Referensi
- pam_usb: [Install](https://github.com/mcdope/pam_usb/wiki/Install)
- pam_usb: [GitHub Repository](https://github.com/mcdope/pam_usb)
