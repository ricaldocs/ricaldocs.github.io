---
title: Membangun Infrastruktur Digital Mandiri dari Nol
description: Ingin lepas dari raksasa teknologi? Pelajari cara membangun infrastruktur digital mandiri dari nol dengan Podman—orkestrasi 25+ layanan self-hosted dalam 15 menit, pengamanan firewall dengan IPC (Iptables Port Controller), dan backup terenkripsi ChaCha20 menggunakan Chantik.
categories: [Digital Independence]
tags: [self-hosted, docker, podman, privacy, firewall, chantik, chacha20]
author: rical
last_modified_at: 2026-09-17
pin: true
image:
  path: /assets/img/posts/2026-04-03-membangun-infrastruktur-digital-mandiri-dari-nol/thumbnail.png
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
---

## Mengapa Infrastruktur Digital Mandiri Itu Penting

Anda membaca ini dari ponsel atau komputer yang sistem operasinya milik perusahaan asing, terhubung ke jaringan yang dipantau, dan menyimpan data di server yang tak bisa Anda jangkau. Lalu Anda merasa punya privasi. Lucu.

Di Indonesia, ini bukan teori. Data warga disimpan di yurisdiksi asing, akun bisa diblokir sepihak, harga naik tanpa negosiasi—dan kita hanya bisa mengeluh di media sosial yang juga bukan milik kita. Kedaulatan digital bukan slogan; ini soal siapa yang memegang kunci data Anda.

Self-hosted membalik logika itu. Data di perangkat Anda, tidak ada yang memonetisasi, konfigurasi milik Anda. Privasi bukan fitur yang bisa dicabut, keamanan bukan celah yang menunggu, kemandirian bukan utopia. Modalnya? Komputer bekas atau Raspberry Pi sekecil dompet, listrik, dan internet. Itu saja.

Membangunnya dianggap rumit—wajar, selama Anda masih mengetik perintah seperti tahun 2015 sambil berharap firewall tidak salah konfigurasi. Dipen mematahkan itu dengan 25+ layanan, satu CLI, 15 menit. Panduan ini memandu dari nol hingga layanan pertama berjalan.

## Prasyarat
- [git.ricalnet.my.id/rical/digital-independence](https://git.ricalnet.my.id/rical/digital-independence)
- Sistem operasi Debian-based Linux
- Akses `sudo` untuk konfigurasi firewall

## Alur Implementasi

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     Clone &     │───▶│     Konfigurasi  │───▶│     Jalankan    │
│     Instalasi   │    │     .env         │    │     Layanan     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │    Verifikasi   │
                                               │    & Monitor    │
                                               └─────────────────┘
```

## 1. Instalasi

### 1.1 Clone Repositori

```bash
git clone https://git.ricalnet.my.id/rical/digital-independence.git ~/digital-independence
cd ~/digital-independence
```

### 1.2 Instal Podman dan Dependensi

```bash
./install-podman-on-debian.sh
```

Script instalasi menyediakan komponen berikut:

| Komponen       | Fungsi                              |
| -------------- | ----------------------------------- |
| Podman         | Mesin container rootless            |
| podman-compose | Orkestrasi Compose                  |
| dipen          | CLI orkestrasi layanan              |
| ipc            | Iptables Port Controller (firewall) |

Verifikasi instalasi:

```bash
podman --version
podman-compose --version
dipen version
```

## 2. Daftar Layanan

```bash
dipen list
```

Menampilkan seluruh layanan yang tersedia beserta direktori dan port default. Total tersedia 27 layanan, mencakup:

```bash
Available Services:

  authentik            → authentik
  dashdot              → dashdot
  element-web          → element-web
  forgejo              → forgejo
  homarr               → homarr
  immich               → immich
  jellyfin             → jellyfin
  libretranslate       → libretranslate
  linkstack            → linkstack
  mastodon             → mastodon
  mediawiki            → wiki
  monitoring           → monitoring
  mqtt                 → mqtt-broker
  navidrome            → navidrome
  nextcloud            → nextcloud
  ntfy                 → ntfy
  obfs4-bridge         → obfs4-bridge
  open-webui           → open-webui
  pi-hole              → pi-hole
  portainer            → portainer
  searxng              → searxng
  synapse              → synapse
  synapse-mautrix      → synapse/mautrix
  uptime-kuma          → uptime-kuma
  vaultwarden          → vaultwarden
  wazuh                → wazuh
  yourls               → yourls

Total: 27 services
```

> Gunakan wildcard untuk mencocokkan beberapa layanan sekaligus, misalnya `dipen env n*` untuk semua layanan berawalan huruf **n**.
{: .prompt-tip}

## 3. Konfigurasi Environment

```bash
dipen env <service1> <service2> <service3>
```

Contoh:

```bash
dipen env nextcloud open-webui authentik
```

Perintah ini akan:

1. Membuat file `.env` dari `.env.example` (jika belum ada)
2. Membuka editor default (`nano` atau `vim`)
3. Memungkinkan perubahan kata sandi default, kunci API, dan konfigurasi lainnya

## 4. Menjalankan Layanan

### 4.1 Mulai Layanan Tertentu

```bash
dipen up nextcloud open-webui authentik
```

Proses yang dijalankan:

1. Membangun/mengunduh image container
2. Membuat network dan volume yang diperlukan
3. Menjalankan container dalam mode detached
4. Menampilkan status startup

> Startup pertama memerlukan waktu beberapa menit tergantung ukuran image dan koneksi internet.
{: .prompt-info}

### 4.2 Mulai Semua Layanan

```bash
dipen all up
```

> Hanya jalankan apabila sumber daya mencukupi. 25 layanan membutuhkan setidaknya 16 GB RAM.
{: .prompt-danger}

## 5. Verifikasi & Monitoring

### 5.1 Cek Status

```bash
dipen ps <service1> <service2> <service3>
```

Status yang diharapkan: `Up` atau `Up (healthy)`.

### 5.2 Lihat Log

```bash
dipen logs nextcloud open-webui authentik
```

Menampilkan 50 baris log terakhir per layanan. Berguna untuk:

- Memverifikasi layanan berjalan dengan benar
- Mendiagnosis error saat startup
- Memantau aktivitas layanan

### 5.3 Akses Layanan

| Contoh Layanan | URL Akses                       |
| -------------- | ------------------------------- |
| Nextcloud      | `http://127.0.0.1:5000`         |
| Open WebUI     | `http://127.0.0.1:3000`         |
| Authentik      | `http://127.0.0.1:9000`         |
| Vaultwarden    | `http://127.0.0.1:8000`         |
| Pi-hole        | `http://192.168.0.1:8080/admin` |

> Semua layanan terikat ke `127.0.0.1` (localhost) secara default. Untuk akses eksternal, gunakan IPC, Tor Hidden Service, atau Cloudflare Tunnel.
{: .prompt-tip}

### 5.4 Monitoring Stack (Prometheus + Grafana)

Setelah layanan berjalan, langkah berikutnya adalah observability. Untuk membangun monitoring stack lengkap — Prometheus, Grafana, Node Exporter, Podman Exporter, dan Alertmanager dengan notifikasi Ntfy — ikuti panduan terpisah:

📖 [Panduan Lengkap Deploy Monitoring Stack Self-Hosted dengan Podman, Prometheus, dan Grafana](https://docs.ricalnet.my.id/posts/panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/)

Panduan tersebut mencakup verifikasi end-to-end, import 4 dashboard siap pakai (Node Exporter Full, Alertmanager, Prometheus, Podman Exporter), serta integrasi Ntfy untuk alert push. Monitoring stack ini melengkapi lapisan observability dari infrastruktur yang baru Anda bangun.

> Untuk deployment skala kecil (2–3 layanan), monitoring stack penuh bersifat over-provisioned. Gunakan Homarr + dashdot (`dipen up dashdot`) — visibilitas host memadai, footprint minimal, tanpa overhead Prometheus/Grafana.
{: .prompt-tip}


## 6. Konfigurasi Firewall (Opsional)

Diperlukan apabila layanan harus diakses dari luar localhost.

```bash
# Setup persistence (sekali saja)
sudo ipc setup-persistence

# Inisialisasi firewall (default-deny)
sudo ipc init

# Buka port yang diperlukan
sudo ipc enable 22     # SSH
sudo ipc enable 5000   # Nextcloud
sudo ipc enable 3000   # Open WebUI
sudo ipc enable 9000   # Authentik

# Verifikasi status
sudo ipc status
```

> Dokumentasi lengkap: [Iptables Port Controller — Firewall](https://git.ricalnet.my.id/rical/digital-independence/wiki/Iptables-Port-Controller-%E2%80%94-Firewall)
{: .prompt-tip}

## 7. Akses Publik

Setelah layanan berjalan di localhost, pilih salah satu dari dua pendekatan berikut untuk akses eksternal.

### 7.1 Perbandingan Singkat

| Aspek         | Tor Hidden Service                  | Cloudflare Tunnel                   |
| ------------- | ----------------------------------- | ----------------------------------- |
| Privasi       | Maksimal — IP tersembunyi           | Bergantung pada Cloudflare          |
| Akses         | Hanya via Tor Browser               | Browser biasa                       |
| Domain        | Tidak perlu                         | Wajib di Cloudflare                 |
| Port firewall | Tidak dibuka                        | Tidak dibuka (outbound-only)        |
| Cocok untuk   | Privasi tinggi, aktivis, jurnalisme | Akses publik umum, tim, development |

> Keduanya dapat dikombinasikan: Cloudflare Tunnel untuk akses publik, Tor untuk akses privat berlapis.
{: .prompt-tip}

### 7.2 Hidden Service Tor — Privasi Maksimal

Menyembunyikan IP server dan mengenkripsi lalu lintas end-to-end. Layanan hanya diakses via Tor menggunakan alamat `.onion`.

📖 [Panduan Implementasi Hidden Service Tor](https://docs.ricalnet.my.id/posts/panduan-implementasi-hidden-service-tor/)

Pilih jika butuh privasi maksimal dan anonimitas — cocok untuk server internal, jurnalisme investigatif, atau organisasi dengan kebutuhan privasi tinggi.

> Bukan pengganti keamanan aplikasi. Tetap terapkan autentikasi dan pastikan aplikasi hanya listening di `127.0.0.1`.
{: .prompt-warning}

### 7.3 Cloudflare Tunnel — Kemudahan Akses

Mengekspos layanan ke internet tanpa membuka port firewall melalui koneksi outbound ke Cloudflare.

📖 [Panduan Lengkap Mengonfigurasi Cloudflare Tunnel](https://docs.ricalnet.my.id/posts/panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/)

Pilih jika butuh akses publik via browser biasa, punya domain sendiri, dan ingin menghindari konfigurasi firewall tradisional — ideal untuk remote access dan hosting aplikasi internal.

## 8. Backup Terenkripsi dengan Chantik

Chantik adalah tool backup terenkripsi ChaCha20 untuk direktori dan volume container (Podman/Docker). Mendukung incremental backup, rotasi retensi, deduplikasi, dan notifikasi ntfy.

### 8.1 Instalasi

```bash
git clone https://git.ricalnet.my.id/rical/chantik ~/chantik
cd ~/chantik
```

### 8.2 Tambahkan Alias (Direkomendasikan)

Agar tidak perlu mengetik path lengkap setiap kali, tambahkan alias ke shell config:

```bash
echo "alias chantik='$(pwd)/chantik.sh'" >> ~/.bashrc
source ~/.bashrc

# atau untuk zsh

echo "alias chantik='$(pwd)/chantik.sh'" >> ~/.zshrc
source ~/.zshrc
```

Verifikasi:

```bash
chantik help
```

### 8.3 Konfigurasi

```bash
cp chantik.example.conf chantik.conf

openssl rand -base64 32 > encryption.key
chmod 600 encryption.key

nano chantik.conf
```

Sesuaikan `BACKUP_BASE_DIR`, `SOURCE_DIR`, `ENCRYPTION_KEY_FILE`, `NTFY_TOPIC`, `NTFY_TOKEN`, dan daftar volume.

> Simpan `encryption.key` terpisah dari backup. Tanpa kunci ini, backup tidak bisa dipulihkan.
{: .prompt-danger}

### 8.4 Menjalankan Backup

```bash
chantik
```

Proses:

```
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Deteksi    │──▶│   Snapshot   │──▶│    Backup    │──▶│  Kompresi    │
│   Runtime    │   │    Volume    │   │ Full/Inc     │   │    gzip      │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
                                                                │
                                                                ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Notifikasi  │◀──│   Rotasi     │◀──│  Verifikasi  │◀──│   Enkripsi   │
│    ntfy      │   │  Retensi     │   │   SHA256     │   │   ChaCha20   │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
```

### 8.5 Melihat Daftar Backup

```bash
chantik list
```

### 8.6 Restore

```bash
chantik restore <nama_backup>
```

Contoh:

```bash
chantik restore postgres
chantik restore volume_postgres volume_redis
chantik restore --dry-run volume_postgres
```

Chantik otomatis membuat pre-restore backup, meminta konfirmasi ganda, lalu mendekripsi dan menerapkan ke target.

### 8.7 Perintah Lain

```bash
chantik verify <file>     # Verifikasi satu backup
chantik verify-all        # Verifikasi semua backup
chantik dedup             # Deduplikasi
chantik test              # Uji enkripsi ChaCha20
chantik help              # Bantuan
```

### 8.8 Backup Otomatis (Cron)

```
0 2 * * * cd ~/chantik && ./chantik.sh >> ~/chantik/cron.log 2>&1
```

### 8.9 Peran dalam Stack

| Lapisan      | Tool               | Melindungi dari              |
| ------------ | ------------------ | ---------------------------- |
| Jaringan     | IPC (iptables)     | Akses tidak sah              |
| Data at-rest | Chantik (ChaCha20) | Kebocoran backup, ransomware |

> Dokumentasi lengkap: [Chantik — ChaCha20-Authenticated Backup Protection](https://git.ricalnet.my.id/rical/digital-independence/wiki/Chantik+%E2%80%94+ChaCha20-Authenticated+Backup+Protection.-)
{: .prompt-tip}

## 9. Referensi Layanan Spesifik

### AI
- [Implementasi Model AI Berbasis Open Source Secara Offline pada Perangkat Android](https://docs.ricalnet.my.id/posts/implementasi-model-ai-berbasis-open-source-secara-offline-pada-perangkat-android/)

### Android
- [Cara Install /e/OS di Xiaomi Poco F4 (Munch)](https://docs.ricalnet.my.id/posts/cara-install-eos-di-xiaomi-poco-f4-munch/)
- [Panduan Instalasi MicroG di Android untuk Pemula dan Pengguna Advanced](https://docs.ricalnet.my.id/posts/panduan-instalasi-microg-di-android-untuk-pemula-dan-pengguna-advanced/)

### Cloud
- [Panduan Lengkap Instalasi Nextcloud untuk Digital Independence](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-nextcloud-untuk-digital-independence/)
- [Panduan Konfigurasi External Storage di Nextcloud](https://docs.ricalnet.my.id/posts/panduan-konfigurasi-external-storage-di-nextcloud/)

### Communications
- [Instalasi dan Konfigurasi Pi-hole untuk Blokir Iklan di Seluruh Jaringan](https://docs.ricalnet.my.id/posts/instalasi-dan-konfigurasi-pi-hole-untuk-blokir-iklan-di-seluruh-jaringan/)
- [Panduan Aktivis untuk Menyebarkan Tor Bridge Obfs4](https://docs.ricalnet.my.id/posts/panduan-aktivis-untuk-menyebarkan-tor-bridge-obfs4/)
- [Panduan Deployment Matrix Synapse Self-Hosted dengan Mautrix Bridge WhatsApp dan Telegram](https://docs.ricalnet.my.id/posts/panduan-deployment-matrix-synapse-self-hosted-dengan-mautrix-bridge-whatsapp-dan-telegram/)

### Dashboard
- [Cara Install Homarr — Dashboard Server Modern dan Rapi](https://docs.ricalnet.my.id/posts/cara-install-homarr-dashboard-server-modern-dan-rapi/)

### Monitoring
- [Panduan Lengkap Deploy Monitoring Stack Self-Hosted dengan Podman, Prometheus, dan Grafana](https://docs.ricalnet.my.id/posts/panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/)
- [Panduan Lengkap Instalasi dan Konfigurasi Wazuh](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-dan-konfigurasi-wazuh/)

### Multimedia
- [Instalasi Jellyfin untuk Media Server Pribadi](https://docs.ricalnet.my.id/posts/instalasi-jellyfin-untuk-media-server-pribadi/)

### Password Manager
- [Panduan Self-Hosting Vaultwarden untuk Password Manager Mandiri](https://docs.ricalnet.my.id/posts/panduan-self-hosting-vaultwarden-untuk-password-manager-mandiri/)

### Single Sign-On (SSO)
- [Panduan Self-Hosting Authentik untuk Digital Independence](https://docs.ricalnet.my.id/posts/panduan-self-hosting-authentik-untuk-digital-independence/)

#### Integrasi dengan Authentik
- [Panduan Integrasi Autentikasi OIDC Homarr dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-autentikasi-oidc-homarr-dengan-authentik/)
- [Panduan Integrasi Forgejo dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-forgejo-dengan-authentik/)
- [Panduan Integrasi Grafana dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-grafana-dengan-authentik/)
- [Panduan Integrasi Immich dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-immich-dengan-authentik/)
- [Panduan Integrasi Nextcloud dengan Authentik via OIDC](https://docs.ricalnet.my.id/posts/panduan-integrasi-nextcloud-dengan-authentik-via-oidc/)
- [Panduan Integrasi Open WebUI dengan Authentik](https://docs.ricalnet.my.id/posts/panduan-integrasi-open-webui-dengan-authentik/)
- [Panduan Integrasi Synapse dengan Authentik untuk Autentikasi SSO](https://docs.ricalnet.my.id/posts/panduan-integrasi-synapse-dengan-authentik-untuk-autentikasi-sso/)
- [Panduan Integrasi Vaultwarden dengan Authentik sebagai SSO Provider](https://docs.ricalnet.my.id/posts/panduan-integrasi-vaultwarden-dengan-authentik-sebagai-sso-provider/)

### Search Engine
- [Deploy SearXNG untuk Kedaulatan Data dan Privasi Pencarian](https://docs.ricalnet.my.id/posts/deploy-searxng-untuk-kedaulatan-data-dan-privasi-pencarian/)

### Social Networks
- [Panduan Implementasi Self-Hosted Social Media](https://docs.ricalnet.my.id/posts/panduan-implementasi-self-hosted-social-media/)

### Telecommunications
- [Deploy MQTT Broker dengan Podman — Panduan Teknis Eclipse Mosquitto](https://docs.ricalnet.my.id/posts/deploy-mqtt-broker-dengan-podman-panduan-teknis-eclipse-mosquitto/)
- [Membangun VoIP Server](https://docs.ricalnet.my.id/posts/membangun-voip-server/)
- [Panduan Membangun 5G Core Sendiri Menggunakan Open5GS dan UERANSIM](https://docs.ricalnet.my.id/posts/panduan-membangun-5g-core-sendiri-menggunakan-open5gs-dan-ueransim/)
- [Uji Ketahanan 5G Core terhadap Serangan DDoS dengan Open5GS dan UERANSIM](https://docs.ricalnet.my.id/posts/uji-ketahanan-5g-core-terhadap-serangan-ddos-dengan-open5gs-dan-ueransim/)

### Wiki
- [Panduan Lengkap Instalasi MediaWiki untuk Digital Independence](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-mediawiki-untuk-digital-independence/)