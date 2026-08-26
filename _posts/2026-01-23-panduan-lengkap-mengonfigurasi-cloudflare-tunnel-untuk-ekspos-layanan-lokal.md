---
title: Panduan Lengkap Mengonfigurasi Cloudflare Tunnel untuk Ekspos Layanan Lokal
description: Cloudflare Tunnel adalah solusi aman untuk mengekspos layanan lokal (seperti web server dan SSH) ke internet tanpa membuka port firewall. Artikel ini memberikan panduan langkah-demi-langkah mengonfigurasi tunnel dengan autentikasi berbasis sertifikat dan manajemen DNS terpusat.
categories: [Cloudflare]
tags: [cloud computing, linux, cloudflare]
author: rical
last_modified_at: 2026-06-01
---

## Prasyarat Konfigurasi

### 1. Persiapan Domain di Cloudflare
Pastikan domain Anda telah terdaftar di Cloudflare dengan status **Active** dan menggunakan nameserver Cloudflare. Verifikasi di dashboard Cloudflare untuk memastikan domain aktif sepenuhnya.

![Status Domain Cloudflare](assets/img/posts/2026-01-23-panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/image.png)

### 2. Kosongkan DNS Records
Hapus semua record DNS yang ada atau pastikan zona DNS dalam keadaan kosong sebelum memulai konfigurasi tunnel. Hal ini mencegah konflik antara record konvensional dan routing tunnel.

![Zona DNS Kosong](assets/img/posts/2026-01-23-panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/image-1.png)

## Instalasi Cloudflared

### Tambahkan Repositori dan Kunci GPG
Cloudflared merupakan CLI resmi Cloudflare untuk mengelola tunnel. Instalasi dimulai dengan menambahkan repositori paket resmi:

```bash
# Buat direktori keyrings dengan permission yang sesuai
sudo mkdir -p --mode=0755 /usr/share/keyrings

# Tambahkan kunci GPG Cloudflare
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

# Tambahkan repositori Cloudflared ke sources.list
echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
```

### Instalasi Paket
Update repositori dan instal cloudflared:

```bash
# Update package list dan instal cloudflared
sudo apt-get update && sudo apt-get install cloudflared -y
```

> Untuk sistem non-Debian/Ubuntu, kunjungi [dokumentasi resmi Cloudflare](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/create-local-tunnel/#1-download-and-install-cloudflared) untuk instruksi instalasi.
{: .prompt-info}

## Autentikasi dan Inisialisasi Tunnel

### 1. Login ke Akun Cloudflare
Autentikasi cloudflared dengan akun Cloudflare Anda:

```bash
cloudflared tunnel login
```

Perintah ini akan:
- Membuka browser otomatis ke halaman login Cloudflare
- Meminta izin untuk mengakses akun Anda
- Membuat file sertifikat `cert.pem` di `~/.cloudflared/`{: .filepath}

Jika browser tidak terbuka otomatis, salin URL yang ditampilkan ke browser manual.

![Halaman Otorisasi Tunnel](assets/img/posts/2026-01-23-panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/image-2.png)

Setelah berhasil login, output akan menampilkan lokasi penyimpanan sertifikat:
```
INF You have successfully logged in.
If you wish to copy your credentials to a server, they have been saved to:
/home/username/.cloudflared/cert.pem
```

### 2. Membuat Tunnel Baru
Buat tunnel dengan nama unik:

```bash
cloudflared tunnel create <NAME>
```

Contoh dengan nama `my-tunnel`:
```bash
cloudflared tunnel create my-tunnel
```

Output akan menampilkan ID tunnel dan lokasi file kredensial JSON:
```
Tunnel credentials written to /home/username/.cloudflared/XXX-XXX-XXX-XXX-XXX.json
Created tunnel my-tunnel with id XXX-XXX-XXX-XXX-XXX
```

> File JSON ini bersifat rahasia. Simpan dengan aman dan jangan bagikan.
{: .prompt-warning}

### 3. Verifikasi Tunnel yang Tersedia
Lihat daftar tunnel yang telah dibuat:

```bash
cloudflared tunnel list
```

## Konfigurasi Routing Tunnel

### 1. Buat File Konfigurasi
Buat atau edit file konfigurasi di `~/.cloudflared/config.yml`{: .filepath}:

```bash
nano ~/.cloudflared/config.yml
```

### 2. Konfigurasi YAML Template
Tambahkan konfigurasi berikut, sesuaikan dengan kebutuhan:

```yaml
# ID tunnel dari perintah 'tunnel create'
tunnel: UUID

# File kredensial yang dihasilkan
credentials-file: /home/username/.cloudflared/UUID.json

# Aturan routing ingress
ingress:
  # Route untuk web server (port 80)
  - hostname: your-domain.com
    service: http://localhost:80
  
  # Route untuk SSH (port 22)
  - hostname: ssh.your-domain.com
    service: ssh://localhost:22
  
  # Fallback rule untuk traffic tidak dikenali
  - service: http_status:404
```

**Penjelasan Konfigurasi:**
- `tunnel`: UUID tunnel dari output sebelumnya
- `credentials-file`: Path lengkap ke file kredensial JSON
- `ingress`: Daftar rule untuk meneruskan traffic
  - `hostname`: Subdomain atau domain tujuan
  - `service`: Protokol dan port layanan lokal
  - Rule terakhir adalah catch-all untuk menangani request tidak valid

## Routing DNS dan Aktivasi

### 1. Tambahkan Record DNS ke Tunnel
Hubungkan domain/subdomain dengan tunnel:

```bash
cloudflared tunnel route dns <UUID atau NAME> <hostname>
```

Contoh:
```bash
cloudflared tunnel route dns my-tunnel your-domain.com
```

Output konfirmasi:
```
INF Added CNAME your-domain-name which will route to this tunnel tunnelID=XXX-XXX-XXX-XXX-XXX
```

### 2. Jalankan Tunnel
Aktifkan tunnel dengan mode interaktif:

```bash
cloudflared tunnel run <UUID atau NAME>
```

### 3. Verifikasi Status Tunnel
Periksa informasi dan status tunnel:

```bash
cloudflared tunnel info <UUID atau NAME>
```

## Troubleshooting

### Troubleshooting Umum
1. **Tunnel tidak terkoneksi**: Periksa koneksi internet dan izin sertifikat
2. **DNS tidak resolve**: Verifikasi CNAME record di dashboard Cloudflare
3. **Service tidak terjangkau**: Pastikan layanan lokal berjalan di port yang sesuai

## Kesimpulan
Cloudflare Tunnel menawarkan solusi aman untuk mengekspos layanan lokal tanpa kompleksitas konfigurasi firewall tradisional. Dengan arsitektur zero-trust, tunnel ini ideal untuk remote access, development preview, dan hosting aplikasi internal.

## Referensi
- [Dokumentasi Resmi Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/create-local-tunnel/)
- [Komunitas Cloudflare](https://community.cloudflare.com/)

## Pranala Menarik

- [Implementasi SSH Tunnel Aman Menggunakan Cloudflare Tunnel](https://docs.ricalnet.my.id/posts/implementasi-ssh-tunnel-aman-menggunakan-cloudflare-tunnel/)