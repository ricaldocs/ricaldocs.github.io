---
title: Panduan Lengkap Instalasi dan Konfigurasi Wazuh
description: Panduan teknis lengkap instalasi dan konfigurasi Wazuh single-node menggunakan Podman/Docker. Mencakup deployment Wazuh Indexer, Manager, Dashboard, generasi sertifikat TLS, manajemen kredensial BCrypt, hingga deployment Wazuh Agent pada endpoint Linux untuk kebutuhan SOC, monitoring, dan incident response.
categories: [Digital Independence, Monitoring]
tags: [wazuh, soc, linux, forensics, incident response, podman]
author: rical
last_modified_at: 2026-09-19
---

## Pendahuluan

Wazuh merupakan platform keamanan open-source yang menggabungkan kemampuan SIEM (Security Information and Event Management) dan XDR (Extended Detection and Response) dalam satu ekosistem terpadu. Arsitektur Wazuh terdiri dari tiga komponen utama yang saling terintegrasi: Wazuh Indexer (penyimpanan dan pengindeksan data), Wazuh Manager (analisis dan korelasi kejadian), serta Wazuh Dashboard (visualisasi dan manajemen). Ketiga komponen ini berjalan sebagai layanan terdistribusi yang berkomunikasi melalui protokol TLS.

Dokumentasi ini membahas proses deployment Wazuh Stack single-node menggunakan container runtime Podman beserta `podman-compose`, mencakup konfigurasi sertifikat, manajemen kredensial, hingga deployment agen pada endpoint. Pendekatan berbasis container dipilih karena memberikan isolasi dependensi, replikasi lingkungan yang konsisten, serta kemudahan rollback dibandingkan instalasi native.

## Deployment Wazuh Stack Single-Node Menggunakan Docker

### 1. Persiapan Repository

```bash
git clone https://git.ricalnet.my.id/rical/digital-independence.git ~/digital-independence
cd ~/digital-independence/wazuh
```

Repositori ini menyediakan manifest deployment yang telah dikurasi, mencakup `compose.yaml`, skrip instalasi Podman, serta direktori `config/` untuk konfigurasi per-komponen. Pemisahan direktori ini bertujuan agar perubahan konfigurasi tidak tercampur dengan definisi layanan.

### 2. Instalasi dipen

```bash
./install-podman-on-debian.sh
```

Skrip ini mengotomatisasi instalasi Podman pada sistem Debian, termasuk konfigurasi rootless container dan aktivasi socket API. Podman dipilih alih-alih Docker karena berjalan tanpa daemon privileged, sehingga mengurangi permukaan serangan pada host.

### 3. Generasi Sertifikat Self-Signed

```bash
podman-compose -f generate-indexer-certs.yml run --rm generator
```

Wazuh Indexer (berbasis OpenSearch) mewajibkan komunikasi internal antar-node melalui TLS. Karena deployment ini bersifat single-node dan tidak terhubung ke CA publik, sertifikat self-signed digunakan. Container `generator` akan menghasilkan:

- Root CA untuk otoritas sertifikat internal.
- Node certificate untuk Indexer.
- Admin certificate untuk operasi administratif.
- Dashboard certificate untuk komunikasi Dashboard ke Indexer.

Sertifikat disimpan di `config/wazuh_indexer_ssl_certs/` dan akan di-mount ke masing-masing container saat startup.

### 4. Konfigurasi Environment Variables

```bash
cp .env.example .env
nano .env
```

```bash
# Wazuh Image Configuration
WAZUH_MANAGER_IMAGE=docker.io/wazuh/wazuh-manager:4.14.7
WAZUH_INDEXER_IMAGE=docker.io/wazuh/wazuh-indexer:4.14.7
WAZUH_DASHBOARD_IMAGE=docker.io/wazuh/wazuh-dashboard:4.14.7

# Bind Address
WAZUH_BIND_ADDRESS=127.0.0.1
WAZUH_DASHBOARD_PORT=5601

# Indexer Credentials
INDEXER_USERNAME=admin
INDEXER_PASSWORD=CHANGE_ME_INDEXER_PASSWORD

# API Credentials
API_USERNAME=wazuh-wui
API_PASSWORD=CHANGE_ME_API_PASSWORD

# Dashboard Credentials
DASHBOARD_USERNAME=kibanaserver
DASHBOARD_PASSWORD=CHANGE_ME_API_PASSWORD
```

Mengapa dipisahkan dalam `.env`? Pemisahan kredensial dari definisi `compose.yaml` mencegah kebocoran rahasia ke version control. File `.env` seharusnya masuk `.gitignore` dan dikelola melalui secret manager pada lingkungan produksi.

> Nilai `127.0.0.1` membatasi akses Dashboard hanya dari loopback. Untuk akses eksternal, ubah ke `0.0.0.0` setelah menempatkan reverse proxy dengan TLS termination di depannya — jangan ekspos Dashboard langsung ke jaringan publik.
{: .prompt-tip}

### 5. Konfigurasi Dashboard Wazuh

```bash
cp config/wazuh_dashboard/wazuh.example.yml config/wazuh_dashboard/wazuh.yml
nano config/wazuh_dashboard/wazuh.yml
```

Struktur konfigurasi yang diperlukan:

```yaml
hosts:
  - 1513629884013:
      url: "https://wazuh.manager"
      port: 55000
      username: wazuh-wui
      password: "" # Menggunakan variable dari .env
      run_as: true
```

Field `url` mengarah ke nama layanan internal (`wazuh.manager`) yang di-resolve oleh DNS Podman pada network yang sama. `run_as: true` mengaktifkan role-based access control berbasis pengguna Wazuh API, bukan sekadar kredensial API global.

### 6. Manajemen Password Internal Users

```bash
cp config/wazuh_indexer/internal_users.example.yml config/wazuh_indexer/internal_users.yml
podman run --rm -it wazuh/wazuh-indexer:4.14.7 bash
```

Di dalam container:

```bash
cd /usr/share/wazuh-indexer/plugins/opensearch-security/tools/
./hash.sh -p "PasswordAnda"
```

Script `hash.sh` menggunakan algoritma BCrypt dengan salt generation untuk menghasilkan hash yang aman. Contoh output:

```
$2y$12$S9XQ5XQ5XQ5XQ5XQ5XQ5XQ5XQ5XQ5XQ5XQ5XQ
```

OpenSearch Security plugin tidak menerima password plaintext. Hash ini disimpan di `internal_users.yml` dan digunakan untuk autentikasi saat service startup. Setiap user (`admin`, `kibanaserver`, `kibanaro`, `logstash`) memerlukan hash yang berbeda — jangan gunakan hash yang sama untuk beberapa akun, karena akan melanggar prinsip least privilege dan menyulitkan rotasi kredensial.

Update file `config/wazuh_indexer/internal_users.yml`:

```yaml
admin:
  hash: "$2y$12$..."
  reserved: true
  backend_roles:
    - "admin"
  description: "Demo admin user"

kibanaserver:
  hash: "$2y$12$..."
  reserved: true
  description: "Demo kibanaserver user"

kibanaro:
  hash: "$2y$12$..."
  reserved: false
  backend_roles:
    - "kibanauser"
    - "readall"
  attributes:
    attribute1: "value1"
    attribute2: "value2"
    attribute3: "value3"
  description: "Demo kibanaro user"
```

### 7. Deployment dan Startup

```bash
dipen up wazuh
sleep 60
dipen logs wazuh
```

`dipen` adalah wrapper internal atas `podman-compose`. Jeda 60 detik diberikan agar layer filesystem selesai di-mount sebelum pengecekan log. Perhatikan urutan startup — Indexer harus `green` terlebih dahulu sebelum Manager dan Dashboard dapat terhubung.

### 8. Verifikasi dan Akses

```bash
https://<ip-address>:8443
```

Credential default:

- Username: `admin`
- Password: `CHANGE_ME_INDEXER_PASSWORD` (sesuai `.env`)

Jika Dashboard menampilkan error `Wazuh API not reachable`, periksa terlebih dahulu apakah container Manager telah melewati health check:

```bash
dipen ps wazuh
dipen logs wazuh
```

## Deployment Wazuh Agent

Wazuh Agent bertugas mengumpulkan data keamanan dari endpoint — log sistem, file integrity monitoring (FIM), vulnerability detection, dan active response — lalu mengirimkannya ke Wazuh Server melalui kanal terenkripsi. Berikut dua metode deployment yang umum digunakan.

### Metode 1: Deployment Menggunakan Docker

Langkah-langkah berikut mengasumsikan Anda telah memiliki direktori hasil kloning repositori `wazuh-docker`.

1. Masuk ke direktori konfigurasi agent:
   ```bash
   cd ~/digital-independence/wazuh/wazuh-agent
   ```

2. Modifikasi file `docker-compose.yml` untuk menyesuaikan alamat IP Wazuh Server:
   ```yaml
   # Wazuh App Copyright (C) 2017, Wazuh Inc. (License GPLv2)
   services:
     wazuh.agent:
       image: wazuh/wazuh-agent:4.14.4
       restart: always
       environment:
         - WAZUH_MANAGER_SERVER=<WAZUH_MANAGER_IP>  # Ganti dengan IP Wazuh Server Anda
       volumes:
         - ./config/wazuh-agent-conf:/wazuh-config-mount/etc/ossec.conf
   ```

   Variabel `WAZUH_MANAGER_SERVER` menentukan alamat enrollment. Jika agent tidak dapat menghubungi server pada port `1515/tcp`, agent akan gagal mendapatkan kunci autentikasi dan tidak akan muncul di Dashboard.

3. Jalankan container agent dalam mode *detached*:
   ```bash
   podman-compose up -d
   ```

### Metode 2: Deployment Langsung pada Host (Linux)

Untuk sistem operasi berbasis Linux, Wazuh menyediakan skrip instalasi otomatis melalui antarmuka manajemen agent.

1. Buka Wazuh Dashboard dan akses menu Agents management > Deploy new agent.
   ![alt text](<../assets/img/posts/2026-01-08-panduan-lengkap-instalasi-dan-konfigurasi wazuh/Screenshot From 2026-04-19 14-17-37.webp>)

2. Pilih sistem operasi target dan ikuti konfigurasi yang disediakan sistem, meliputi:
   - Alamat IP Wazuh Server
   - Nama agent
   - Kelompok agent (jika ada)

3. Jalankan perintah instalasi yang dihasilkan langsung pada terminal host target.

> Pastikan konektivitas jaringan antara agent dan server tidak terhalang firewall. Port default yang digunakan adalah 1514/udp (agent connection service) dan 1515/tcp (agent enrollment service).
{: .prompt-tip}

## Referensi

- [Dokumentasi resmi Wazuh](https://documentation.wazuh.com)
- [Wazuh: Required ports](https://documentation.wazuh.com/current/getting-started/architecture.html#required-ports)