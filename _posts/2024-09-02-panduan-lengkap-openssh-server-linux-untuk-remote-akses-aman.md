---
title: Panduan Lengkap OpenSSH Server Linux untuk Remote Akses Aman
description: Pelajari instalasi OpenSSH Server, konfigurasi SSH key authentication, transfer file dengan SCP, SSH tunneling, dan perintah dasar SSH untuk administrasi server jarak jauh yang aman dengan enkripsi kriptografi.
categories: [Cybersecurity, Cryptography] 
tags: [cryptography, ssh]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
[Secure Shell (SSH)](https://id.wikipedia.org/wiki/Secure_Shell) adalah protokol kriptografi yang menyediakan komunikasi data terenkripsi, akses command-line interface (CLI) yang aman, eksekusi perintah jarak jauh, dan berbagai layanan jaringan lainnya antara dua host. Protokol ini menghubungkan server dan klien melalui saluran terenkripsi, baik dalam jaringan terpercaya maupun tidak terpercaya, dengan komponen server SSH dan klien SSH yang berjalan pada masing-masing endpoint.

## Instalasi OpenSSH Server
Lakukan instalasi OpenSSH Server dengan memperbarui repositori sistem dan menginstal paket yang diperlukan:
```bash
sudo apt update && sudo apt install openssh-server
```

Verifikasi status layanan SSH setelah instalasi:
```bash
sudo systemctl status ssh
```

Jika layanan belum aktif, jalankan perintah:
```bash
sudo systemctl start ssh
```

Aktifkan layanan SSH untuk berjalan secara otomatis pada proses boot:
```bash
sudo systemctl enable ssh
```

## Perintah SSH Umum
### Koneksi ke Server
Gunakan sintaks berikut untuk membangun koneksi SSH:
```bash
ssh username@hostname
```
> - `username`: Akun pengguna pada server target
- `hostname`: Alamat IP atau nama domain server
{: .prompt-info}

### Koneksi dengan Port Kustom
Untuk koneksi melalui port non-default:
```bash
ssh -p <port_number> username@hostname
```

### Autentikasi dengan Kunci SSH
Gunakan kunci privat SSH untuk autentikasi:
```bash
ssh -i ~/.ssh/id_rsa username@hostname
```

### Transfer File dengan SCP
- **Upload file** ke server:
```bash
scp ~/Documents/file.txt username@hostname:/home/user/
```

- **Download file** dari server:
```bash
scp username@hostname:/path/to/remote_file /path/to/local_directory
```

- **Transfer direktori** rekursif:
```bash
scp -r ~/Documents/Projects username@hostname:/home/user/
```

### Eksekusi Perintah Jarak Jauh
Jalankan perintah pada server remote tanpa membuka sesi interaktif:
```bash
ssh username@hostname 'ls -la /home/rical'
```

### SSH Tunneling
Membuat terowongan aman untuk mengakses layanan server melalui port lokal:
```bash
ssh -L local_port:remote_host:remote_port username@hostname
```
> - `local_port`: Port pada mesin lokal
- `remote_host`: Destinasi server target
- `remote_port`: Port layanan pada server remote
{: .prompt-info}

Contoh implementasi port forwarding:
```bash
ssh -L 8080:localhost:80 username@hostname
```
Perintah di atas akan meneruskan koneksi lokal port 8080 ke port 80 pada server remote.

### Manajemen Kunci dengan SSH Agent
Tambahkan kunci privat ke SSH agent:
```bash
ssh-add ~/.ssh/id_rsa
```

### Akses Remote melalui Codium
Pastikan ekstensi **Remote-SSH** terinstal pada Codium.

1. Buka **Command Palette** (`Ctrl + Shift + P`)
2. Ketik `Remote-SSH: Connect to Host...`
3. Masukkan kredensial akses server