---
title: Cara Instalasi Ghost CMS dengan Docker di Linux
description: Tutorial instalasi Ghost CMS dengan Docker di Linux. Panduan lengkap konfigurasi domain, SMTP email, database MySQL, dan reverse proxy Caddy untuk SSL otomatis.
categories: [Digital Independence, Publications]
tags: [self-hosted, docker, ghost-cms]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Ghost adalah sebuah platform penerbitan open source yang dirancang untuk membangun dan mengoperasikan situs web independen, seperti blog, majalah daring, dan jurnal. Platform ini ditulis dalam JavaScript dan menggunakan kerangka kerja Node.js. Ghost dikenal karena fokusnya pada pengalaman penulis serta kecepatan dan kesederhanaan dalam pengelolaan konten.

## Prasyarat Instalasi

Sebelum melakukan instalasi Ghost, pastikan sistem memenuhi persyaratan berikut:

- Server berbasis Linux dengan spesifikasi 2GB RAM/1 CPU.
- Docker versi 20.10.13 atau lebih tinggi telah terpasang (lihat: [Panduan Instalasi Docker](https://docs.docker.com/engine/install/)).
- Nama domain dengan DNS A-Record yang mengarah ke alamat IP server.
- Layanan email SMTP untuk transaksi surel.
- (Opsional) Akun [Tinybird](https://www.tinybird.co/) untuk analisis lalu lintas web.

## Panduan Instalasi

### 1. Mengkloning Repositori

Salin repositori Docker resmi Ghost ke direktori `/opt/ghost` dengan perintah:
```bash
git clone https://github.com/TryGhost/ghost-docker.git /opt/ghost && cd /opt/ghost
```

### 2. Konfigurasi

Salin berkas konfigurasi contoh untuk Ghost dan Caddy:
```bash
cp .env.example .env && cp caddy/Caddyfile.example caddy/Caddyfile
```

Edit berkas `.env` menggunakan editor teks (seperti `nano` atau `vim`) dan sesuaikan variabel berikut:
- `DOMAIN`: Ganti dengan domain utama situs Ghost (contoh: `mysite.com`).
- `ADMIN_DOMAIN`: (Opsional, direkomendasikan) Domain terpisah untuk panel admin (contoh: `admin.mysite.com`).
- `DATABASE_ROOT_PASSWORD`: Hasilkan kata sandi acak dengan `openssl rand -hex 32`.
- `DATABASE_PASSWORD`: Hasilkan kata sandi acak menggunakan `openssl rand -hex 32`.
- Bagian `SMTP Email`: Sesuaikan dengan konfigurasi layanan SMTP yang digunakan.

Contoh isi berkas untuk instalasi localhost:

```
# Use the below flags to enable the Analytics or ActivityPub containers as well
# COMPOSE_PROFILES=analytics,activitypub

# Ghost domain
# Custom public domain Ghost will run on
DOMAIN=localhost

# Ghost Admin domain
# If you have Ghost Admin setup on a separate domain uncomment the line below and add the domain
# You also need to uncomment the corresponding block in your Caddyfile
# ADMIN_DOMAIN=

# Database settings
# All database settings must not be changed once the database is initialised
DATABASE_ROOT_PASSWORD=changeme
# DATABASE_USER=optionalusername
DATABASE_PASSWORD=changeme

# ActivityPub
# If you'd prefer to self-host ActivityPub yourself uncomment the line below
# ACTIVITYPUB_TARGET=activitypub:8080

# Tinybird configuration
# If you want to run Analytics, paste the output from `docker compose run --rm tinybird-login get-tokens` below
# TINYBIRD_API_URL=https://api.tinybird.co
# TINYBIRD_TRACKER_TOKEN=p.eyJxxxxx
# TINYBIRD_ADMIN_TOKEN=p.eyJxxxxx
# TINYBIRD_WORKSPACE_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Ghost configuration (https://ghost.org/docs/config/)

# SMTP Email (https://ghost.org/docs/config/#mail)
# Transactional email is required for logins, account creation (staff invites), password resets and other features
# This is not related to bulk mail / newsletter sending
#mail__transport=SMTP
#mail__options__host=smtp.example.com
#mail__options__port=465
#mail__options__secure=true
#mail__options__auth__user=postmaster@example.com
#mail__options__auth__pass=1234567890

# Advanced customizations

# Force Ghost version
# You should only do this if you need to pin a specific version
# The update commands won't work
# GHOST_VERSION=6-alpine

# Port Ghost should listen on
# You should only need to edit this if you want to host
# multiple sites on the same server
# GHOST_PORT=2368

# Data locations
# Location to store uploaded data
UPLOAD_LOCATION=./data/ghost

# Location for database data
MYSQL_DATA_LOCATION=./data/mysql
```

### 3. Menjalankan Ghost

Jalankan perintah berikut untuk mengunduh image Docker dan menjalankan kontainer:
```bash
docker compose pull
```

```bash
docker compose up -d
```

Proses ini mungkin memerlukan waktu beberapa menit tergantung kecepatan jaringan.

### 4. Verifikasi Instalasi

Setelah instalasi selesai, buka peramban web dan akses domain yang telah dikonfigurasi. Untuk mengakses panel admin, tambahkan path `/ghost` pada domain utama (contoh: `https://mysite.com/ghost`) dan selesaikan proses penyiapan akun administrator.

## Konfigurasi Lanjutan

- Analytics: Integrasikan dengan [Tinybird](https://www.tinybird.co/) atau layanan analisis lainnya melalui fitur Integrations di panel admin.
- TKustomisasi tampilan dengan mengunggah tema kustom atau menggunakan tema bawaan Ghost.
- Aktifkan SSL/TLS secara otomatis melalui Caddy dan gunakan kata sandi yang kuat untuk database.

## Pranala Luar

- [How To Install Ghost With Docker](https://docs.ghost.org/install/docker)
- [How To Install Ghost Locally](https://docs.ghost.org/install/local)
- [Ghost Configuration: Mail](https://docs.ghost.org/config#mail)