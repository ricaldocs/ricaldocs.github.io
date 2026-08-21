---
title: Panduan Lengkap Instalasi dan Konfigurasi Wazuh
description: Tutorial langkah demi langkah ini mencakup setup server dan agent, akses dashboard, manajemen user, konfigurasi jaringan, troubleshooting, hingga deployment menggunakan Docker. Pelajari cara memantau keamanan jaringan dan deteksi ancaman siber secara real-time dengan platform terintegrasi ini.
categories: [Cybersecurity]
tags: [wazuh, soc, linux, forensics, incident response]
author: rical
last_modified_at: 2026-08-21
---

## Pendahuluan
Keamanan informasi telah menjadi pilar fundamental bagi kelangsungan operasional organisasi. Ancaman siber yang terus berkembang, mulai dari ransomware, pelanggaran data, hingga serangan zero-day, menuntut pendekatan proaktif dalam deteksi dan respons insiden keamanan. Di sinilah perangkat Security Information and Event Management (SIEM) memainkan peran krusial sebagai mata dan telinga tim keamanan dalam memantau infrastruktur teknologi.

Wazuh hadir sebagai solusi SIEM open-source terkemuka yang menggabungkan kemampuan Intrusion Detection System (IDS), Security Analytics, dan Compliance Monitoring dalam satu platform terintegrasi. Dengan arsitektur berbasis agen-server yang scalable, Wazuh memungkinkan organisasi untuk mengumpulkan, menganalisis, dan mengkorelasikan data keamanan dari berbagai sumber, mulai dari endpoint, server, cloud, hingga container secara real-time.

> Penting untuk dicatat bahwa meskipun panduan ini menggunakan pendekatan instalasi terotomatisasi untuk mempercepat proses setup, pemahaman mendalam tentang setiap komponen (Wazuh Server, Indexer, dan Dashboard) akan membantu dalam operasional dan pemeliharaan jangka panjang. Selamat membangun lapisan pertahanan siber yang lebih tangguh!
{: .prompt-info}

## Deployment Wazuh Stack Single-Node Menggunakan Docker

### 1. Persiapan Repository

```bash
git clone https://github.com/ricalnet/digital-independence.git
```

Repository ini berisi konfigurasi terstruktur untuk deployment Wazuh dalam environment containerized. Struktur direktori telah dioptimalkan dengan pemisahan konfigurasi untuk setiap komponen (indexer, dashboard, server) yang memudahkan manajemen dan skalabilitas.

### 2. Instalasi Docker Engine

#### Untuk Debian:
```bash
./install-docker-engine-on-debian.sh
```

#### Untuk Ubuntu:
```bash
./install-docker-engine-on-ubuntu.sh
```

Script instalasi mengkonfigurasi repository resmi Docker, menginstal paket dependensi (containerd, runc), dan mengatur service docker untuk auto-start. Perbedaan script Debian/Ubuntu terletak pada manajemen paket (apt vs apt-get) dan konfigurasi repository yang spesifik versi.

### 3. Generasi Sertifikat Self-Signed

```bash
cd wazuh
docker compose -f generate-indexer-certs.yml run --rm generator
```

Image `wazuh/wazuh-indexer` digunakan untuk menjalankan script `generate_certs` yang membuat:
- Root CA Certificate (`root-ca.pem`) sebagai trust anchor
- Certificate dan Private Key untuk setiap node indexer
- Admin Certificate untuk akses administrative ke cluster

Sertifikat disimpan di `./wazuh-indexer/certs/`{: .filepath} dan akan di-mount sebagai volume ke container indexer. Proses ini kritis karena Wazuh menggunakan TLS mutual authentication untuk komunikasi antar komponen.

### 4. Konfigurasi Environment Variables

```bash
cp .env.example .env
nano .env
```

Parameter Kritis yang Perlu Disesuaikan:

```
# -------------------- WAZUH INDEXER --------------------
INDEXER_USERNAME=admin
INDEXER_PASSWORD=your-secret-password
INDEXER_HEAP_SIZE=512m
INDEXER_MAX_HEAP=768m

# -------------------- WAZUH API --------------------
API_USERNAME=wazuh-wui
API_PASSWORD=your-secret-password

# -------------------- WAZUH DASHBOARD --------------------
DASHBOARD_USERNAME=kibanaserver
DASHBOARD_PASSWORD=your-secret-password

# -------------------- PORT BINDING --------------------
MANAGER_PORT_1514=127.0.0.1:1514:1514
MANAGER_PORT_1515=127.0.0.1:1515:1515
MANAGER_PORT_55000=127.0.0.1:55000:55000
# MANAGER_PORT_514=127.0.0.1:514:514/udp

INDEXER_PORT_9200=127.0.0.1:9200:9200
DASHBOARD_PORT_443=443:5601
```

Docker Compose menggunakan variable substitution untuk menyisipkan nilai-nilai ini ke dalam service definitions. Ini memungkinkan:
- Separation of concerns antara kode dan konfigurasi
- Kemudahan rotasi password tanpa mengubah docker-compose.yml
- Support untuk multi-environment deployment

### 5. Konfigurasi Dashboard Wazuh

```bash
cp config/wazuh_dashboard/wazuh.example.yml config/wazuh_dashboard/wazuh.yml
nano config/wazuh_dashboard/wazuh.yml
```

Struktur Konfigurasi yang Diperlukan:
```yaml
hosts:
  - 1513629884013:
      url: "https://wazuh.manager"
      port: 55000
      username: wazuh-wui
      password: "MyS3cr37P450r.*-" # Menggunakan variable dari .env
      run_as: true
```

File `wazuh.yml` berisi konfigurasi API endpoint yang harus sesuai dengan environment. Penggunaan environment memastikan sinkronisasi password antara dashboard dan indexer.

### 6. Manajemen Password Internal Users

```bash
cp config/wazuh_indexer/internal_users.example.yml config/wazuh_indexer/internal_users.yml
docker run --rm -it wazuh/wazuh-indexer:4.14.7 bash
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
 
OpenSearch Security plugin tidak menerima password plaintext. Hash ini disimpan di `internal_users.yml` dan digunakan untuk autentikasi saat service startup. Setiap user (admin, kibanaserver, kibanaro, logstash) memerlukan hash yang berbeda.

Update file `config/wazuh_indexer/internal_users.yml`{: .filepath}:
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
docker compose up -d
docker compose logs -f
```

Proses yang Terjadi:
1. Membuat persistent volumes untuk data indexer dan logs
2. Membuat network bridge untuk komunikasi antar container
3. Service Initialization:
   - `wazuh-indexer`: Bootstraps OpenSearch cluster dengan security plugin
   - `wazuh-server`: Inisialisasi Wazuh manager dan API
   - `wazuh-dashboard`: Configures OpenSearch Dashboards dengan Wazuh plugin

### 8. Verifikasi dan Akses

```bash
https://<ip-address>
```

Credential Default:
- Username: `admin`
- Password: `your-secret-password` (sesuai .env)

Verifikasi Service Status:
```bash
docker compose ps
docker logs wazuh.dashboard -f
docker logs wazuh.manager -f
docker logs wazuh.indexer -f
```

## Deployment Wazuh Agent

Wazuh Agent bertugas mengumpulkan data keamanan dari endpoint dan mengirimkannya ke Wazuh Server. Berikut dua metode deployment yang umum digunakan.

### Metode 1: Deployment Menggunakan Docker

Langkah-langkah berikut mengasumsikan Anda telah memiliki direktori hasil kloning repositori `wazuh-docker`.

1.  Masuk ke direktori konfigurasi agent:
    ```bash
    cd wazuh-docker/wazuh-agent
    ```

2.  Modifikasi file `docker-compose.yml` untuk menyesuaikan alamat IP Wazuh Server:
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

3.  Jalankan container agent dalam mode detached:
    ```bash
    docker compose up -d
    ```

### Metode 2: Deployment Langsung pada Host (Linux)

Untuk sistem operasi berbasis Linux, Wazuh menyediakan skrip instalasi otomatis melalui antarmuka manajemen agent.

1.  Buka **Wazuh Dashboard** dan akses menu **Agents management** > **Deploy new agent**.
    ![alt text](<../assets/img/posts/2026-01-08-panduan-lengkap-instalasi-dan-konfigurasi wazuh/Screenshot From 2026-04-19 14-17-37.png>)

2.  Pilih sistem operasi target dan ikuti konfigurasi yang disediakan sistem, meliputi:
    - Alamat IP Wazuh Server
    - Nama agent
    - Kelompok agent (jika ada)

3.  Jalankan perintah instalasi yang dihasilkan langsung pada terminal host target.

> Pastikan konektivitas jaringan antara agent dan server tidak terhalang firewall. Port default yang digunakan adalah 1514/udp (agent connection service) dan 1515/tcp (agent enrollment service).
{: .prompt-tip}

## Referensi
- [Dokumentasi resmi Wazuh](https://documentation.wazuh.com)
- [Wazuh: Required ports](https://documentation.wazuh.com/current/getting-started/architecture.html#required-ports)
