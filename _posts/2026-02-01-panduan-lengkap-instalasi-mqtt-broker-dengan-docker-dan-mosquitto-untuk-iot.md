---
title: Panduan Lengkap Instalasi MQTT Broker dengan Docker & Mosquitto untuk IoT
description: Pelajari cara install dan konfigurasi MQTT Broker untuk proyek Internet of Things (IoT) menggunakan Docker & Mosquitto. Tutorial lengkap mulai dari prasyarat, setup Docker Compose, autentikasi user, hingga testing koneksi MQTT dan WebSocket.
categories: [Digital Independence, Telecommunications]
tags: [internet of things, mqtt]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

MQTT (Message Queuing Telemetry Transport) adalah protokol messaging ringan berbasis publish/subscribe yang dirancang khusus untuk komunikasi Machine-to-Machine (M2M) dan Internet of Things (IoT). Docker menyediakan lingkungan yang terisolasi dan konsisten untuk menjalankan MQTT Broker, sehingga memudahkan deployment, scaling, dan manajemen dependensi.

Dokumentasi ini mencakup panduan langkah-demi-langkah untuk menginstal dan mengonfigurasi Eclipse Mosquitto sebagai MQTT Broker menggunakan Docker dan Docker Compose pada sistem Debian/Ubuntu.

**Komponen yang akan diinstal:**
- Docker Engine (container runtime)
- Eclipse Mosquitto (MQTT Broker) versi terbaru
- Mosquitto Client Utilities (alat pengujian)
- Systemd service untuk auto-start

## Prasyarat Sistem

Sebelum memulai instalasi, pastikan sistem Anda memenuhi persyaratan berikut:

| Komponen       | Spesifikasi Minimum                     |
| -------------- | --------------------------------------- |
| Sistem Operasi | Debian 13+ / Ubuntu 20.04+              |
| Arsitektur     | x86_64 / ARM64                          |
| RAM            | 512 MB                                  |
| Storage        | 2 GB ruang kosong                       |
| Akses          | Root atau sudo privileges               |
| Jaringan       | Koneksi internet untuk download package |

## Instalasi Docker Engine

### Langkah 1: Persiapan Dependensi Sistem

Perbarui indeks package dan instal dependensi yang diperlukan untuk menambahkan repositori Docker:

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
```

**Penjelasan package:**
- `apt-transport-https`: Memungkinkan apt menggunakan repositori melalui HTTPS
- `ca-certificates`: Sertifikat CA standar untuk verifikasi koneksi SSL
- `curl`: Tool untuk transfer data dari/ke server
- `software-properties-common`: Menyediakan utilitas manajemen repositori (add-apt-repository)

### Langkah 2: Unduh dan Eksekusi Skrip Instalasi Docker

Repositori `digital-independence` menyediakan skrip otomatis untuk instalasi Docker Engine pada Debian. Unduh skrip tersebut:

```bash
wget https://github.com/ricalnet/digital-independence/blob/main/install-docker-engine-on-debian.sh
chmod +x install-docker-engine-on-debian.sh
```

Jalankan skrip instalasi:

```bash
./install-docker-engine-on-debian.sh
```

> Skrip ini akan mengonfigurasi repositori resmi Docker, menginstal Docker Engine, Docker CLI, dan Containerd. Proses ini memerlukan koneksi internet yang stabil.
{: .prompt-info}

### Langkah 3: Konfigurasi Hak Akses Pengguna

Tambahkan pengguna Anda ke grup `docker` untuk menjalankan perintah Docker tanpa `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

> Perintah `newgrp docker` menerapkan perubahan grup tanpa perlu logout. Jika perintah ini tidak berfungsi, lakukan logout dan login kembali.
{: .prompt-info}

Verifikasi bahwa instalasi Docker berhasil:

```bash
docker --version
```

**Output yang diharapkan:**
```
Docker version 29.x.x, build xxxxxxx
```

## Persiapan Proyek MQTT Broker

### Langkah 1: Clone Repositori Konfigurasi

Clone repositori yang berisi file Docker Compose dan konfigurasi Mosquitto:

```bash
git clone https://github.com/ricalnet/mqtt-docker.git
cd mqtt-docker
```

### Langkah 2: Buat Direktori dan File yang Diperlukan

Struktur direktori berikut diperlukan untuk menyimpan data persisten dan log:

```bash
mkdir -p config data log
touch config/pwfile
```

**Penjelasan direktori:**

| Direktori | Fungsi                                                                               |
| --------- | ------------------------------------------------------------------------------------ |
| `config/` | Menyimpan file konfigurasi Mosquitto (`mosquitto.conf`) dan file password (`pwfile`) |
| `data/`   | Menyimpan data persisten Mosquitto (database sesi, retained messages)                |
| `log/`    | Menyimpan file log untuk debugging dan monitoring                                    |

## Deployment Kontainer Mosquitto

### Langkah 1: Jalankan Kontainer dengan Docker Compose

```bash
docker compose up -d
```

Flag `-d` menjalankan kontainer dalam mode detached (background).

### Langkah 2: Verifikasi Status Kontainer

```bash
docker compose ps
```

**Output yang diharapkan:**
```
NAME              IMAGE                      COMMAND                  SERVICE       CREATED             STATUS             PORTS
mosquitto-local   eclipse-mosquitto:latest   "/docker-entrypoint.…"   mqtt-broker   About an hour ago   Up About an hour   0.0.0.0:1883->1883/tcp, [::]:1883->1883/tcp, 0.0.0.0:9001->9001/tcp, [::]:9001->9001/tcp
```

### Langkah 3: Monitoring Log Real-time

```bash
docker compose logs -f
```

Gunakan `Ctrl+C` untuk keluar dari mode follow. Flag `-f` memungkinkan Anda melihat log secara real-time, berguna untuk debugging saat terjadi masalah koneksi atau konfigurasi.

### Langkah 4: Verifikasi Instalasi Mosquitto

Cek versi Mosquitto di dalam kontainer:

```bash
docker exec mosquitto-local mosquitto -v
```

Periksa kesehatan kontainer secara detail:

```bash
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
```

Format output tabel memudahkan pembacaan informasi port yang terbuka dan status kontainer.

## Konfigurasi Autentikasi Pengguna

Keamanan merupakan aspek kritis dalam deployment MQTT Broker. Mosquitto mendukung autentikasi berbasis file password.

### Langkah 1: Masuk ke Shell Kontainer

```bash
docker exec -it mosquitto-local sh
```

### Langkah 2: Buat Pengguna Administrator

Gunakan flag `-c` untuk membuat file password baru dan menambahkan pengguna pertama:

```bash
mosquitto_passwd -c /mosquitto/config/pwfile admin
```

Saat diminta, masukkan password untuk pengguna `admin` (contoh: `Admin@2024!`).

> Gunakan password yang kompleks dengan kombinasi huruf besar, huruf kecil, angka, dan karakter khusus. Hindari penggunaan password default atau yang mudah ditebak.
{: .prompt-tip}

### Langkah 3: Tambahkan Pengguna Tambahan

Untuk menambahkan pengguna lain, jangan gunakan flag `-c` karena akan menimpa file yang sudah ada:

```bash
mosquitto_passwd /mosquitto/config/pwfile user1
mosquitto_passwd /mosquitto/config/pwfile user2
```

### Langkah 4: Verifikasi Daftar Pengguna

Periksa isi file password untuk memastikan semua pengguna telah terdaftar:

```bash
cat /mosquitto/config/pwfile
```

Keluar dari shell kontainer:

```bash
exit
```

### Langkah 5: Restart Kontainer

Restart kontainer untuk menerapkan perubahan konfigurasi autentikasi:

```bash
docker compose restart
```

Verifikasi log untuk memastikan tidak ada error setelah restart:

```bash
docker compose logs --tail=20
```

## Mendapatkan Informasi Jaringan Kontainer

Untuk keperluan troubleshooting atau integrasi dengan layanan lain, Anda mungkin perlu mengetahui IP address kontainer:

```bash
# Dapatkan IP address kontainer
docker inspect mosquitto-local | grep IPAddress

# Atau gunakan format output yang lebih bersih
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mosquitto-local
```

**Contoh output:** `172.17.0.2`

## Instalasi MQTT Client Tools

Mosquitto Client Utilities menyediakan perintah `mosquitto_pub` dan `mosquitto_sub` untuk pengujian publish/subscribe:

```bash
sudo apt install -y mosquitto-clients
```

Verifikasi instalasi:

```bash
mosquitto_sub --version
mosquitto_pub --version
```

**Output yang diharapkan:**
```
mosquitto_sub version 2.x.x running on libmosquitto 2.x.x.
mosquitto_pub version 2.x.x running on libmosquitto 2.x.x.
```

## Pengujian Koneksi MQTT

### Test Koneksi Dasar dengan Localhost

**Terminal 1 - Subscriber:**
```bash
mosquitto_sub -h localhost -t "test/connection" -u user1 -P "user1" -v
```

**Penjelasan parameter:**
- `-h localhost`: Hostname broker MQTT
- `-t "test/connection"`: Topic yang akan di-subscribe
- `-u user1`: Username untuk autentikasi
- `-P "user1"`: Password untuk autentikasi
- `-v`: Mode verbose, menampilkan topic bersama pesan

**Terminal 2 - Publisher:**
```bash
mosquitto_pub -h localhost -t "test/connection" -m "MQTT Broker berjalan dengan baik" -u user1 -P "user1"
```

**Hasil yang diharapkan:** Terminal 1 akan menampilkan pesan yang dipublikasikan dari Terminal 2, mengonfirmasi bahwa broker berfungsi dengan benar.

## Pengujian Koneksi WebSocket

Mosquitto mendukung koneksi WebSocket pada port 9001, memungkinkan aplikasi web browser untuk terhubung langsung ke MQTT Broker.

### Contoh Kode JavaScript untuk WebSocket

```javascript
// Pastikan library MQTT.js sudah diimpor
// <script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>

const client = mqtt.connect('ws://localhost:9001', {
  username: 'user1',
  password: 'user1',
  clientId: 'web_client_' + Math.random().toString(16).substr(2, 8)
});

client.on('connect', function() {
  console.log('Terhubung ke MQTT Broker via WebSocket');
  
  // Subscribe ke topic
  client.subscribe('test/websocket', function(err) {
    if (!err) {
      // Publish pesan test
      client.publish('test/websocket', 'Hello dari WebSocket client');
    }
  });
});

client.on('message', function(topic, message) {
  console.log('Pesan diterima:', topic, message.toString());
});

client.on('error', function(error) {
  console.error('Kesalahan koneksi:', error);
});
```

## Integrasi Systemd untuk Auto-Start

Untuk memastikan layanan MQTT Subscriber berjalan otomatis saat sistem boot, kita akan mengonfigurasi systemd service.

### Langkah 1: Edit File Service

Buka file `systemd/mosquitto-sub.service` untuk disesuaikan:

```bash
nano systemd/mosquitto-sub.service
```

**Konten service file yang umum:**
```ini
[Unit]
Description=Mosquitto MQTT Subscriber untuk test/connection
After=network.target
Wants=network.target

[Service]
Type=simple
User=your_username
ExecStart=/usr/bin/mosquitto_sub -h ip/domain -t "test/connection" -u user1 -P user1 -v
Restart=always
RestartSec=10
StandardOutput=append:/var/log/mosquitto-sub.log
StandardError=append:/var/log/mosquitto-sub-error.log

[Install]
WantedBy=multi-user.target
```

> Sesuaikan parameter `User` dengan username sistem Anda dan `ExecStart` dengan perintah subscribe yang sesuai dengan kebutuhan Anda.
{: .prompt-tip}

### Langkah 2: Salin File Service ke Systemd

```bash
sudo cp systemd/mosquitto-sub.service /etc/systemd/system/
```

### Langkah 3: Reload Systemd Daemon

```bash
sudo systemctl daemon-reload
```

Setiap kali ada perubahan pada file unit service, daemon-reload diperlukan agar systemd membaca konfigurasi terbaru.

## Manajemen Layanan

Repositori ini menyediakan skrip untuk mempermudah manajemen siklus hidup layanan.

### Menjalankan Layanan Subscriber

```bash
./start-sub.sh
```

Skrip ini akan memulai proses subscriber yang berjalan di background.

### Menghentikan Layanan Subscriber

```bash
./stop-sub.sh
```

### Melihat Log Real-time

```bash
./show-mosquitto-sub.sh
```

Skrip ini menampilkan log subscriber secara real-time, berguna untuk monitoring pesan yang diterima.

### Pengujian Koneksi Otomatis

```bash
./test-mosquitto-pub.sh
```

Skrip pengujian ini melakukan publish secara otomatis untuk memverifikasi bahwa seluruh sistem berfungsi dengan baik.

## Pemecahan Masalah

### Masalah Umum dan Solusinya

| Gejala                    | Penyebab Kemungkinan           | Solusi                                                                                                           |
| ------------------------- | ------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| Kontainer tidak berjalan  | Port sudah digunakan           | Cek port 1883 dan 9001: `sudo netstat -tlnp \| grep -E '1883\|9001'`                                             |
| Autentikasi gagal         | File password tidak terbaca    | Periksa permission file: `docker exec mosquitto-local ls -la /mosquitto/config/pwfile`                           |
| Koneksi WebSocket ditolak | Konfigurasi listener WebSocket | Verifikasi `mosquitto.conf` memiliki listener port 9001 dengan protokol websockets                               |
| Log menunjukkan error     | Format konfigurasi salah       | Validasi file konfigurasi: `docker exec mosquitto-local mosquitto -c /mosquitto/config/mosquitto.conf --verbose` |

### Perintah Diagnostik Berguna

```bash
# Lihat penggunaan resource kontainer
docker stats mosquitto-local --no-stream

# Cek port yang listening di kontainer
docker exec mosquitto-local netstat -tlnp

# Lihat konfigurasi Mosquitto yang aktif
docker exec mosquitto-local cat /mosquitto/config/mosquitto.conf
```