---
title: Panduan Self-Hosting Authentik untuk Digital Independence
description: Pelajari cara deploy Authentik sebagai Identity Provider (IdP) self-hosted menggunakan Podman dan podman-compose. Panduan teknis lengkap mencakup arsitektur, keamanan, konfigurasi, dan integrasi dengan ekosistem Digital Independence untuk SSO terpusat.
categories: [Digital Independence, SSO]
tags: [self-hosted, sso, authentik]
author: rical
last_modified_at: 2026-09-11
---

## Mengapa Authentik? Mengembalikan Kendali atas Identitas Digital Anda

Di era di mana setiap layanan digital menuntut akun terpisah, kita sering kali menyerahkan kendali identitas kita kepada pihak ketiga. Setiap login baru berarti satu lagi kata sandi yang harus diingat, satu lagi titik data pribadi yang tersimpan di server entah di mana, dan satu lagi ketergantungan pada layanan yang bisa saja berubah kebijakan atau tutup sewaktu-waktu.

Authentik hadir sebagai jawaban atas masalah ini. Ini adalah Identity Provider (IdP) open-source yang memungkinkan Anda mengelola autentikasi dan otorisasi untuk semua layanan self-hosted Anda dari satu titik terpusat. Dengan Authentik, Anda mendapatkan:

- Single Sign-On (SSO) sejati — login sekali, akses semua layanan yang terintegrasi
- Kendali penuh atas data identitas — kredensial dan metadata pengguna tetap di infrastruktur Anda
- Dukungan protokol standar — OAuth2, OpenID Connect (OIDC), SAML, LDAP, dan lainnya
- Manajemen pengguna dan grup — kontrol akses berbasis peran (RBAC) yang granular
- Multi-factor authentication (MFA) — lapisan keamanan tambahan tanpa ketergantungan pihak ketiga
- Audit log lengkap — lacak setiap upaya autentikasi dan perubahan konfigurasi

Dalam ekosistem Digital Independence, Authentik berfungsi sebagai "gerbang utama" yang menghubungkan puluhan layanan — dari Nextcloud, Immich, hingga Matrix — ke dalam satu sistem identitas yang kohesif. Ini bukan sekadar alat teknis, ini adalah fondasi kedaulatan digital Anda.

## Memahami Komponen Inti

Sebelum terjun ke deployment, penting untuk memahami bagaimana Authentik bekerja. Arsitektur Authentik terdiri dari empat komponen utama yang saling terhubung:

### 1. Server — Otak dari Sistem

Komponen `server` adalah inti dari Authentik. Ini menangani:
- Antarmuka web (UI) untuk manajemen
- Endpoint autentikasi (OAuth2, OIDC, SAML)
- API untuk integrasi eksternal
- Sesi pengguna dan token

Server berjalan sebagai aplikasi Python (Django) yang di-serve melalui port 9000 (HTTP) dan 9443 (HTTPS). Dalam konfigurasi `compose.yaml`, server di-deploy dengan:

```yaml
server:
  image: ${AUTHENTIK_IMAGE:-ghcr.io/goauthentik/server:latest}
  command: server
  ports:
    - "${COMPOSE_PORT_HTTP:-9000}:9000"
    - "${COMPOSE_PORT_HTTPS:-9443}:9443"
```

### 2. Worker — Tenaga Kerja di Balik Layar

Komponen `worker` menjalankan tugas-tugas asinkron:
- Sinkronisasi dengan direktori eksternal (LDAP, Active Directory)
- Pengiriman email notifikasi
- Pemrosesan event dan audit log
- Pembersihan sesi kedaluwarsa

Worker menggunakan image yang sama dengan server tetapi menjalankan perintah `worker` alih-alih `server`. Keduanya berbagi volume `media` dan `certs` untuk akses data yang konsisten.

### 3. PostgreSQL — Penyimpanan Data Persisten

Semua data konfigurasi, pengguna, grup, dan audit log disimpan dalam database PostgreSQL. Dalam konfigurasi ini, PostgreSQL 18 Alpine digunakan dengan:

- Health check untuk memastikan database siap sebelum server dimulai
- Resource limits (2GB memory, 2 CPU) untuk mencegah konsumsi berlebihan
- Security hardening — `no-new-privileges`, `cap_drop: ALL` dengan pengecualian minimal

### 4. Redis — Cache dan Sesi

Redis berfungsi sebagai:
- Cache untuk sesi pengguna
- Message broker untuk komunikasi antara server dan worker
- Penyimpanan sementara untuk token dan state OAuth

Konfigurasi Redis di sini menggunakan autentikasi password (`REDIS_PASSWORD`) dan kebijakan `allkeys-lru` untuk manajemen memori yang efisien.

### Diagram Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                         INTERNET                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREWALL (IPC)                           │
│              Default-Deny, Port 9000/9443                   │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   AUTHENTIK SERVER                          │
│         (UI, OAuth2/OIDC, SAML, API Endpoint)               │
│                    Port 9000/9443                           │
└─────────┬───────────────────────────────┬───────────────────┘
          │                               │
          ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│   AUTHENTIK WORKER  │         │   AUTHENTIK REDIS   │
│  (Background Tasks) │◄───────►│   (Cache & Broker)  │
└─────────┬───────────┘         └─────────────────────┘
          │
          ▼
┌─────────────────────┐
│   POSTGRESQL DB     │
│  (Users, Config,    │
│   Audit Logs)       │
└─────────────────────┘
```

## Prasyarat

Sebelum memulai, pastikan sistem Anda memenuhi persyaratan berikut:

| Komponen       | Versi Minimum         | Catatan                                           |
| -------------- | --------------------- | ------------------------------------------------- |
| Podman         | 5.4+                  | Mode rootless untuk keamanan                      |
| podman-compose | v1.3+                 | Orkestrasi container                              |
| Git            | Terbaru               | Clone repositori                                  |
| OS             | Linux (Debian/Ubuntu) | Atau WSL2                                         |
| Memori         | 4GB+                  | Authentik membutuhkan ~3.5GB untuk semua komponen |
| Penyimpanan    | 10GB+                 | Tergantung jumlah pengguna dan log                |

### Instalasi Podman dan Dependensi

Repositori Digital Independence menyediakan script instalasi otomatis:

```bash
git clone https://git.ricalnet.my.id/rical/digital-independence.git ~/digital-independence
cd ~/digital-independence
./install-podman-on-debian.sh
```

Script ini akan:
1. Memperbarui sistem dan menginstal Podman
2. Menginstal `uidmap`, `slirp4netns`, `dbus-user-session`, dan `fuse-overlayfs`
3. Mengaktifkan `linger` untuk user Anda (agar container tetap berjalan setelah logout)
4. Menginstal `podman-compose`
5. Mengonfigurasi registri container
6. Mengaktifkan Podman socket untuk integrasi dengan Portainer dan Homarr
7. Menyiapkan wrapper `dipen` di `.bashrc` dan `.zshrc`

Mengapa rootless? Podman rootless menjalankan container tanpa hak akses root, mengurangi risiko eskalasi privilege jika terjadi kompromi. Ini adalah praktik keamanan terbaik untuk self-hosting.

## Langkah Deployment: Dari Nol hingga Berjalan

### Langkah 1: Konfigurasi Environment

Setiap layanan dalam ekosistem Digital Independence memiliki file `.env.example` yang perlu disalin dan disesuaikan. Gunakan alat `dipen` untuk membuat dan mengedit file `.env` secara otomatis:

```bash
dipen env authentik
```

Perintah ini akan:
- Menyalin `.env.example` menjadi `.env` jika belum ada
- Membuka editor (default: `nano`) untuk Anda edit

Variabel kunci yang wajib dikonfigurasi:

| Variabel               | Deskripsi            | Contoh                    |
| ---------------------- | -------------------- | ------------------------- |
| `PG_PASS`              | Password PostgreSQL  | `openssl rand -base64 32` |
| `REDIS_PASSWORD`       | Password Redis       | `openssl rand -base64 32` |
| `AUTHENTIK_SECRET_KEY` | Secret key Authentik | `openssl rand -base64 60` |
| `COMPOSE_PORT_HTTP`    | Port HTTP            | `9000`                    |
| `COMPOSE_PORT_HTTPS`   | Port HTTPS           | `9443`                    |

Gunakan `openssl rand -base64 32` untuk menghasilkan password yang kuat dan unik. Jangan pernah menggunakan password default atau yang mudah ditebak.
{: .prompt-tip}

### Langkah 2: Memulai Layanan

Setelah konfigurasi selesai, mulai layanan dengan:

```bash
dipen up authentik
```

Atau jika Anda ingin melihat output secara langsung:

```bash
dipen up -d
```

Perintah `dipen up` akan:
1. Membaca file `compose.yaml`
2. Menjalankan `podman-compose up -d` di direktori `authentik/`
3. Memulai semua container dalam mode detached

Apa yang terjadi di balik layar?

1. Podman membuat network `authentik` (internal bridge)
2. Volume `authentik_postgresql`, `authentik_redis`, `authentik_media`, `authentik_certs`, dan `authentik_templates` dibuat
3. Container PostgreSQL dan Redis dimulai terlebih dahulu
4. Health check memastikan kedua database siap
5. Container server dan worker dimulai setelah dependensi sehat

### Langkah 3: Verifikasi Deployment

Pantau log untuk memastikan semua komponen berjalan dengan baik:

```bash
dipen logs -f authentik
```

Atau periksa status container:

```bash
dipen ps authentik
```

Anda akan melihat output seperti:

```
CONTAINER ID  IMAGE                                    COMMAND     CREATED         STATUS                   PORTS
abc123def456  ghcr.io/goauthentik/server:latest        server      2 minutes ago   Up 2 minutes (healthy)   0.0.0.0:9000->9000/tcp
def456ghi789  ghcr.io/goauthentik/server:latest        worker      2 minutes ago   Up 2 minutes (healthy)
ghi789jkl012  docker.io/postgres:18-alpine             postgres    2 minutes ago   Up 2 minutes (healthy)
jkl012mno345  docker.io/redis:alpine                   redis       2 minutes ago   Up 2 minutes (healthy)
```

### Langkah 4: Akses Antarmuka Web

Buka browser dan akses:

```
http://localhost:9000
```

Atau jika Anda mengakses dari mesin lain:

```
http://<IP-SERVER>:9000
```

Anda akan disambut dengan halaman setup awal Authentik. Ikuti wizard untuk membuat akun administrator pertama.

> Jika Anda mengakses dari luar localhost, pastikan port 9000 sudah dibuka di firewall menggunakan IPC:
> ```bash
> sudo ipc enable 9000 both tcp
> ```
{: .prompt-info}

## Konfigurasi Firewall dengan IPC: Keamanan Berlapis

Digital Independence menyertakan IPC (Iptables Port Controller) — alat manajemen firewall yang menerapkan kebijakan `default-deny`. Ini berarti semua koneksi masuk ditolak kecuali port yang secara eksplisit dibuka.

### Mengapa Default-Deny?

Pendekatan default-deny adalah prinsip keamanan fundamental: "apa yang tidak diizinkan, dilarang." Dengan hanya membuka port yang benar-benar diperlukan, Anda meminimalkan attack surface secara drastis.

### Setup Awal IPC

```bash
# Setup persistence (aturan tetap berlaku setelah reboot)
sudo ipc setup-persistence

# Inisialisasi firewall (default-deny)
sudo ipc init

# Buka port SSH (jika belum)
sudo ipc enable 22 both tcp

# Buka port Authentik (jika perlu akses eksternal)
sudo ipc enable 9000 both tcp
sudo ipc enable 9443 both tcp
```

### Verifikasi Aturan Firewall

```bash
sudo ipc status
```

Output akan menunjukkan port mana yang terbuka dan aturan aktif lainnya.

Untuk layanan yang terikat ke `127.0.0.1` (localhost), Anda tidak perlu membuka port di firewall. Ini adalah konfigurasi default yang aman untuk layanan yang hanya diakses melalui reverse proxy atau Cloudflare Tunnel.

## Integrasi dengan Layanan Lain

Salah satu kekuatan utama Authentik adalah kemampuannya terintegrasi dengan layanan lain. Berikut adalah beberapa contoh integrasi dengan layanan dalam ekosistem Digital Independence:

- [Panduan Integrasi Nextcloud dengan Authentik via OIDC](https://docs.ricalnet.my.id/posts/panduan-integrasi-nextcloud-dengan-authentik-via-oidc/)
- [Panduan Integrasi Immich dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-immich-dengan-authentik/)
- [Panduan Integrasi Autentikasi OIDC Homarr dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-autentikasi-oidc-homarr-dengan-authentik/)
- [Panduan Integrasi Open WebUI dengan authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-open-webui-dengan-authentik/)
- [Panduan Integrasi Synapse dengan Authentik untuk Autentikasi SSO](https://docs.ricalnet.my.id/posts/panduan-integrasi-synapse-dengan-authentik-untuk-autentikasi-sso/)
- [Panduan Integrasi Vaultwarden dengan Authentik sebagai SSO Provider](https://docs.ricalnet.my.id/posts/panduan-integrasi-vaultwarden-dengan-authentik-sebagai-sso-provider/)

### Tabel Perbandingan Protokol Autentikasi

| Protokol    | Kelebihan                                              | Kekurangan                                      | Cocok Untuk                        |
| ----------- | ------------------------------------------------------ | ----------------------------------------------- | ---------------------------------- |
| OAuth2/OIDC | Standar modern, mudah diintegrasikan, mendukung mobile | Memerlukan konfigurasi per layanan              | Sebagian besar aplikasi web modern |
| SAML 2.0    | Enterprise-ready, mendukung SSO kompleks               | Lebih rumit, XML-based                          | Aplikasi enterprise, legacy        |
| LDAP        | Cocok untuk direktori pengguna, banyak didukung        | Tidak untuk SSO modern, plaintext               | Aplikasi legacy, internal tools    |
| Proxy Auth  | Sederhana, tidak perlu modifikasi aplikasi             | Kurang fleksibel, bergantung pada reverse proxy | Aplikasi yang tidak mendukung SSO  |

## Praktik Terbaik

### 1. Hardening Container

Konfigurasi `compose.authentik.yaml` sudah menerapkan praktik keamanan berikut:

| Fitur               | Implementasi                             | Manfaat                              |
| ------------------- | ---------------------------------------- | ------------------------------------ |
| `no-new-privileges` | `security_opt: no-new-privileges=true`   | Mencegah eskalasi privilege          |
| `cap_drop`          | `cap_drop: ALL` + pengecualian minimal   | Mengurangi kemampuan container       |
| `read_only`         | `read_only: true` pada server & worker   | Mencegah modifikasi filesystem       |
| `tmpfs`             | `/tmp`, `/run`, `/var/run` sebagai tmpfs | Mencegah penulisan ke disk           |
| `Resource limits`   | Memory, CPU, PIDs limits                 | Mencegah DoS dan konsumsi berlebihan |
| `Health checks`     | Untuk semua komponen                     | Deteksi dini kegagalan               |

### 2. Manajemen Secret

- Gunakan password yang kuat dan unik untuk setiap layanan
- Simpan secret di file `.env` dengan izin `chmod 600`
- Jangan pernah commit file `.env` ke repositori Git
- Gunakan Vaultwarden (tersedia di ekosistem Digital Independence) untuk menyimpan secret

### 3. Jaringan

- Layanan terikat ke `127.0.0.1` secara default
- Gunakan Cloudflare Tunnel atau Tor Hidden Service untuk akses eksternal tanpa membuka port
- Aktifkan HTTPS dengan sertifikat yang valid
- Gunakan IPC untuk mengontrol port yang terbuka

### 4. Audit dan Monitoring

- Aktifkan audit log di Authentik untuk melacak semua event autentikasi
- Integrasikan dengan Wazuh (tersedia di ekosistem) untuk deteksi ancaman
- Gunakan Uptime Kuma untuk memantau ketersediaan layanan
- Atur notifikasi melalui ntfy untuk peringatan real-time

### 5. Backup Rutin

Gunakan Chantik — alat backup terenkripsi yang disertakan dalam ekosistem Digital Independence:

```bash
# Backup harian (tambahkan ke cron)
0 2 * * * /path/to/digital-independence/chantik backup
```

Chantik menggunakan enkripsi ChaCha20-Poly1305 dengan derivasi kunci PBKDF2 (600.000 iterasi), memastikan data backup Anda aman bahkan jika disimpan di penyimpanan eksternal.

## Cron Jobs untuk Pemeliharaan

Digital Independence menyediakan beberapa script otomatisasi yang dapat dijadwalkan dengan cron. Berikut adalah contoh konfigurasi cron untuk Authentik:

```bash
# Edit crontab pengguna
crontab -e

# Tambahkan baris berikut:

# Backup Authentik harian - jam 2 pagi
0 2 * * * /path/to/digital-independence/chantik backup authentik

# Update container Authentik mingguan - Minggu jam 6 pagi
0 6 * * 0 /path/to/digital-independence/dipen.sh update authentik

# Prune resource tidak terpakai mingguan - Minggu jam 11 siang
0 11 * * 0 /path/to/digital-independence/dipen.sh prune all
```

> Semua cron job berjalan dalam mode rootless. Jangan pernah menggunakan `sudo` dengan perintah podman di cron.
{: .prompt-tip}

## Troubleshooting

### 1. Container Gagal Start

Gejala: Container exited atau restart loop.

Solusi:
```bash
# Periksa log
dipen logs authentik

# Periksa status container
podman ps -a --filter "name=authentik"

# Periksa resource
podman stats
```

Penyebab umum:
- Password database tidak cocok
- Port sudah digunakan
- Resource tidak mencukupi

### 2. Tidak Bisa Akses Web UI

Gejala: Koneksi ditolak atau timeout.

Solusi:
```bash
# Periksa apakah container berjalan
dipen ps authentik

# Periksa port binding
podman port authentik-server

# Periksa firewall
sudo ipc status

# Periksa log
dipen logs authentik
```

### 3. Database Connection Error

Gejala: Log menunjukkan error koneksi ke PostgreSQL.

Solusi:
```bash
# Periksa health check PostgreSQL
podman exec authentik-postgresql pg_isready -U authentik

# Periksa environment variable
podman exec authentik-server env | grep POSTGRES

# Pastikan password cocok
grep PG_PASS authentik/.env
```

### 4. Performa Lambat

Gejala: UI lambat, autentikasi memakan waktu.

Solusi:
- Tambah alokasi memori di `compose.yaml`
- Periksa penggunaan resource dengan `podman stats`
- Aktifkan Redis untuk caching
- Kurangi jumlah worker jika CPU terbatas

### 5. Lupa Password Admin

Gejala: Tidak bisa login ke Authentik.

Solusi:
```bash
# Reset password admin
podman exec -it authentik-server ak create_admin_group
podman exec -it authentik-server ak change_password --username admin
```

## Kesimpulan

Authentik bukan sekadar alat teknis — ini adalah fondasi kedaulatan digital Anda. Dengan mengelola identitas secara mandiri, Anda:

- Memutus ketergantungan pada penyedia identitas pihak ketiga (Google, Facebook, GitHub)
- Mengontrol penuh data pribadi dan metadata pengguna
- Meningkatkan keamanan dengan kebijakan akses terpusat dan MFA
- Menyederhanakan pengalaman pengguna dengan SSO yang mulus
- Membangun keterampilan DevOps melalui praktik langsung

Dalam ekosistem Digital Independence yang lebih luas, Authentik adalah simpul yang menghubungkan semua layanan menjadi satu sistem yang kohesif. Dikombinasikan dengan Podman rootless, firewall IPC, backup terenkripsi Chantik, dan otomatisasi cron, Anda memiliki infrastruktur digital yang sepenuhnya mandiri, aman, dan dapat diandalkan.

Langkah selanjutnya:
1. Jelajahi layanan lain dalam ekosistem Digital Independence (`dipen list`)
2. Integrasikan Authentik dengan layanan yang Anda gunakan
3. Aktifkan MFA untuk semua akun
4. Setup backup rutin dengan Chantik
5. Pantau dengan Wazuh dan Uptime Kuma

Kedaulatan digital bukan tentang menolak teknologi — ini tentang memilih siapa yang mengendalikannya. Dan dengan Authentik, kendali itu ada di tangan Anda.

## Referensi

| Sumber Daya                     | Tautan                                                                                                                                                 |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Repositori Digital Independence | [git.ricalnet.my.id/rical/digital-independence](https://git.ricalnet.my.id/rical/digital-independence)                                                 |
| Wiki Resmi                      | [Digital Independence Wiki](https://git.ricalnet.my.id/rical/digital-independence/wiki)                                                                |
| Dokumentasi IPC                 | [Iptables Port Controller](https://git.ricalnet.my.id/rical/digital-independence/wiki/Iptables-Port-Controller-%E2%80%94-Firewall)                     |
| Chantik Backup Tool             | [Encrypted Backup Protection](https://git.ricalnet.my.id/rical/digital-independence/wiki/Chantik+%E2%80%94+ChaCha20-Authenticated+Backup+Protection.-) |
| Authentik Official              | [goauthentik.io](https://goauthentik.io/)                                                                                                              |
| Podman Documentation            | [podman.io/docs](https://podman.io/docs)                                                                                                               |