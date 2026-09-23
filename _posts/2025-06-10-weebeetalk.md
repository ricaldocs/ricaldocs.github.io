---
title: WeeBeeTalk
description: Solusi telekomunikasi hybrid yang berfokus pada privasi, dirancang untuk konferensi enterprise dengan mengintegrasikan stack teknologi open-source seperti Rocket.Chat, Jitsi, dan Asterisk.
categories: [Digital Independence, Communications]
tags: [docker, telecommunications, self-hosted, jitsi, asterisk]
author: rical
last_modified_at: 2026-02-19
---

## 1. Pendahuluan

WeeBeeTalk merupakan arsitektur telekomunikasi hybrid berorientasi privasi yang dirancang khusus untuk memenuhi kebutuhan konferensi enterprise melalui integrasi tumpukan teknologi sumber terbuka. Solusi ini dikembangkan sebagai respons terhadap tantangan kontemporer dalam komunikasi bisnis modern, terutama menyangkut kerahasiaan data, interoperabilitas sistem, dan kontrol infrastruktur mandiri.

Mengapa arsitektur hybrid diperlukan?

| Tantangan            | Solusi WeeBeeTalk                          |
| -------------------- | ------------------------------------------ |
| Keamanan end-to-end  | Enkripsi pada semua lapisan komunikasi     |
| Ketergantungan cloud | Implementasi on-premise penuh              |
| Interoperabilitas    | Integrasi chat, video, dan teleponi        |
| Kebijakan konsisten  | RBAC dan autentikasi multi-faktor terpusat |

Komponen utama:

| Komponen                                | Fungsi                           | Lisensi    |
| --------------------------------------- | -------------------------------- | ---------- |
| [Rocket.Chat](https://www.rocket.chat/) | Platform kolaborasi pesan instan | MIT        |
| [Jitsi Meet](https://jitsi.org/)        | Engine konferensi video WebRTC   | Apache 2.0 |
| [Asterisk](https://www.asterisk.org/)   | Gateway teleponi berbasis IP-PBX | GPL        |

![Arsitektur WeeBeeTalk](/assets/img/posts/2025-06-10-weebeetalk/weebeetalk.png)
*Arsitektur WeeBeeTalk*

Implementasi mengadopsi paradigma "privacy by design" dengan:
- Enkripsi end-to-end (data-at-rest dan data-in-transit)
- Role-Based Access Control (RBAC)
- Autentikasi multi-faktor

## 2. Lingkungan Sistem dan Prasyarat

WeeBeeTalk diimplementasikan pada **Debian GNU/Linux** (versi stabil terkini), dipilih karena stabilitas LTS, ekosistem paket komprehensif, dan kompatibilitas optimal.

### Spesifikasi Minimum

| Komponen | Spesifikasi                 | Mengapa                                      |
| -------- | --------------------------- | -------------------------------------------- |
| OS       | Debian 12 (Bookworm) x86_64 | Stabilitas dan dukungan jangka panjang       |
| CPU      | 4 core x64                  | Menangani beban konferensi dan chat simultan |
| RAM      | 8 GB                        | Cukup untuk menjalankan 3 komponen utama     |
| Storage  | 50 GB SSD                   | Image Docker dan log memakan ruang           |
| Jaringan | IP publik statis / DNS      | Akses eksternal dan SSL/TLS                  |

### Prasyarat Debian

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

```bash
sudo apt install -y apt-transport-https ca-certificates gnupg2 curl software-properties-common
```

**Mengapa paket-paket ini?**
- `apt-transport-https`, `ca-certificates`, `gnupg2`, `curl` → Untuk mengunduh dan memverifikasi paket dari repositori eksternal (Docker, NodeSource, dll)
- `software-properties-common` → Menambahkan PPA/repositori dengan `add-apt-repository`

## 3. Konfigurasi Rocket.Chat via Docker

### 3.1 Mengambil Konfigurasi

```bash
git clone --depth 1 https://github.com/RocketChat/rocketchat-compose.git
cd rocketchat-compose
cp .env.example .env
```

| Perintah               | Fungsi                        | Mengapa                                                |
| ---------------------- | ----------------------------- | ------------------------------------------------------ |
| `--depth 1`            | Kloning hanya commit terakhir | Menghemat bandwidth dan waktu                          |
| `cp .env.example .env` | Membuat file konfigurasi      | `.env` menyimpan rahasia; tidak boleh di-commit ke Git |

### 3.2 Konfigurasi .env

```bash
nano .env
```

Variabel kunci:
```plaintext
RELEASE=7.10.0
```

> Versi spesifik memastikan stabilitas dan kompatibilitas. `latest` bisa berubah tanpa pemberitahuan dan merusak integrasi.
{: .prompt-warning}

### 3.3 Menjalankan Rocket.Chat

```bash
docker compose -f compose.database.yml -f compose.monitoring.yml -f compose.traefik.yml -f compose.yml up -d
```

Mengapa banyak compose file? Arsitektur modular:
- `compose.database.yml` → MongoDB (database)
- `compose.monitoring.yml` → Prometheus + Grafana (opsional)
- `compose.traefik.yml` → Reverse proxy (opsional)
- `compose.yml` → Rocket.Chat utama

Tanpa monitoring dan Traefik:
```bash
docker compose -f compose.database.yml -f compose.yml up -d
```

Akses:
- Lokal: `http://localhost:3000`
- Production: `ROOT_URL` yang dikonfigurasi di `.env`

## 4. Integrasi dengan WebRTC (Jitsi)

### 4.1 Instalasi

> Jangan clone repository git. Untuk versi stabil, gunakan rilis resmi. Branch `master` bersifat unstable dan hanya untuk development.
{: .prompt-warning}

Unduh rilis terbaru:
```bash
wget $(wget -q -O - https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep zip | cut -d\" -f4)
unzip <nama-file>
```

Konfigurasi:
```bash
cp env.example .env
./gen-passwords.sh
```

Generate password:
```bash
mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}
```

Jalankan:
```bash
docker compose up -d
```

Akses: `https://localhost:8443`

Port:

| Port         | Fungsi                | Mengapa HTTPS?                                           |
| ------------ | --------------------- | -------------------------------------------------------- |
| 8443 (HTTPS) | Akses utama WebRTC    | WebRTC membutuhkan HTTPS untuk mengakses kamera/mikrofon |
| 8000 (HTTP)  | Reverse proxy backend | Tidak untuk akses langsung                               |

### 4.2 Konfigurasi Tambahan

| Komponen    | Perintah             | Fungsi                                       |
| ----------- | -------------------- | -------------------------------------------- |
| PUBLIC_URL  | Set di `.env`        | Domain publik tempat Jitsi berjalan          |
| Jigasi      | `-f jigasi.yml`      | Gateway SIP untuk panggilan ke telepon biasa |
| Etherpad    | `-f etherpad.yml`    | Berbagi dokumen real-time                    |
| Jibri       | `-f jibri.yml`       | Rekaman dan streaming                        |
| Transcriber | `-f transcriber.yml` | Transkripsi otomatis                         |
| Grafana     | `-f grafana.yml`     | Monitoring dan log analysis                  |

Semua komponen:
```bash
docker compose -f docker-compose.yml -f transcriber.yml -f jigasi.yml -f jibri.yml up -d
```

### 4.3 Proses Update

Unduh rilis terbaru:
```bash
wget $(wget -q -O - https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep zip | cut -d\" -f4)
unzip <nama-file>  # Timpa file yang ada
```

Mengapa update penting? Perbaikan keamanan dan bug fix. Jitsi Meet aktif dikembangkan.

### 4.4 Testing Development Builds

Hanya untuk pengujian:
```bash
git clone https://github.com/jitsi/docker-jitsi-meet && cd docker-jitsi-meet
docker compose up
```

> Branch `master` bekerja dengan image unstable yang diupload setiap hari. Jangan gunakan di production.
{: .prompt-danger}

### 4.5 Troubleshooting

Error: `Failed to access your microphone/camera`

| Penyebab                              | Solusi                            |
| ------------------------------------- | --------------------------------- |
| Akses via HTTP, bukan HTTPS           | Gunakan `https://`                |
| `navigator.mediaDevices is undefined` | HTTPS diperlukan untuk WebRTC API |

Mengapa HTTPS wajib? Browser modern memblokir akses media devices di konteks non-HTTPS karena alasan keamanan.

Security Group Rules:

![Inbound Rules](../assets/img/posts/2025-06-10-weebeetalk/inbound-rules.png)

## 5. Integrasi dengan Asterisk

Lihat dokumentasi terpisah: [Membangun VoIP Server](https://docs.ricalnet.my.id/posts/membangun-voip-server/) menggunakan Asterisk.

Asterisk berfungsi sebagai:
- Gateway antara jaringan SIP dan PSTN (telepon biasa)
- PBX (Private Branch Exchange) internal
- Bridge antara Jitsi (WebRTC) dan telepon konvensional

Mengapa Asterisk penting? Banyak enterprise masih memiliki infrastruktur telepon tradisional. Asterisk menjembatani dunia baru (WebRTC) dan dunia lama (PSTN) tanpa mengganti seluruh sistem.

## Ringkasan Arsitektur

```
┌─────────────────────────────────────────────────────┐
│                     Pengguna                        │
└──────────────┬───────────────────┬──────────────────┘
               │                   │
               ▼                   ▼
┌─────────────────────┐ ┌──────────────────────┐
│   Rocket.Chat       │ │   Jitsi Meet         │
│   Pesan Instan      │ │   Konferensi Video   │
│   Kolaborasi        │ │   WebRTC             │
└──────────┬──────────┘ └──────────┬───────────┘
           │                       │
           └───────────┬───────────┘
                       ▼
              ┌────────────────┐
              │   Asterisk     │
              │   IP-PBX       │
              │   Gateway SIP  │
              └────────────────┘
```

Alur Komunikasi:
1. Chat → Rocket.Chat
2. Video Call → Jitsi (WebRTC)
3. Panggilan Telepon → Asterisk (SIP/PSTN)
4. Semua terintegrasi → Pengalaman pengguna tunggal

## Pranala Luar

- [Deploy Rocket.Chat](https://docs.rocket.chat/docs/deploy-with-docker-docker-compose)
- [Asterisk Manager Interface (AMI)](https://docs.asterisk.org/Configuration/Interfaces/Asterisk-Manager-Interface-AMI/)
- [Jitsi Meet Handbook](https://jitsi.github.io/handbook/docs/intro)