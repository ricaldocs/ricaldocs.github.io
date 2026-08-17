---
title: Cara Mengatur IP Statis di Raspberry Pi OS (Trixie) dengan NetworkManager
description: Panduan lengkap dan praktis untuk mengonfigurasi IP statis pada Raspberry Pi OS versi terbaru (Trixie dan yang lebih baru) yang menggunakan NetworkManager. Ikuti langkah-langkah mudah ini untuk koneksi ethernet maupun WiFi, lengkap dengan perintah verifikasi dan tips penting agar konfigurasi berjalan tanpa masalah.
categories: [Cloud & On-Premise, Raspberry Pi]
tags: [raspberry pi, linux, cloud computing]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Sejak rilis Raspberry Pi OS Bookworm, sistem operasi resmi Raspberry Pi beralih menggunakan `NetworkManager` sebagai pengelola jaringan default, menggantikan `dhcpcd` yang digunakan di versi sebelumnya. Perubahan ini membawa fleksibilitas lebih dalam mengelola koneksi, termasuk pengaturan IP statis yang dapat dilakukan melalui baris perintah atau GUI.

Artikel ini akan memandu Anda menetapkan IP statis pada Raspberry Pi menggunakan perintah `nmcli` (command-line tool dari NetworkManager). Metode ini berlaku untuk antarmuka ethernet (`eth0`) maupun WiFi (`wlan0`).

## Prasyarat

- Raspberry Pi dengan Raspberry Pi OS Trixie (atau versi lebih baru) yang sudah terinstal.
- Akses terminal (lokal atau SSH).
- Hak akses superuser (`sudo`).
- Mengetahui detail jaringan Anda:  
  - IP address yang diinginkan (misal: `192.168.0.50`)  
  - Gateway/router (misal: `192.168.0.1`)  
  - DNS server (misal: `192.168.0.1` dan `9.9.9.9`)  
  - Subnet mask dalam notasi CIDR (`/24` setara `255.255.255.0`)

## Langkah-Langkah Konfigurasi IP Statis

### 1. Cek Koneksi yang Tersedia

Pertama, identifikasi nama koneksi yang aktif atau akan dikonfigurasi. Gunakan perintah:

```bash
nmcli con show
```

Output akan menampilkan daftar koneksi. Perhatikan kolom `NAME` – Anda akan memerlukan nama persis ini untuk langkah berikutnya.  
Contoh output:
```
NAME                UUID                                  TYPE      DEVICE
Wired connection 1  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  ethernet  eth0
netplan-wlan0-SSID-WIFI-ANDA      xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  wifi      wlan0
```

> Nama koneksi bisa berbeda. Untuk ethernet biasanya "Wired connection 1", sedangkan WiFi menggunakan SSID jaringan Anda.
{: .prompt-info}

### 2. Set IP Statis untuk Ethernet

Jika Anda ingin mengatur IP statis pada koneksi ethernet (misal: "Wired connection 1"), jalankan perintah berikut:

```bash
sudo nmcli con mod "Wired connection 1" \
  ipv4.addresses 192.168.0.50/24 \
  ipv4.gateway 192.168.0.1 \
  ipv4.dns "192.168.0.1 9.9.9.9" \
  ipv4.method manual
```

Penjelasan parameter:
- `ipv4.addresses` : Alamat IP yang diinginkan beserta subnet mask (`/24` = 255.255.255.0).
- `ipv4.gateway` : Alamat gateway/router Anda.
- `ipv4.dns` : Server DNS (bisa lebih dari satu, dipisah spasi).
- `ipv4.method manual` : Mengubah metode dari DHCP (otomatis) menjadi manual (statis).

### 3. Set IP Statis untuk WiFi

Untuk koneksi WiFi, ganti `"Wired connection 1"` dengan nama SSID jaringan Anda. Contoh:

```bash
sudo nmcli con mod "SSID-WIFI-ANDA" \
  ipv4.addresses 192.168.0.50/24 \
  ipv4.gateway 192.168.0.1 \
  ipv4.dns "192.168.0.1 9.9.9.9" \
  ipv4.method manual
```

> Pastikan nama koneksi WiFi Anda ditulis persis seperti yang muncul di `nmcli con show`, termasuk tanda kutip jika mengandung spasi.
{: .prompt-info}

### 4. Restart NetworkManager

Setelah modifikasi, restart layanan NetworkManager agar perubahan diterapkan:

```bash
sudo systemctl restart NetworkManager
```

Koneksi akan terputus sesaat dan tersambung kembali dengan konfigurasi baru.

## Verifikasi Konfigurasi

Untuk memastikan IP statis telah berfungsi, lakukan pengecekan berikut:

### Cek Alamat IP

```bash
ip addr show
```

Perhatikan antarmuka yang dikonfigurasi (misal `eth0` atau `wlan0`). Pastikan `inet` menampilkan IP yang Anda tetapkan.

### Cek Tabel Routing

```bash
ip route show
```

Pastikan gateway default sudah sesuai dengan yang diatur.

### Uji Koneksi

```bash
ping 9.9.9.9
ping google.com
```

Kedua perintah di atas menguji koneksi ke internet (IP dan DNS). Jika keduanya berhasil, konfigurasi Anda sudah benar.

## Tips Penting

1. Pastikan IP statis yang Anda pilih berada di luar range DHCP router. Biasanya range DHCP dimulai dari `192.168.0.2` hingga `192.168.0.100` atau `192.168.0.200`. Gunakan IP di atas range tersebut, misal `192.168.0.50` (untuk `192.168.0.2`).

2. `/24` berarti subnet mask `255.255.255.0`. Jika jaringan Anda menggunakan subnet berbeda, sesuaikan angkanya (misal `/16` untuk `255.255.0.0`).

3. Gantilah nilai berikut sesuai dengan konfigurasi jaringan lokal:
   - `192.168.0.50` → IP yang diinginkan
   - `192.168.0.1` → Alamat gateway/router Anda
   - `192.168.0.1 9.9.9.9` → DNS server (bisa menggunakan DNS router atau publik)

4. Jika suatu saat ingin kembali ke DHCP, jalankan:
   ```bash
   sudo nmcli con mod "Wired connection 1" ipv4.method auto
   sudo systemctl restart NetworkManager
   ```

5. Jika Raspberry Pi Anda terhubung ke ethernet dan WiFi sekaligus, pastikan hanya satu antarmuka yang memiliki gateway default, atau atur metric routing untuk menghindari konflik.

## Kesimpulan

Dengan NetworkManager, pengaturan IP statis di Raspberry Pi OS menjadi lebih mudah dan terstruktur. Metode `nmcli` yang digunakan di atas memberikan kontrol penuh tanpa perlu mengedit file konfigurasi secara manual. Pastikan Anda selalu memverifikasi pengaturan dan menyesuaikan dengan topologi jaringan agar koneksi berjalan stabil.

Jika mengalami kendala, periksa kembali nama koneksi, parameter jaringan, atau restart NetworkManager. Selamat mencoba!