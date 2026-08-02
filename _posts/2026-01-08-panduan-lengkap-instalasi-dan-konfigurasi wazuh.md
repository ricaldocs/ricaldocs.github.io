---
title: Panduan Lengkap Instalasi dan Konfigurasi Wazuh
description: Tutorial langkah demi langkah ini mencakup setup server dan agent, akses dashboard, manajemen user, konfigurasi jaringan, troubleshooting, hingga deployment menggunakan Docker. Pelajari cara memantau keamanan jaringan dan deteksi ancaman siber secara real-time dengan platform terintegrasi ini.
categories: [Cybersecurity]
tags: [wazuh, soc, linux, forensics, incident response]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Keamanan informasi telah menjadi pilar fundamental bagi kelangsungan operasional organisasi. Ancaman siber yang terus berkembang, mulai dari ransomware, pelanggaran data, hingga serangan zero-day, menuntut pendekatan proaktif dalam deteksi dan respons insiden keamanan. Di sinilah perangkat Security Information and Event Management (SIEM) memainkan peran krusial sebagai mata dan telinga tim keamanan dalam memantau infrastruktur teknologi.

Wazuh hadir sebagai solusi SIEM open-source terkemuka yang menggabungkan kemampuan Intrusion Detection System (IDS), Security Analytics, dan Compliance Monitoring dalam satu platform terintegrasi. Dengan arsitektur berbasis agen-server yang scalable, Wazuh memungkinkan organisasi untuk mengumpulkan, menganalisis, dan mengkorelasikan data keamanan dari berbagai sumber, mulai dari endpoint, server, cloud, hingga container secara real-time.

> Penting untuk dicatat bahwa meskipun panduan ini menggunakan pendekatan instalasi terotomatisasi untuk mempercepat proses setup, pemahaman mendalam tentang setiap komponen (Wazuh Server, Indexer, dan Dashboard) akan membantu dalam operasional dan pemeliharaan jangka panjang. Selamat membangun lapisan pertahanan siber yang lebih tangguh!
{: .prompt-info}

## Instalasi Wazuh

### Langkah 1: Unduh dan Jalankan Instalasi
Eksekusi perintah berikut untuk mengunduh skrip instalasi dan menjalankannya dengan mode otomatis:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

### Langkah 2: Verifikasi Instalasi
Setelah proses instalasi selesai, sistem akan menampilkan informasi akses sebagai berikut:

```
INFO: --- Summary ---
INFO: You can access the web interface https://<WAZUH_DASHBOARD_IP_ADDRESS>
    User: admin
    Password: <ADMIN_PASSWORD>
INFO: Installation finished.
```

### Langkah 3: Akses Dashboard Wazuh
1. Buka browser dan akses alamat IP yang ditampilkan pada output instalasi
   ![alt text](<../assets/img/posts/2026-01-08-panduan-lengkap-instalasi-dan-konfigurasi wazuh/Screenshot_2026-01-08_13-59-13.png>)

2. Saat pertama kali mengakses, browser akan menampilkan peringatan keamanan sertifikat
3. **Catatan Penting**: Peringatan ini normal karena menggunakan [sertifikat self-signed](https://ricaldocs.github.io/posts/mastering-self-signed-certificates/). Anda dapat:
   - Menerima sertifikat sebagai pengecualian, atau
   - Mengkonfigurasi sertifikat dari Certificate Authority (CA) yang terpercaya

## Manajemen Kredensial

### Menampilkan Password Pengguna
Password untuk semua pengguna Wazuh Indexer dan Wazuh API tersimpan dalam file terenkripsi. Untuk menampilkannya:

```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

### Uninstalasi Komponen
Untuk menghapus komponen pusat Wazuh, gunakan opsi uninstall:

```bash
sudo bash ./wazuh-install.sh -u
# atau
sudo bash ./wazuh-install.sh --uninstall
```

## Konfigurasi Sistem

### Nonaktifkan Pembaruan Otomatis
> Nonaktifkan repositori Wazuh untuk mencegah pembaruan tidak sengaja yang dapat mengganggu stabilitas sistem.
{: .prompt-tip}

```bash
sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
apt update
```

### Konfigurasi Alamat IP
Jika diperlukan perubahan alamat IP, modifikasi file konfigurasi berikut:

1. **Wazuh Dashboard** (`/etc/wazuh-dashboard/opensearch_dashboards.yml`{: .filepath}):
   ```yaml
   opensearch.hosts: ["https://<ALAMAT_IP_BARU>:9200"]
   ```

2. **Wazuh Indexer** (`/etc/wazuh-indexer/opensearch.yml`{: .filepath}):
   ```yaml
   network.host: <ALAMAT_IP_BARU>
   ```

3. Restart layanan setelah perubahan:
   ```bash
   sudo systemctl restart wazuh-dashboard
   sudo systemctl restart wazuh-indexer
   ```

## Troubleshooting

### Masalah Sertifikat
- Jika mengalami masalah koneksi SSL, pastikan waktu sistem telah disinkronisasi
- Untuk lingkungan produksi, pertimbangkan menggunakan sertifikat dari CA terpercaya

### Masalah Koneksi
- Verifikasi firewall tidak memblokir port 443 (HTTPS) dan 9200 (API)
- Pastikan semua layanan Wazuh berjalan dengan status `active`

## Deployment Wazuh Stack Single-Node Menggunakan Docker

### 1. Pengantar
Instalasi ini mencakup kloning repositori, generasi sertifikat, deployment container, dan akses ke antarmuka dashboard Wazuh.

### 2. Kloning Repositori
Langkah pertama adalah mengunduh kode sumber konfigurasi Docker Wazuh ke sistem lokal.

1.  Jalankan perintah berikut untuk mengkloning repositori dan sekaligus memilih branch:
    ```bash
    git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.1
    ```

2.  Masuk ke direktori `single-node`{: .filepath} untuk menjalankan seluruh perintah yang dijelaskan dalam dokumen ini.
    ```bash
    cd wazuh-docker/single-node/
    ```

### 3. Generasi Sertifikat
Komunikasi antar node dalam stack Wazuh harus diamankan menggunakan sertifikat. Terdapat dua opsi yang tersedia:
*   **Sertifikat Self-Signed Wazuh** (direkomendasikan untuk lingkungan uji/pengembangan)
*   **Sertifikat Milik Sendiri** (untuk lingkungan produksi)

Untuk menghasilkan sertifikat [self-signed](https://ricaldocs.github.io/posts/mastering-self-signed-certificates/) untuk setiap node, gunakan Docker image `wazuh-certs-generator`.

1.  **Opsional - Konfigurasi Proxy**: Jika sistem menggunakan proxy, tambahkan konfigurasi berikut ke dalam file `generate-indexer-certs.yml`. **Ganti `<YOUR_PROXY_ADDRESS_OR_DNS>` dengan informasi proxy Anda**. Jika tidak menggunakan proxy, lewati langkah ini.
    ```yaml
    # Wazuh App Copyright (C) 2017, Wazuh Inc. (License GPLv2)
    services:
      generator:
        image: wazuh/wazuh-certs-generator:0.0.3
        hostname: wazuh-certs-generator
        volumes:
          - ./config/wazuh_indexer_ssl_certs/:/certificates/
          - ./config/certs.yml:/config/certs.yml
        environment:
          - HTTP_PROXY=<YOUR_PROXY_ADDRESS_OR_DNS>
    ```

2.  Jalankan perintah berikut untuk menghasilkan sertifikat:
    ```bash
    docker compose -f generate-indexer-certs.yml run --rm generator
    ```
    Sertifikat yang dihasilkan akan disimpan di direktori `wazuh-docker/single-node/config/wazuh_indexer_ssl_certs`{: .filepath}.

### 4. Deployment Stack
Setelah sertifikat siap, mulai deployment container Wazuh menggunakan perintah Docker Compose.

1.  Jalankan perintah berikut untuk membangun dan menjalankan container dalam mode detached:
    ```bash
    docker compose up -d
    ```

   > Docker tidak secara otomatis memuat ulang konfigurasi. Setelah melakukan perubahan pada konfigurasi komponen apa pun, stack **harus di-restart** untuk menerapkan perubahan.
   {: .prompt-info}

### 5. Mengakses Wazuh Dashboard
Setelah stack single-node berhasil di-deploy, dashboard Wazuh dapat diakses melalui alamat IP host Docker atau `localhost`.

1.  Buka browser dan akses alamat berikut:
    ```
    https://<DOCKER_HOST_IP>
    ```
    > Jika menggunakan [sertifikat self-signed](https://ricaldocs.github.io/posts/mastering-self-signed-certificates/), browser akan menampilkan peringatan terkait keaslian sertifikat. Peringatan ini dapat diabaikan untuk lingkungan non-produksi.
    {: .prompt-info}

2.  Gunakan kredensial default berikut untuk masuk:
    *   **Username:** `admin`
    *   **Password:** `SecretPassword`

    > Segera ubah kata sandi default setelah login pertama.
    {: .prompt-tip}

### 6. Pemecahan Masalah (Troubleshooting)
Selama proses startup, container Wazuh Dashboard akan berulang kali memeriksa status Wazuh Indexer. Anda mungkin melihat beberapa pesan log seperti `"Failed to connect to Wazuh indexer port 9200"` atau `"Wazuh dashboard server is not ready yet"`. **Ini adalah perilaku yang normal.** Pesan ini akan berhenti setelah Wazuh Indexer berjalan sepenuhnya, yang biasanya memakan waktu sekitar satu menit. Kredensial default untuk Wazuh Indexer dapat ditemukan dalam file `docker-compose.yml`.


Berikut adalah pembaruan untuk bagian **7. wazuh-agent** agar lebih sesuai dengan standar dokumentasi teknis profesional yang konsisten dengan bagian sebelumnya:

---

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
