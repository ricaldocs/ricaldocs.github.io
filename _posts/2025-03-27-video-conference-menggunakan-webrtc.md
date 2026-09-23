---
title: Video Conference Menggunakan WebRTC
description: Implementasi solusi konferensi video WebRTC pada server Ubuntu dengan eksposur jaringan melalui tunneling Ngrok untuk akses remote yang aman.
categories: [no categories]
tags: [telecommunications, webrtc, linux, ngrok]
author: rical
last_modified_at: 2026-06-01
---

## Gambaran Umum
WebRTC (Web Real-Time Communication) merupakan teknologi open-source yang memungkinkan komunikasi real-time untuk audio, video, dan pertukaran data secara peer-to-peer antar browser web tanpa memerlukan plugin tambahan. Dokumen ini menjelaskan implementasi konferensi video WebRTC menggunakan server Ubuntu dengan tunneling ngrok untuk akses eksternal.

## Prosedur Konfigurasi

### 1. Pengambilan Authtoken Ngrok
Akses [portal dashboard ngrok](https://dashboard.ngrok.com/) untuk memperoleh authtoken.

> Autentikasi token diperlukan untuk mengotorisasi sesi tunneling antara server lokal dan layanan ngrok cloud.
{: .prompt-info}

![Halaman Authtoken Ngrok](assets/img/posts/2025-03-27-video-conference-menggunakan-webrtc/ngrok-token.png)

### 2. Akses Remote ke Server Ubuntu
Lakukan koneksi SSH ke server Ubuntu menggunakan protokol Secure Shell:

```bash
ssh username@hostname
```

> **Referensi**: [Dokumentasi OpenSSH](https://docs.ricalnet.my.id/posts/panduan-lengkap-openssh-server-linux-untuk-remote-akses-aman/)

> Ganti placeholder `username` dan `hostname` dengan kredensial dan alamat server yang sesuai.
{: .prompt-tip}

![Antarmuka Login SSH](assets/img/posts/2025-03-27-video-conference-menggunakan-webrtc/ssh-login.png)

### 3. Pembaruan Repositori Sistem
Update indeks paket sistem untuk memastikan ketersediaan versi terbaru:

```bash
sudo apt update -y
```

> Pemeliharaan repositori secara berkala menjamin keamanan sistem dan akses ke pembaruan perangkat lunak terkini.
{: .prompt-tip}

### 4. Instalasi Snapd Package Manager
Lakukan instalasi snapd untuk manajemen paket aplikasi:

```bash
sudo apt install -y snapd
```

Instalasi komponen inti snap:
```bash
sudo snap install core
```

Instalasi ngrok via snap:
```bash
sudo snap install ngrok
```

> Snapd menyediakan lingkungan terisolasi untuk aplikasi dengan sistem update otomatis dan dependensi terkelola.
{: .prompt-info}

### 5. Kloning Repositori WebRTC
Ambil kode sumber aplikasi dari repository GitHub:

```bash
git clone https://github.com/ricalnet/WebRTC.git && cd WebRTC
```

> Proses kloning menyediakan akses ke kodebase implementasi WebRTC yang siap dijalankan.
{: .prompt-info}

### 6. Instalasi Node Package Manager
Pasang npm untuk manajemen dependensi JavaScript:

```bash
sudo apt install -y npm
```

> Jika muncul dialog konfigurasi, gunakan tombol Tab untuk navigasi dan pilih opsi `Ok`.
{: .prompt-tip}

> NPM berfungsi sebagai package manager utama dalam ekosistem Node.js untuk mengelola modul dan dependencies.
{: .prompt-info}

### 7. Konfigurasi Authtoken Ngrok
Integrasikan authtoken ke konfigurasi ngrok:

```bash
ngrok config add-authtoken $YOUR_AUTHTOKEN
```

Output konfigurasi:
```
Authtoken saved to configuration file: /home/ubuntu/snap/ngrok/260/.config/ngrok/ngrok.yml
```

> Penyimpanan authtoken mengaktifkan fitur tunneling aman dan layanan premium ngrok.
{: .prompt-info}

### 8. Instalasi Nodemon Development Tool
Pasang nodemon sebagai dev dependency:

```bash
npm install nodemon --save-dev
```

> Nodemon meningkatkan efisiensi development dengan automatic restart pada saat modifikasi kode terdeteksi.
{: .prompt-tip}

### 9. Eksekusi Aplikasi
Jalankan server development WebRTC:

```bash
npm run dev
```

> Perintah ini mengaktifkan server development pada port lokal untuk testing awal.
{: .prompt-info}

### 10. Konfigurasi Tunneling Ngrok
Buat tunnel akses publik ke server lokal:

```bash
ngrok http http://localhost:4300
```

> Tunnel ngrok menyediakan URL publik yang dapat diakses dari internet untuk keperluan testing dan demonstrasi.
![Antarmuka Forwarding Ngrok](assets/img/posts/2025-03-27-video-conference-menggunakan-webrtc/ngrok-forwarding.png)
![Halaman Web Ngrok](assets/img/posts/2025-03-27-video-conference-menggunakan-webrtc/ngrok-page.png)
{: .prompt-info}