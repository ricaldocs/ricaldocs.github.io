---
title: Implementasi SSH Tunnel Aman Menggunakan Cloudflare Tunnel
description: Pelajari cara mengimplementasikan SSH Tunnel yang aman melalui Cloudflare Tunnel dengan panduan teknis langkah demi langkah. Dokumentasi ini mencakup konfigurasi DNS, SSH client, server hardening, dan troubleshooting.
categories: [Cloudflare]
tags: [cloud computing, linux, cloudflare, ssh]
author: rical
last_modified_at: 2026-06-01
---

## Pengantar

SSH Tunnel melalui Cloudflare Tunnel memberikan solusi koneksi SSH yang aman tanpa perlu membuka port firewall secara langsung ke internet. Dengan menggunakan Cloudflare sebagai perantara, koneksi SSH Anda terlindungi oleh infrastruktur global Cloudflare dan dapat diakses dari mana saja.

## Prasyarat

Sebelum memulai, pastikan Anda memiliki:
- Akun Cloudflare dengan domain terdaftar
- Cloudflared terinstal di server dan client
- Akses SSH ke server target
- Akses ke DNS management di Cloudflare

## 1. Konfigurasi DNS Records

Langkah pertama adalah mengarahkan subdomain Anda melalui Cloudflare Tunnel. Pastikan tunnel sudah dibuat sebelumnya melalui dashboard Cloudflare atau CLI.

```bash
cloudflared tunnel route dns <tunnel-id> ssh.domain.id
```

> Ganti `<tunnel-id>` dengan ID tunnel Anda yang sebenarnya, dan `ssh.domain.id` dengan subdomain yang ingin digunakan.
{: .prompt-tip}

## 2. Konfigurasi SSH Client

### 2.1 Instalasi Cloudflared
Pastikan Cloudflared terinstal di komputer client Anda. Untuk sistem berbasis [Debian/Ubuntu](https://docs.ricalnet.my.id/posts/panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/#instalasi-cloudflared).

### 2.2 Konfigurasi SSH Client
Edit file konfigurasi SSH di client Anda:

```bash
nano ~/.ssh/config
```

Tambahkan konfigurasi berikut:

```
Host ssh-domain
    HostName ssh.domain.id
    ProxyCommand cloudflared access ssh --hostname %h
    User your_username  # Ganti dengan username SSH Anda
    Port 22
    IdentityFile ~/.ssh/id_rsa  # Opsional: untuk autentikasi SSH key
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

**Penjelasan parameter:**
- `Host`: Alias untuk koneksi SSH
- `HostName`: Subdomain yang dikonfigurasi di Cloudflare
- `ProxyCommand`: Perintah untuk routing melalui Cloudflare Tunnel
- `User`: Username untuk login ke server
- `IdentityFile`: Path ke private key SSH (jika menggunakan SSH key)

### 2.3 Melakukan Koneksi
Setelah konfigurasi selesai, lakukan koneksi SSH dengan perintah:

```bash
ssh ssh-domain
```

## 3. Hardening SSH Server

Untuk meningkatkan keamanan server SSH, konfigurasikan file `/etc/ssh/sshd_config`:

### 3.1 Edit Konfigurasi SSH Server
```bash
sudo nano /etc/ssh/sshd_config
```

### 3.2 Rekomendasi Konfigurasi Keamanan
```config
# Disable password authentication (gunakan SSH key saja)
PasswordAuthentication no
ChallengeResponseAuthentication no

# Disable root login langsung
PermitRootLogin no

# Batasi user yang diizinkan login
AllowUsers your_username
AllowGroups ssh-users

# Limit login attempts
MaxAuthTries 3
MaxSessions 5
LoginGraceTime 60

# Protocol settings
Protocol 2
ClientAliveInterval 300
ClientAliveCountMax 2

# Key exchange algorithms
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256

# Ciphers
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com

# MACs
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```

### 3.3 Restart SSH Service
Setelah mengubah konfigurasi, restart service SSH:

```bash
sudo systemctl reload ssh
sudo systemctl restart sshd
sudo systemctl status ssh
```

## 4. Troubleshooting Komprehensif

### 4.1 Koneksi SSH Gagal

**Periksa status SSH service:**
```bash
sudo systemctl status ssh
sudo journalctl -u ssh -n 50 --no-pager
```

**Periksa firewall:**
```bash
sudo ufw status verbose
sudo ufw allow ssh
sudo ufw allow 22/tcp
```
### 4.3 Masalah DNS

**Cek DNS resolution:**
```bash
nslookup ssh.domain.id
dig ssh.domain.id
```

> Verifikasi di dashboard Cloudflare. Pastikan record A/AAAA atau CNAME sudah terkonfigurasi.
{: .prompt-info}

### 4.4 Debugging SSH Client

**SSH dengan output verbose:**
```bash
ssh -vvv ssh-domain
```

**Test tanpa config file:**
```bash
ssh -o "ProxyCommand=cloudflared access ssh --hostname ssh.domain.id" your_username@ssh.domain.id
```

## 5. Kesimpulan

Implementasi SSH Tunnel melalui Cloudflare Tunnel memberikan solusi koneksi SSH yang aman dan reliabel. Dengan mengikuti panduan ini, Anda dapat mengatur koneksi SSH yang terlindungi oleh infrastruktur Cloudflare, mengurangi exposure server langsung ke internet, dan meningkatkan keamanan keseluruhan.