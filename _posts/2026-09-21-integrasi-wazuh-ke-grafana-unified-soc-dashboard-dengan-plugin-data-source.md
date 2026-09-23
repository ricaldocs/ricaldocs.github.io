---
title: Integrasi Wazuh ke Grafana — Unified SOC Dashboard dengan Plugin Data Source
description: Panduan teknis mengintegrasikan Wazuh ke Grafana via plugin armanfeyzi-wazuh-datasource. Konfigurasi data source, UID wazuh, service account token, dan visualisasi alert, CVE, FIM, SCA dalam satu dashboard.
categories: [Digital Independence, Monitoring]
tags: [wazuh, grafana, soc, linux, forensics, incident response, podman, siem]
author: rical
last_modified_at: 2026-09-21
---

> Pastikan Anda memiliki stack monitoring dan Wazuh agent yang berjalan:
> 
> 1. [Panduan Lengkap Deploy Monitoring Stack Self-Hosted dengan Podman, Prometheus, dan Grafana](https://docs.ricalnet.my.id/posts/panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/)
> 2. [Panduan Lengkap Instalasi dan Konfigurasi Wazuh](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-dan-konfigurasi-wazuh/)
> 3. [Konfigurasi Wazuh Agent untuk Keamanan Host — FIM, Rootcheck, dan SCA](https://docs.ricalnet.my.id/posts/konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/)
{: .prompt-info}

## Mengapa Integrasi Ini Penting?

Wazuh Dashboard dan Grafana sama-sama kuat, tetapi memiliki fokus berbeda. Wazuh unggul dalam analisis alert keamanan dan manajemen agent, sedangkan Grafana unggul dalam visualisasi metrik deret waktu dan korelasi data lintas sumber. Memisahkan keduanya berarti operator SOC harus berpindah antarmuka untuk menjawab pertanyaan sederhana seperti: "Apakah lonjakan CPU di container ini berkorelasi dengan alert SSH brute force?"

Integrasi ini menyatukan kedua dunia tersebut. Data keamanan Wazuh (alert, kerentanan, FIM, SCA, status agent) mengalir ke Grafana melalui plugin data source, sehingga tersedia berdampingan dengan metrik operasional dari Prometheus dan Podman Exporter. Hasilnya adalah single pane of glass — satu antarmuka untuk keputusan operasional dan keamanan.

```
┌─────────────────────────────────────────────────────────────┐
│                    GRAFANA (Port 3003)                      │
│                  Single Pane of Glass                       │
│                                                             │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐   │
│  │  Wazuh Plugin  │  │  Prometheus    │  │  Node        │   │
│  │  (Data Source) │  │  (Data Source) │  │  Exporter    │   │
│  └───────┬────────┘  └───────┬────────┘  └──────┬───────┘   │
└──────────┼───────────────────┼──────────────────┼───────────┘
           │                   │                  │
           │ API + Indexer     │ Pull metrics     │ Pull metrics
           │                   │                  │
┌──────────▼─────────┐  ┌──────▼─────────┐  ┌─────▼──────────┐
│   WAZUH STACK      │  │  PROMETHEUS    │  │  PODMAN        │
│                    │  │                │  │  EXPORTER      │
│  ┌──────────────┐  │  │  TSDB          │  │                │
│  │   Manager    │  │  │  (15d retain)  │  │  Container     │
│  │   :55000     │  │  └────────────────┘  │  metrics       │
│  └──────┬───────┘  │                      └────────────────┘
│         │          │
│  ┌──────▼───────┐  │
│  │   Indexer    │  │
│  │   :9200      │  │
│  └──────────────┘  │
└──────────┬─────────┘
           │
           │ Alerts, CVE, FIM, SCA
           │
┌──────────▼─────────┐
│   WAZUH AGENT      │
│   (ricalnet-os)    │
│                    │
│  FIM · Rootcheck   │
│  SCA · Syscollector│
└────────────────────┘
```

## Prasyarat Teknis

| Komponen | Versi Minimum | Keterangan |
|---|---|---|
| Grafana | 10.4+ | Dukungan plugin data source modern |
| Wazuh Manager | 4.7+ | Endpoint API dan Indexer |
| Wazuh Indexer | 4.7+ | Penyimpanan data keamanan |
| Jaringan Podman | `wazuh-network` | Grafana harus bergabung ke jaringan ini |
| Akses API | Port 55000 | Wazuh Manager API |
| Akses Indexer | Port 9200 | Wazuh Indexer |

## 1. Instal Plugin Wazuh ke Grafana

Plugin `armanfeyzi-wazuh-datasource` menghubungkan Grafana langsung ke Wazuh Manager API dan Indexer, mengambil data alert, kerentanan, FIM, SCA, dan status agent dalam format yang dapat divisualisasikan.

```bash
podman exec -it grafana /usr/share/grafana/bin/grafana cli plugins install armanfeyzi-wazuh-datasource
```

> Pada Grafana 13+, perintah `grafana-cli` telah dihapus dan digantikan oleh `grafana cli`. Path lengkap `/usr/share/grafana/bin/grafana` diperlukan karena binary tidak selalu tersedia di `$PATH` dalam container.
{: .prompt-info}

### Restart Grafana

Plugin hanya dimuat saat startup, jadi restart wajib dilakukan:

```bash
podman restart grafana
```

### Verifikasi Plugin Terpasang

```bash
podman exec -it grafana ls /var/lib/grafana/plugins/ | grep wazuh
```

Output yang diharapkan menampilkan direktori `armanfeyzi-wazuh-datasource`.

## 2. Verifikasi Konektivitas Jaringan

Grafana harus berada di jaringan yang sama dengan Wazuh agar dapat mengakses `wazuh.manager:55000` dan `wazuh.indexer:9200` melalui nama container, bukan melalui IP host.

```bash
podman inspect grafana --format '{{json .NetworkSettings.Networks}}' | python3 -m json.tool
```

Output yang diharapkan menampilkan dua jaringan:

```json
{
    "monitoring_network",
    "wazuh-network"
}
```

Jika `wazuh-network` tidak muncul, tambahkan ke `monitoring/compose.yaml`:

```yaml
services:
  grafana:
    networks:
      - monitoring
      - wazuh-network

networks:
  wazuh-network:
    external: true
    name: wazuh-network
```

Mengapa pakai nama container, bukan IP host? Komunikasi antar-container dalam jaringan Podman bridge bersifat langsung dan tidak bergantung pada port mapping host. Ini lebih andal, lebih cepat, dan tidak terekspos ke jaringan luar.

## 3. Buat Service Account Token

Token diperlukan untuk autentikasi API Grafana saat membuat data source. Penggunaan token lebih aman daripada Basic Auth karena dapat dicabut kapan saja tanpa mengubah password admin.

### Langkah di UI Grafana

1. Buka Administration → Users and access → Service accounts
2. Klik Add service account
   - Display name: `cli-admin`
   - Role: `Admin`
     ![alt text](<../assets/img/posts/2026-09-21-integrasi-wazuh-ke-grafana-unified-security-and-operational-dashboard/Screenshot From 2026-09-21 21-47-25.png>)

3. Klik Add service account token
   - Display name: `patch-uid`
     ![alt text](<../assets/img/posts/2026-09-21-integrasi-wazuh-ke-grafana-unified-security-and-operational-dashboard/Screenshot From 2026-09-21 14-55-25.png>)

4. Salin token yang muncul — hanya ditampilkan sekali

Simpan token di variabel shell untuk memudahkan langkah berikutnya:

```bash
export GRAFANA_TOKEN="GANTI_DENGAN_TOKEN"
export GRAFANA_URL="http://127.0.0.1:3003"
```

## 4. Buat Data Source dengan UID `wazuh`

Dashboard bawaan plugin mereferensikan UID data source secara hardcode sebagai `wazuh`. Jika UID berbeda (misalnya `efyxd6vrax5hcc` yang dihasilkan Grafana secara acak), semua panel akan menampilkan `No data` meskipun koneksi berhasil di Explore.

### Kredensial yang Diperlukan

| Kredensial | Sumber |
|---|---|
| `apiPassword` | `API_PASSWORD` di file `.env` compose Wazuh |
| `indexerPassword` | `INDEXER_PASSWORD` di file `.env` compose Wazuh |

Untuk memverifikasi nilainya:

```bash
podman exec -it wazuh.manager env | grep -E "API_PASSWORD|INDEXER_PASSWORD"
```

### Perintah Pembuatan Data Source

```bash
curl -X POST "${GRAFANA_URL}/api/datasources" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  -d '{
    "uid": "wazuh",
    "name": "Wazuh",
    "type": "armanfeyzi-wazuh-datasource",
    "access": "proxy",
    "url": "https://wazuh.manager:55000",
    "jsonData": {
      "indexerURL": "https://wazuh.indexer:9200",
      "indexerUsername": "admin",
      "skipTLSVerify": true
    },
    "secureJsonData": {
      "apiPassword": "CHANGE_ME_API_PASSWORD",
      "indexerPassword": "CHANGE_ME_INDEXER_PASSWORD"
    }
  }'
```

Mengapa `skipTLSVerify: true`? Wazuh menggunakan sertifikat self-signed untuk komunikasi internal. Dalam lingkungan laboratorium atau infrastruktur tertutup, verifikasi TLS dapat dilewati. Untuk produksi, impor root CA Wazuh ke trust store Grafana.

Respons sukses:

```json
{
  "datasource": { "id": 29, "uid": "wazuh", "name": "Wazuh"},
  "id": 29,
  "message": "Datasource added",
  "name": "Wazuh"
}
```

### Verifikasi UID

```bash
curl -s "${GRAFANA_URL}/api/datasources" \
  -H "Authorization: Bearer ${GRAFANA_TOKEN}" \
  | python3 -m json.tool | grep '"uid"'
```

Output harus menampilkan `"uid": "wazuh"`.

## 5. Verifikasi Konfigurasi di UI Grafana

Meskipun data source sudah dibuat via API, verifikasi melalui UI memastikan semua field terbaca dengan benar.

Buka Connections → Data sources → Wazuh, lalu periksa:

![alt text](<../assets/img/posts/2026-09-21-integrasi-wazuh-ke-grafana-unified-security-and-operational-dashboard/Screenshot From 2026-09-21 15-16-46.png>)

| Field | Nilai |
|---|---|
| Manager URL | `https://wazuh.manager:55000` |
| Indexer URL | `https://wazuh.indexer:9200` |
| API username | `wazuh-wui` |
| API password | (terisi otomatis) |
| Indexer username | `admin` |
| Indexer password | (terisi otomatis) |
| Skip TLS verify | ✅ Tercentang |

Klik Save & test. Pesan yang diharapkan:

```
Connected to Wazuh manager API and indexer
```

## 6. Import Dashboard Bawaan

Plugin menyertakan lima dashboard siap pakai yang secara otomatis mereferensikan UID `wazuh`.

### Langkah Import

1. Buka Dashboards → New → Import
2. Pilih semua dashboard dari folder plugin
   ![alt text](<../assets/img/posts/2026-09-21-integrasi-wazuh-ke-grafana-unified-security-and-operational-dashboard/Screenshot From 2026-09-21 15-20-40.png>)

### Dashboard yang Tersedia

| Dashboard | Konten |
|---|---|
| Security Overview | Ringkasan alert berdasarkan severity, tren waktu, top rules |
| Vulnerabilities | Distribusi CVE, top paket terdampak, severity breakdown |
| File Integrity Monitoring | Perubahan file, siapa yang mengubah, kapan |
| SCA | Skor CIS benchmark, check yang gagal, rekomendasi |
| Agent Status | Status koneksi agent, versi, OS, grup |

## 7. Verifikasi Akhir

### Cek dari Explore

Buka Explore → pilih Wazuh, lalu uji setiap data type:

| Data Type | Ekspektasi |
|---|---|
| Alerts | Grafik time series alert |
| Vulnerabilities | Tabel CVE dengan paket dan versi |
| Agent Status | Daftar agent dengan status |
| FIM | Perubahan file |
| SCA | Hasil benchmark |

### Cek dari Dashboard

Buka Dashboards → Wazuh → Vulnerabilities. Panel harus terisi dengan data kerentanan (misalnya 139 Open vulnerabilities: 41 High, 85 Medium, 13 Low untuk agent `ricalnet-os`).

![alt text](<../assets/img/posts/2026-09-21-integrasi-wazuh-ke-grafana-unified-security-and-operational-dashboard/Screenshot From 2026-09-21 15-26-16.png>)

## 8. Hasil Akhir

Setelah semua langkah selesai, Anda memiliki:

| Kapabilitas | Sumber Data |
|---|---|
| Visualisasi alert keamanan | Wazuh Manager API |
| Analisis kerentanan | Wazuh Indexer |
| Monitoring integritas file | Wazuh FIM |
| Skor kepatuhan CIS | Wazuh SCA |
| Status agent | Wazuh API |
| Metrik container | Podman Exporter |
| Metrik host | Node Exporter |
| Notifikasi | Alertmanager + ntfy |

Semua tersedia dalam satu antarmuka Grafana, memungkinkan korelasi antara kejadian keamanan dan kondisi operasional dalam satu layar.

## Referensi

- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Grafana Plugin: armanfeyzi-wazuh-datasource](https://grafana.com/grafana/plugins/armanfeyzi-wazuh-datasource/)
- [Grafana Service Accounts](https://grafana.com/docs/grafana/latest/administration/service-accounts/)
- [Podman Networking](https://docs.podman.io/en/latest/markdown/podman-network.1.html)