---
title: Implementasi Mautrix-WhatsApp Bridge dengan Docker
description: Dokumentasi teknis lengkap untuk menyebarkan jembatan Matrix-WhatsApp menggunakan mautrix-whatsapp dan homeserver Synapse dalam kontainer Docker. Meliputi arsitektur, konfigurasi, manajemen, dan pemecahan masalah.
categories: [Digital Independence, Communications]
tags: [self-hosted, cryptography, docker, matrix protocol, element]
author: rical
last_modified_at: 2026-07-02
---

> Panduan ini merupakan dokumentasi lama dan tidak lagi mencerminkan praktik keamanan terkini. Silakan merujuk pada panduan terbaru: [Panduan Deployment Matrix Synapse Self-Hosted dengan Mautrix Bridge WhatsApp & Telegram](https://docs.ricalnet.my.id/posts/panduan-deployment-matrix-synapse-self-hosted-dengan-mautrix-bridge-whatsapp-dan-telegram/).
{: .prompt-warning}

## Pendahuluan

mautrix-whatsapp bridge adalah jembatan yang menghubungkan homeserver Matrix (Synapse) dengan jaringan WhatsApp. Jembatan ini memungkinkan pengguna Matrix berkomunikasi langsung dengan kontak dan grup WhatsApp tanpa harus meninggalkan klien Matrix mereka.

### Fitur Utama

- ✅ Sinkronisasi pesan dua arah (real-time)
- ✅ Dukungan penuh untuk grup WhatsApp
- ✅ Transfer media (gambar, video, dokumen)
- ✅ Enkripsi end-to-end WhatsApp
- ✅ Multi-device support
- ✅ Status online/typing (opsional)

### Prasyarat

- Synapse berjalan di Docker ([lihat panduan instalasi](https://docs.ricalnet.my.id/posts/matrix-protocol-with-synapse-and-element/))
- Docker dan Docker Compose terinstal
- Nama domain untuk server Matrix (contoh: `matrix.domain.my.id`)
- Akun WhatsApp aktif

## Arsitektur Sistem

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│   Klien Matrix  │◄────►│     Synapse      │◄────►│ mautrix-whatsapp│◄────►│   WhatsApp      │
│   (Element dll) │      │  (Homeserver)    │      │    (Bridge)     │      │   (Ponsel)      │
└─────────────────┘      └────────┬─────────┘      └────────┬────────┘      └─────────────────┘
                                  │                         │
                                  │    Jaringan Docker      │
                                  │   (synapse-network)     │
                                  └─────────────────────────┘
                                           │
                                   ┌───────▼────────┐
                                   │   PostgreSQL   │
                                   │   (Database)   │
                                   └────────────────┘
```

Komponen utama:
- Synapse: Homeserver Matrix
- mautrix-whatsapp: Bridge WhatsApp
- PostgreSQL: Database untuk menyimpan data bridge
- Jaringan Docker: `synapse-network` untuk komunikasi antar kontainer

## Instalasi dan Konfigurasi

### Langkah 1: Struktur Direktori

Clone repositori dan buat struktur direktori untuk data jembatan:

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
cd synapse/mautrix-whatsapp
```

### Langkah 2: Konfigurasi Environment

```bash
cp .env.example .env
```

File `.env` berisi variabel environment yang digunakan oleh Docker Compose.

### Langkah 3: Konfigurasi Bridge

Jalankan bridge sekali untuk menghasilkan file konfigurasi bawaan:

```bash
docker compose up -d
sleep 10 
docker compose down
```

Edit file konfigurasi:

```bash
nano mautrix-whatsapp-data/config.yaml
```

#### Bagian yang Perlu Disesuaikan:

Berikut adalah bagian-bagian penting yang WAJIB disesuaikan dengan lingkungan Anda:

```yaml
# Config for the bridge's database.
database:
    type: postgres
    uri: postgres://mautrix_whatsapp:PASSWORD_ANDA@postgres/mautrix_whatsapp?sslmode=disable
    # Ganti PASSWORD_ANDA dengan password yang sama di docker-compose.yml

# Homeserver details.
homeserver:
    address: http://synapse:8008
    domain: matrix.domain.anda.id

# Application service host/registration related details.
appservice:
    address: http://mautrix-whatsapp:29318
    hostname: 0.0.0.0
    port: 29318
    id: whatsapp
    bot:
        username: whatsappbot 
        displayname: WhatsApp bridge bot
        avatar: ""

# Config options that affect the central bridge module.
bridge:
    # Permissions for using the bridge.
    permissions:
        '*': user
        '@username_anda:matrix.domain.anda.id': admin  

# End-to-bridge encryption support options.
encryption:
    allow: true
    default: true
    require: true
    appservice: false
    msc4190: false
    msc4392: true
    self_sign: false
    allow_key_sharing: false
    delete_keys:
        delete_outbound_on_ack: true
        dont_store_outbound: false
        ratchet_on_decrypt: true
        delete_fully_used_on_decrypt: true
        delete_prev_on_new_session: true
        delete_on_device_delete: true
        periodically_delete_expired: true
        delete_outdated_inbound: true
    verification_levels:
        receive: cross-signed-tofu
        send: cross-signed-tofu
        share: cross-signed-tofu
    rotation:
        enable_custom: true
        milliseconds: 604800000
        messages: 50
        disable_device_change_key_rotation: false 
```

> Pastikan password PostgreSQL di `database.uri` sama dengan `POSTGRES_PASSWORD` di docker-compose.yml
{: .prompt-info}

### Langkah 4: Generate dan Install File Registrasi

Generate file registrasi:
```bash
docker compose up -d
sleep 10
docker compose down
```

Copy ke direktori Synapse:
```bash
sudo cp mautrix-whatsapp-data/registration.yaml /var/lib/docker/volumes/synapse-data/_data/mautrix-whatsapp-registration.yaml
```

Set permission:
```bash
sudo chown -R 991:991 /var/lib/docker/volumes/synapse-data/_data/mautrix-whatsapp-registration.yaml
```

### Langkah 5: Konfigurasi Synapse

Edit file `homeserver.yaml`:

```bash
sudo nano /var/lib/docker/volumes/synapse-data/_data/homeserver.yaml
```

Tambahkan baris berikut di bagian `app_service_config_files`:

```yaml
app_service_config_files:
  - /data/mautrix-whatsapp-registration.yaml
  # Jika ada bridge lain, tambahkan juga:
  # - /data/mautrix-telegram-registration.yaml
```

Restart Synapse:

```bash
docker restart synapse
sleep 10
```

### Langkah 6: Jalankan Bridge

```bash
docker compose up -d
docker compose logs -f
```

Tunggu hingga muncul log seperti:
```
mautrix-whatsapp  | INF Bridge started
mautrix-whatsapp  | INF No user logins found
```

## Manajemen Bridge

### Perintah Docker

| Tindakan       | Perintah                 |
| -------------- | ------------------------ |
| Memulai bridge | `docker compose up -d`   |
| Menghentikan   | `docker compose down`    |
| Restart        | `docker compose restart` |
| Melihat log    | `docker compose logs -f` |
| Status         | `docker compose ps`      |

### Perintah di Matrix

Setelah bridge berjalan, buat room chat dengan bot `@whatsappbot:domain.anda.id` dan kirim perintah:

| Perintah       | Deskripsi                                |
| -------------- | ---------------------------------------- |
| `!wa help`     | Menampilkan semua perintah               |
| `!wa login-qr` | Menampilkan QR code untuk login WhatsApp |
| `!wa logout`   | Logout dari WhatsApp                     |
| `!wa ping`     | Cek koneksi bridge                       |
| `!wa sync`     | Sinkronisasi manual                      |

### Proses Login WhatsApp

1. Kirim perintah `!wa login-qr` ke room bot
2. Bridge akan membalas dengan kode QR
3. Buka WhatsApp di ponsel → Menu → Perangkat tertaut → Tautkan perangkat
4. Pindai kode QR yang ditampilkan
5. Tunggu hingga sinkronisasi selesai (bisa 1-5 menit)

## Pemecahan Masalah

### 1. Sinkronisasi Lambat

**Masalah:** Chat tidak muncul atau sinkronisasi memakan waktu lama

**Solusi:**
- Tunggu 5-10 menit, sinkronisasi awal memang lambat
- Kirim perintah `!wa sync` untuk memaksa sinkronisasi
- Periksa log: `docker compose logs -f | grep sync`

## Kesimpulan

mautrix-whatsapp bridge menyediakan integrasi yang seamless antara Matrix dan WhatsApp dengan fitur lengkap:

- ✅ Pesan real-time dua arah
- ✅ Dukungan grup dan media
- ✅ Enkripsi end-to-end
- ✅ Multi-device WhatsApp
- ✅ Stabil dan reliable

Dengan mengikuti panduan ini, Anda berhasil mengimplementasikan jembatan WhatsApp di server Matrix Anda. Pengguna kini dapat berkomunikasi dengan kontak WhatsApp langsung dari klien Matrix pilihan mereka.

### Langkah Selanjutnya

1. Login WhatsApp dengan scan QR code
2. Uji coba kirim pesan ke kontak WhatsApp
3. Konfigurasi double puppeting (opsional)
4. Setup monitoring dan backup otomatis
5. Eksplorasi fitur lanjutan di [dokumentasi resmi](https://docs.mau.fi/bridges/go/whatsapp/index.html)

## Pranala Luar

- [Dokumentasi mautrix-whatsapp](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=whatsapp)