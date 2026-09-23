---
title: Konfigurasi VNC dengan SSH Tunnel pada Raspberry Pi
description: Tutorial langkah demi langkah untuk mengakses desktop Raspberry Pi secara remote menggunakan VNC melalui SSH tunnel yang aman. Pelajari konfigurasi server, port forwarding, dan koneksi client dengan TigerVNC.
categories: [Cloud & On-Premise, Raspberry Pi]
tags: [raspberry pi, remote desktop, linux]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Remote desktop ke Raspberry Pi memungkinkan Anda mengontrol antarmuka grafis dari jarak jauh. Kombinasi **WayVNC** (VNC server) dan **SSH tunneling** memberikan solusi yang aman untuk akses remote melalui jaringan. Artikel ini akan memandu Anda melalui konfigurasi lengkap dari server hingga client.

### Prasyarat
- Raspberry Pi dengan Raspberry Pi OS terinstal
- Akses SSH ke Raspberry Pi
- Client dengan sistem operasi Linux

## 1. Konfigurasi Server (Raspberry Pi)

### 1.1 Aktifkan VNC Server

Masuk ke Raspberry Pi melalui SSH atau langsung, lalu jalankan:

```bash
sudo raspi-config
```

Navigasi melalui menu berikut:
1. Pilih **Interface Options**
2. Pilih **VNC**
3. Pilih **Yes** untuk mengaktifkan VNC

> Raspberry Pi OS menggunakan WayVNC sebagai server VNC default.
{: .prompt-info}

### 1.2 Verifikasi Status WayVNC

Setelah mengaktifkan, periksa status layanan VNC:

```bash
sudo systemctl status wayvnc
```

Output yang diharapkan:
```
● wayvnc.service - VNC Server
     Loaded: loaded (/usr/lib/systemd/system/wayvnc.service; enabled; preset: enabled)
     Active: active (running)
```

Jika status tidak aktif, mulai layanan dengan:
```bash
sudo systemctl start wayvnc && sudo systemctl enable wayvnc
```

### 1.3 Konfigurasi Firewall

Buka port VNC default (5900) di firewall UFW:

```bash
sudo ufw allow 5900/tcp && sudo ufw reload
```

Verifikasi aturan firewall:
```bash
sudo ufw status verbose
```

## 2. Konfigurasi Client (Komputer Lokal)

### 2.1 Instal TigerVNC Viewer

Update package list dan instal TigerVNC Viewer:

```bash
sudo apt update && sudo apt install -y tigervnc-viewer
```

### 2.2 Setup SSH Tunnel

#### Hentikan Tunnel yang Berjalan
Sebelum membuat tunnel baru, pastikan tidak ada tunnel yang konflik:

```bash
pkill -f "ssh.*5901:localhost:5900"
```

#### Buat SSH Tunnel
Jalankan perintah berikut untuk membuat secure tunnel:

```bash
ssh -L 5901:localhost:5900 username@<IP_ADDRESS> -C -N -v
```

**Penjelasan parameter:**
- `-L 5901:localhost:5900`: Forward port lokal 5901 ke port 5900 di server
- `username@<IP_ADDRESS>`: Username dan IP address Raspberry Pi
- `-C`: Kompresi data
- `-N`: Tidak menjalankan remote command
- `-v`: Verbose output (opsional, untuk debugging)

> Ganti `username` dan `<IP_ADDRESS>` dengan username dan IP Raspberry Pi Anda.
{: .prompt-tip}

### 2.3 Koneksi VNC

Di terminal baru (biarkan tunnel berjalan di terminal sebelumnya), hubungkan ke VNC:

```bash
vncviewer localhost:5901
```

### 2.4 Autentikasi

Setelah VNC Viewer terbuka:
1. Masukkan kredensial Raspberry Pi (username dan password)
2. Centang **Keep password for reconnect** jika diinginkan
3. Klik **OK**

![Tampilan Login VNC](assets/img/posts/2026-01-18-konfigurasi-vnc-dengan-ssh-tunnel-pada-raspberry-pi/contoh-tampilan-login-vnc.png)
_Contoh tampilan login VNC_

## 3. Troubleshooting

### 3.1 Tunnel Tidak Terbentuk
```
ssh: connect to host 192.168.100.32 port 22: Connection refused
```
**Solusi:**
- Pastikan SSH aktif di Raspberry Pi: `sudo systemctl status ssh`
- Verifikasi alamat IP yang benar

### 3.2 VNC Connection Failed
```
Unable to connect to VNC server
```
**Solusi:**
- Periksa apakah tunnel masih aktif
- Verifikasi WayVNC berjalan di Raspberry Pi
- Pastikan tidak ada firewall yang memblokir koneksi

### 3.3 Autentikasi Gagal
```
Authentication failure
```
**Solusi:**
- Pastikan username dan password benar
- Reset password Raspberry Pi jika perlu

## 4. Tips Keamanan

1. **Gunakan SSH Key Authentication** untuk koneksi SSH yang lebih aman
2. **Ubah port default** SSH dari 22 ke port lain
3. **Nonaktifkan VNC** ketika tidak digunakan
4. **Gunakan VPN** untuk koneksi dari jaringan eksternal

## 5. Komponen Alternatif

- **VNC Server Alternatif**: RealVNC, TightVNC
- **SSH Client Alternatif**: PuTTY (Windows), OpenSSH (macOS/Linux)
- **VNC Client Lain**: RealVNC Viewer, Remmina

## Kesimpulan

Konfigurasi VNC dengan SSH tunnel memberikan akses remote yang aman ke Raspberry Pi. Metode ini mengenkapsulasi lalu lintas VNC dalam koneksi SSH terenkripsi, melindungi data dari penyadapan. Dengan panduan ini, Anda dapat mengontrol Raspberry Pi secara grafis dari jarak jauh dengan keamanan optimal.