---
title: Implementasi Mautrix-Telegram Bridge dengan Docker
description: Dokumentasi teknis langkah-demi-langkah untuk menyebarkan jembatan (bridge) Matrix-Telegram menggunakan mautrix-telegram dan homeserver Synapse dalam kontainer Docker. Meliputi arsitektur, konfigurasi, perintah manajemen, dan tips pemecahan masalah untuk komunikasi mulus antara Matrix dan Telegram.
categories: [Digital Independence, Communications]
tags: [self-hosted, cryptography, docker, matrix protocol, element]
author: rical
last_modified_at: 2026-07-02
---

> Panduan ini merupakan dokumentasi lama dan tidak lagi mencerminkan praktik keamanan terkini. Silakan merujuk pada panduan terbaru: [Panduan Deployment Matrix Synapse Self-Hosted dengan Mautrix Bridge WhatsApp & Telegram](https://docs.ricalnet.my.id/posts/panduan-deployment-matrix-synapse-self-hosted-dengan-mautrix-bridge-whatsapp-dan-telegram/).
{: .prompt-warning}

## Pendahuluan

mautrix-telegram bridge adalah alat yang menghubungkan homeserver Matrix (misalnya Synapse) dengan jaringan Telegram. Jembatan ini memungkinkan pengguna Matrix berkomunikasi langsung dengan kontak, grup, dan saluran Telegram tanpa harus meninggalkan klien Matrix mereka.

Dengan mengikuti panduan ini, Anda akan:

- Memahami arsitektur jembatan.
- Menyiapkan jaringan Docker khusus untuk komunikasi antar‑kontainer.
- Mengonfigurasi dan menjalankan kontainer mautrix‑telegram.
- Mendaftarkan jembatan sebagai layanan aplikasi (appservice) ke Synapse.
- Mempelajari perintah manajemen penting dan teknik pemecahan masalah.

## Arsitektur Sistem

Diagram berikut menggambarkan interaksi antar komponen:

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Klien Matrix  │◄────►│     Synapse      │◄────►│ mautrix-telegram│
│   (Element dll) │      │  (Homeserver)    │      │    (Bridge)     │
└─────────────────┘      └────────┬─────────┘      └────────┬────────┘
                                  │                         │
                                  │    Jaringan Docker      │
                                  │   (synapse-network)     │
                                  └─────────────────────────┘
                                           │
                                   ┌───────▼────────┐
                                   │   Telegram     │
                                   │   Network      │
                                   └────────────────┘
```

- Synapse adalah homeserver Matrix yang menangani semua lalu lintas Matrix.
- mautrix-telegram berjalan sebagai kontainer terpisah yang menjembatani kedua jaringan.
- Kedua kontainer berkomunikasi melalui jaringan Docker khusus (`synapse-network`), sementara jembatan juga terhubung ke internet publik untuk menjangkau server Telegram.

## Prasyarat

Sebelum memulai, pastikan Anda memiliki:

- Synapse yang berjalan di Docker (lihat [artikel sebelumnya](https://docs.ricalnet.my.id/posts/matrix-protocol-with-synapse-and-element/) jika perlu).
- Docker dan Docker Compose terinstal di host.
- Nama domain untuk server Matrix Anda (misalnya `matrix.domain.my.id`).
- Kredensial API Telegram:
  - `api_id` dan `api_hash` – dapatkan dari [my.telegram.org/apps](https://my.telegram.org/apps).
  - (Opsional) Token Bot Telegram dari [@BotFather](https://t.me/BotFather) jika ingin menggunakan fitur bot.

## Gambaran Komponen

| Komponen         | Nama Kontainer     | Image                                  | Tujuan                            |
| ---------------- | ------------------ | -------------------------------------- | --------------------------------- |
| Synapse          | `synapse`          | `matrixdotorg/synapse:latest`          | Homeserver Matrix utama.          |
| mautrix-telegram | `mautrix-telegram` | `dock.mau.dev/mautrix/telegram:latest` | Menjembatani Matrix dan Telegram. |

Kedua kontainer harus dapat berkomunikasi. Kita akan menempatkannya pada jaringan Docker yang sama.

## Instalasi dan Konfigurasi

### Langkah 1: Siapkan Kontainer Bridge

Clone repositori dan buat struktur direktori untuk data jembatan:

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
cd synapse/mautrix-telegram
```

Jalankan kontainer sekali untuk menghasilkan file konfigurasi bawaan:

```bash
docker compose up -d
docker compose logs -f   # Tunggu sampai muncul "Config file created"
docker compose down      # Hentikan kontainer untuk mengedit konfigurasi
```

### Langkah 2: Konfigurasi Awal

Edit file konfigurasi yang telah dibuat:

```bash
nano mautrix-telegram-data/config.yaml
```

Ubah bagian-bagian penting seperti di bawah ini. Ganti placeholder dengan nilai aktual Anda.

```yaml
# Homeserver details
homeserver:
    address: http://synapse:8008          # Nama layanan Docker Synapse dan port internal
    domain: matrix.domain.my.id            # Domain Matrix Anda

# Application service host/registration related details
appservice:
    address: http://mautrix-telegram:29317 # Alamat internal bridge
    hostname: 0.0.0.0
    port: 29317
    database: sqlite:/data/mautrix-telegram.db

# Get your own API keys at https://my.telegram.org/apps
telegram:
    api_id: YOUR_API_ID                     # misalnya 123456
    api_hash: YOUR_API_HASH                  # misalnya 'a1b2c3d4e5f6...'
    bot_token: ""                            # Token bot opsional

    # Permissions for using the bridge.
    permissions:
        '*': user
        '@namaanda:matrix.domain.my.id': admin   # Pengguna Matrix Anda

    # End-to-bridge encryption support options.
    encryption:
        allow: true
        default: true
        appservice: false
        msc4190: false
        self_sign: false
        require: true
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

> `homeserver.address` harus mengarah ke kontainer Synapse menggunakan nama layanan Docker (`synapse`) dan port internal (biasanya `8008`). `appservice.address` harus mencerminkan hostname dan port kontainer bridge itu sendiri.
{: .prompt-info}

### Langkah 3: Daftarkan Appservice ke Synapse

Jalankan bridge kembali untuk membuat file registrasi:

```bash
docker compose up -d
```

Setelah beberapa saat, file `registration.yaml` akan muncul di direktori `mautrix-telegram-data`. Salin file tersebut ke volume data Synapse:

```bash
sudo cp mautrix-telegram-data/registration.yaml /var/lib/docker/volumes/synapse-data/_data/mautrix-telegram-registration.yaml
```

Sekarang edit file konfigurasi Synapse untuk menyertakan file registrasi:

```bash
sudo nano /var/lib/docker/volumes/synapse-data/_data/homeserver.yaml
```

Tambahkan atau aktifkan baris berikut:

```yaml
app_service_config_files:
  - /data/mautrix-telegram-registration.yaml
```

Simpan file dan restart Synapse:

```bash
docker restart synapse
```

### Langkah 4: Restart Layanan

Restart bridge untuk memastikan koneksi berjalan baik:

```bash
docker compose restart
```

Periksa log untuk konfirmasi bahwa bridge berhasil berjalan:

```bash
docker compose logs -f
```

Anda akan melihat pesan seperti `Startup actions complete in... seconds, now running forever`.

## Manajemen Bridge

### Perintah Docker

| Tindakan             | Perintah                 |
| -------------------- | ------------------------ |
| Memulai bridge       | `docker compose up -d`   |
| Menghentikan bridge  | `docker compose down`    |
| Merestart bridge     | `docker compose restart` |
| Melihat log (ikuti)  | `docker compose logs -f` |
| Cek status kontainer | `docker compose ps`      |

### Perintah di Ruang Matrix

Setelah bridge berjalan, undang bot bridge ke ruang Matrix (biasanya pengguna bot adalah `@telegrambot:domainanda`). Kemudian Anda dapat mengirim perintah di ruang tersebut. Perintah umum:

| Perintah                | Deskripsi                                             |
| ----------------------- | ----------------------------------------------------- |
| `help`                  | Menampilkan semua perintah yang tersedia.             |
| `login`                 | Login ke Telegram menggunakan telepon dan password.   |
| `login-qr`              | Login dengan memindai kode QR (direkomendasikan).     |
| `logout`                | Keluar dari Telegram.                                 |
| `ping`                  | Periksa konektivitas ke Telegram.                     |
| `contacts`              | Lihat daftar kontak Telegram.                         |
| `pm @username`          | Mulai obrolan pribadi dengan pengguna Telegram.       |
| `pm 123456789`          | Mulai obrolan dengan pengguna berdasarkan ID numerik. |
| `join https://t.me/...` | Bergabung ke grup atau saluran Telegram.              |
| `create Nama Grup`      | Membuat grup Telegram baru.                           |

Setelah login, bridge akan secara otomatis menyinkronkan obrolan Telegram Anda, dan Anda akan melihatnya sebagai ruang di klien Matrix.

## Pemecahan Masalah

### 1. Bridge Tidak Bisa Terhubung ke Synapse

**Error:** `MUnknownToken: Invalid access token`  
**Penyebab:** File registrasi tidak ditemukan atau tidak dirujuk dengan benar di Synapse.

**Solusi:**  
- Pastikan `registration.yaml` telah disalin ke direktori data Synapse.  
- Pastikan jalur di `homeserver.yaml` benar (misalnya `/data/mautrix-telegram-registration.yaml`{: .filepath}).  
- Restart kedua kontainer:

```bash
docker restart synapse
docker compose restart
```

### 2. Pesan Terenkripsi Tidak Terbaca

**Error:** `Got encrypted message ... but encryption is not enabled`  
**Penyebab:** Secara bawaan bridge tidak mendukung enkripsi ujung-ke-ujung, atau ruang dienkripsi.

**Solusi:**  
- **Opsi A:** Buat ruang baru tanpa enkripsi.  
- **Opsi B:** Aktifkan dukungan enkripsi di bridge (lanjutan). Tambahkan ke `config.yaml`:

```yaml
encryption:
    allow: true
    default: false
    require: false
```

Kemudian restart bridge.

### 3. Kesalahan Database

**Error:** `Configuration error: appservice.database not configured`  
**Penyebab:** Pengaturan database hilang atau salah.

**Solusi:**  
Gunakan SQLite untuk kemudahan. Pastikan baris berikut ada di `config.yaml`:

```yaml
appservice:
    database: sqlite:/data/mautrix-telegram.db
```

### 4. Kesalahan Izin

**Error:** `bridge.permissions not configured`  
**Penyebab:** Bagian izin tidak ada atau tidak lengkap.

**Solusi:**  
Tambahkan blok izin dasar:

```yaml
bridge:
    permissions:
        '*': user
        '@adminanda:domain.anda': admin
```

## Pemantauan dan Logging

Pemantauan rutin membantu memastikan bridge berjalan lancar.

- Lihat error:

  ```bash
  docker compose logs -f | grep -E "ERROR|CRITICAL|WARNING"
  ```

- Periksa koneksi ke homeserver:

  ```bash
  docker compose logs -f | grep "Connection to homeserver"
  ```

- Aktivitas pengguna:

  ```bash
  docker compose logs -f | grep "Handling transaction"
  ```

- Pemeriksaan kesehatan:

  Status kontainer:
  ```bash
  docker ps | grep mautrix-telegram
  ```

  Konektivitas ke Synapse:
  ```bash
  docker compose exec mautrix-telegram curl -s http://synapse:8008/health
  ```

  Endpoint API bridge (jika port dipublikasi):
  ```bash
  curl -s http://localhost:29317/_matrix/app/v1/ping
  ```

## Praktik Terbaik Keamanan

- Isolasi kontainer dengan jaringan Docker khusus (`synapse-network`). Jangan buka port yang tidak perlu.
- Lindungi file registrasi – berisi `as_token` dan `hs_token`. Jangan pernah commit ke kontrol versi.
- Jaga kerahasiaan kredensial API Telegram (`api_id`, `api_hash`). Mereka setara dengan kata sandi.
- Cadangkan secara rutin database SQLite dan file konfigurasi bridge.
- Pantau log untuk aktivitas mencurigakan, seperti upaya login gagal berulang.
- Gunakan firewall untuk membatasi lalu lintas keluar jika memungkinkan; bridge hanya perlu akses ke server Telegram dan Synapse Anda.

## Cadangan dan Pemulihan

### Cadangan

Buat arsip terkompresi dari direktori data bridge:

```bash
tar -czf mautrix-telegram-backup-$(date +%Y%m%d).tar.gz \
  ~/apps/mautrix-telegram/mautrix-telegram-data/
```

Simpan arsip ini di lokasi aman.

### Pemulihan

Hentikan bridge:

```bash
cd ~/apps/mautrix-telegram
docker compose down
```

Pulihkan data dari cadangan:

```bash
tar -xzf mautrix-telegram-backup-YYYYMMDD.tar.gz
```

Jalankan kembali bridge:

```bash
docker compose up -d
```

## Kesimpulan

Menerapkan mautrix-telegram bridge dengan Docker dan Synapse memberikan cara yang andal untuk mengintegrasikan Matrix dan Telegram. Panduan ini telah memandu Anda melalui seluruh proses—dari penyiapan jaringan dan konfigurasi hingga manajemen dan pemecahan masalah. Dengan jembatan ini, pengguna Matrix Anda dapat berkomunikasi dengan lancar dengan kontak, grup, dan saluran Telegram.

Arsitektur yang digunakan memastikan pemisahan perhatian, kemudahan perawatan, dan skalabilitas. Dengan mengikuti rekomendasi keamanan dan pencadangan, Anda dapat mempertahankan jembatan yang stabil dan aman dalam jangka panjang.

## Pranala Luar

- [Dokumentasi mautrix-telegram](https://docs.mau.fi/bridges/general/docker-setup.html?bridge=telegram)
- [Mendapatkan ID API Telegram](https://my.telegram.org/apps)