---
title: Panduan Lengkap Deploy Monitoring Stack Self-Hosted dengan Podman, Prometheus, dan Grafana
description: Panduan teknis langkah demi langkah membangun monitoring stack self-hosted menggunakan Podman, Prometheus, Grafana, Node Exporter, Podman Exporter, dan Alertmanager di Raspberry Pi. Lengkap dengan verifikasi end-to-end, integrasi Ntfy untuk notifikasi, dan import dashboard siap pakai.
categories: [Digital Independence, Monitoring]
tags: [self-hosted, grafana, prometheus]
author: rical
last_modified_at: 2026-09-19
---

## Pendahuluan

Monitoring adalah fondasi dari infrastruktur self-hosted yang sehat. Tanpa observability, Anda tidak akan tahu kapan disk penuh, container OOM-kill, atau service down hingga user melapor. Artikel ini memandu Anda membangun monitoring stack production-grade di Raspberry Pi menggunakan Podman rootless, dengan fokus pada:

- Prometheus — time-series database & scraper
- Grafana — visualisasi & dashboard
- Node Exporter — host metrics (CPU, RAM, disk, network)
- Podman Exporter — container metrics (44 container Anda)
- Alertmanager — routing alert ke Ntfy
- Ntfy — push notification
- Ntfy-Alertmanager Bridge — jembatan webhook Alertmanager → Ntfy

## Prasyarat

Sebelum mulai, pastikan:

- Komputer server dengan OS Trixie 64-bit
- RAM minimal 4 GB (8 GB direkomendasikan untuk 44 container)
- Podman 4.0+ dan Podman Compose terinstall
- Akses SSH ke server
- Ntfy untuk Alertmanager

## Langkah 1: Clone Repository & Install Podman

```bash
git clone https://git.ricalnet.my.id/rical/digital-independence.git ~/digital-independence
cd ~/digital-independence
./install-podman-on-debian.sh
```

Repository `digital-independence` adalah single source of truth untuk seluruh stack self-hosted Anda. Script `install-podman-on-debian.sh` mengotomasi instalasi Podman, Podman Compose, dan konfigurasi awal (termasuk enable `podman.socket` untuk rootless mode). Rootless Podman dipilih karena berjalan sebagai user biasa — tanpa daemon root — sehingga mengurangi attack surface secara signifikan.

## Langkah 2: Buat Network Monitoring

```bash
podman network create monitoring_network
podman network ls | grep monitoring
```

Mengapa network terpisah? Container monitoring (Prometheus, Grafana, dll) dan container aplikasi (Authentik, Immich, dll) harus berada di network yang sama agar Prometheus bisa scrape exporter. Network `monitoring_network` juga memungkinkan Ntfy diakses Alertmanager tanpa expose port ke host. Ini adalah isolasi network — prinsip keamanan dasar dalam container orchestration.

## Langkah 3: Sesuaikan Konfigurasi Environment

```bash
dipen env monitoring
```

Perintah `dipen env monitoring` membuka editor untuk file `.env` di folder `monitoring/`. Isi variabel berikut dengan nilai yang di-generate:

```bash
GRAFANA_ADMIN_PASSWORD=$(openssl rand -hex 32)
GRAFANA_SECRET_KEY=$(openssl rand -hex 32)
```

> Hardcoding password di `compose.yaml` adalah anti-pattern keamanan. Dengan `.env`, credentials terpisah dari source code, bisa di-`.gitignore`, dan mudah dirotasi. `openssl rand -hex 32` menghasilkan 256-bit entropy.
{: .prompt-info}

## Langkah 4: Jalankan Stack Monitoring

```bash
dipen up monitoring
sleep 30
dipen ps monitoring
```

Output yang diharapkan:

```
▶ 1 services: monitoring

[1/1] Processing monitoring...
▶ monitoring...
CONTAINER ID  IMAGE                                              COMMAND               CREATED         STATUS                   PORTS                     NAMES
4a1b365f9c9e  docker.io/prom/prometheus:latest                   --config.file=/et...  28 minutes ago  Up 28 minutes (healthy)  127.0.0.1:9090->9090/tcp  prometheus
cf9ac57bb219  docker.io/prom/node-exporter:latest                --path.procfs=/ho...  28 minutes ago  Up 28 minutes (healthy)  127.0.0.1:9100->9100/tcp  node-exporter
347dbfb930a9  quay.io/navidys/prometheus-podman-exporter:latest  --collector.enabl...  28 minutes ago  Up 28 minutes (healthy)  127.0.0.1:9882->9882/tcp  podman-exporter
26a63ec570ef  docker.io/prom/alertmanager:latest                 --config.file=/et...  28 minutes ago  Up 28 minutes (healthy)  127.0.0.1:9093->9093/tcp  alertmanager
88ad72aed27a  docker.io/grafana/grafana-oss:latest                                     28 minutes ago  Up 28 minutes (healthy)  127.0.0.1:3003->3000/tcp  grafana
```

Mengapa `sleep 30`? Prometheus butuh ~15-30 detik untuk memuat config, membuka TSDB, dan mulai scrape target. Grafana butuh ~60 detik untuk migrasi database internal. Tanpa jeda, `dipen ps` akan menampilkan status `starting` (belum `healthy`).

> Grafana listen di port 3003 (bukan default 3000) karena port 3000 sudah dipakai Open WebUI. Ini contoh port collision avoidance di host dengan banyak service.
{: .prompt-info}

## Langkah 5: Verifikasi Health Endpoints

```bash
echo "=== Prometheus ==="
curl -s http://localhost:9090/-/healthy

echo "=== Grafana ==="
curl -s http://localhost:3003/api/health

echo "=== Node Exporter ==="
curl -s http://localhost:9100/metrics | head -1

echo "=== Podman Exporter ==="
curl -s http://localhost:9882/health

echo "=== Alertmanager ==="
curl -s http://localhost:9093/-/healthy
```

Output yang diharapkan:

```
=== Prometheus ===
Prometheus Server is Healthy.

=== Grafana ===
{
  "database": "ok",
  "version": "13.0.2",
  "commit": "3fcdbc5a"
}

=== Node Exporter ===
# HELP go_gc_duration_seconds A summary of the wall-time pause (stop-the-world) duration in garbage collection cycles.

=== Podman Exporter ===
<html>
			<head><title>Podman Exporter</title></head>
			<body>
			<h1>Podman Exporter</h1>
			<p><a href="/metrics">Metrics</a></p>
			</body>
			</html>

=== Alertmanager ===
OK
```

Mengapa health endpoint penting? Health endpoint adalah kontrak antara service dan orchestrator. Docker/Podman menggunakan endpoint ini untuk menentukan status `healthy`. Prometheus juga menggunakan endpoint serupa (`/metrics`) untuk scrape. Verifikasi manual memastikan semua service siap menerima request sebelum lanjut.

## Langkah 6: Verifikasi Prometheus Targets

```bash
curl -s http://localhost:9090/api/v1/targets | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
for t in d['data']['activeTargets']:
    job = t['labels']['job']
    health = t['health']
    icon = '✅' if health == 'up' else '❌'
    print(f'  {icon} {job:20} {health}')
"
```

Output yang diharapkan:

```
  ✅ alertmanager         up
  ✅ grafana              up
  ✅ node-exporter        up
  ✅ podman               up
  ✅ prometheus           up
```

Mengapa verifikasi target? Prometheus tidak otomatis tahu service mana yang harus di-scrape. Config `prometheus.yml` mendefinisikan scrape job dengan target. Jika target `down`, bisa jadi: (1) service tidak berjalan, (2) network tidak terhubung, (3) DNS resolution gagal di dalam network Podman. Verifikasi ini memastikan semua jalur komunikasi terbuka.

## Langkah 7: Verifikasi Podman Exporter Metrics

```bash
# Cek jumlah container terdeteksi
curl -s http://localhost:9882/metrics | grep -c "^podman_container_info"

# Cek apakah metric punya label name
curl -s http://localhost:9882/metrics | grep "^podman_container_cpu_seconds_total" | \
  head -1 | grep -oP 'name="[^"]*"'
```

Output yang diharapkan:

```
44
name="authentik_postgresql"
name="pod_authentik"
```

Mengapa label `name` penting? Metric Prometheus tanpa label `name` hanya menyediakan container ID — tidak human-readable. Dengan flag `--collector.store-labels` dan `--collector.enhance-metrics`, Podman Exporter menambahkan label seperti `name`, `image`, `pod_name` ke setiap metric. Ini memungkinkan query seperti `topk(5, rate(podman_container_cpu_seconds_total[5m]))` menghasilkan output yang bisa dibaca.

> Jika label `name` tidak muncul, tambahkan flag berikut di `compose.yaml`:
```yaml
command:
  - "--collector.enable-all"
  - "--collector.store-labels"
  - "--collector.enhance-metrics"
```
{: .prompt-tip}

## Langkah 8: Verifikasi Prometheus Rules

```bash
curl -s http://localhost:9090/api/v1/rules | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
for g in d['data']['groups']:
    print(f\"  📁 {g['name']}: {len(g['rules'])} rules\")
"
```

Output yang diharapkan:

```
  📁 container_alerts: 3 rules
  📁 database_alerts: 5 rules
  📁 host_alerts: 8 rules
  📁 service_alerts: 1 rules
```

Mengapa rule grouping? Alert rules dikelompokkan berdasarkan kategori (`host`, `container`, `database`, `service`). Ini memudahkan: 
1. Maintenance — tambah rule di file terpisah 
2. Troubleshooting — lihat rule mana yang gagal evaluasi (3) 
3. Dokumentasi — struktur jelas. Setiap group punya `interval` evaluasi independen (30 detik di sini)

## Langkah 9: Verifikasi Alertmanager

```bash
curl -s http://localhost:9093/api/v2/status | python3 -m json.tool
curl -s http://localhost:9093/api/v2/alerts | python3 -m json.tool
```

Mengapa cek Alertmanager? Alertmanager menerima alert dari Prometheus, melakukan deduplication, grouping, inhibition, dan routing ke receiver (Ntfy). Verifikasi status memastikan cluster ready dan config valid. Output `[]` untuk alerts berarti tidak ada alert aktif — sistem sehat.

## Langkah 10: Verifikasi Ntfy Network

```bash
podman inspect ntfy-server --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}'
```

Output yang diharapkan:

```
WARN[0000] Could not find mount at destination "/var/run" when parsing user volumes for container b81f842e4256ce64052ebf6574c43b778eb863758eae564ab9f95e94e7917b62 
monitoring_network ntfy_network 
```

Mengapa Ntfy di dua network? Ntfy harus terhubung ke `monitoring_network` agar Alertmanager bisa POST webhook ke `http://ntfy-server:80/critical-alerts`. Tapi Ntfy juga tetap di `ntfy_network` (internal) untuk komunikasi antar-container Ntfy sendiri. Dual-homing ini adalah pattern umum di Docker/Podman untuk expose service ke multiple network tanpa membuka port ke host.

Warning `/var/run` tidak berbahaya — hanya Podman memberi tahu bahwa ada volume mount yang tidak ditemukan. Ntfy tetap berfungsi normal.

## Langkah 11: Test Query Prometheus

```bash
# Top 5 CPU
curl -s -G "http://localhost:9090/api/v1/query" \
  --data-urlencode "query=topk(5, rate(podman_container_cpu_seconds_total[5m]))" | \
  python3 -c "
import sys, json
d = json.load(sys.stdin)
for r in d['data']['result']:
    name = r['metric'].get('name', 'N/A')
    val = float(r['value'][1])
    print(f'  {name:30} {val:.4f} cores')
"
```

Output yang diharapkan:

```
  wazuh.manager                  0.8304 cores
  grafana                        0.0171 cores
  uptime-kuma                    0.0167 cores
  prometheus                     0.0154 cores
  immich_machine_learning        0.0119 cores
```

Mengapa `--data-urlencode`? Query PromQL mengandung karakter khusus seperti `(`, `)`, dan `[`. Tanpa URL-encoding, curl akan gagal parse URL. `--data-urlencode` otomatis meng-encode query agar bisa dikirim via `GET` request dengan aman.

## Langkah 12: Setup Ntfy-Alertmanager Bridge

Alertmanager mengirim webhook dalam format JSON mentah yang tidak dipahami Ntfy secara langsung. Diperlukan bridge yang menerjemahkan payload Alertmanager ke format Ntfy.

### Salin File Konfigurasi Bridge

```bash
cp ~/digital-independence/monitoring/ntfy-alertmanager/config.example ~/digital-independence/monitoring/ntfy-alertmanager/config

nano ~/digital-independence/monitoring/ntfy-alertmanager/config
```

Edit file `~/digital-independence/monitoring/ntfy-alertmanager/config`:

```
http-address :8080

ntfy {
  topic "http://ntfy-server:80/alertmanager"
  token "tk_xxxxxxxxxxxx"
}

alertmanager {
  url "http://alertmanager:9093"
}
```

> `http-address` harus `:8080` atau `0.0.0.0:8080`, bukan `127.0.0.1:8080`. Jika menggunakan `127.0.0.1`, container Alertmanager tidak akan bisa menjangkau bridge.
{: .prompt-warning}

> `topic` harus berupa URL lengkap ke topik Ntfy, bukan hanya nama topik. Gunakan `http://ntfy-server:80/alertmanager` (sesuaikan port dengan konfigurasi Ntfy Anda). Jangan gunakan `https://` jika Ntfy Anda tidak melayani TLS — ini akan menyebabkan error `connection refused` ke port 443.
{: .prompt-tip}

> `token` adalah token akses Ntfy yang bisa dibuat di halaman akun Ntfy.
{: .prompt-info}

### Berikan Izin Tulis ke Token Ntfy

Token Ntfy secara default tidak punya izin publish ke topik tertentu. Berikan izin `write-only`:

```bash
podman exec -it ntfy-server ntfy access '*' 'alertmanager' write-only
```

Verifikasi izin sudah tersimpan:

```bash
podman exec -it ntfy-server ntfy access
```

Output yang diharapkan (baris untuk topik `alertmanager`):

```
* alertmanager write-only
```

Mengapa `write-only`? Bridge hanya perlu mengirim notifikasi, tidak perlu membaca. Prinsip least privilege — batasi hak akses seminimal mungkin. Jika token bocor, penyerang tidak bisa membaca topik Anda.

## Langkah 13: Kirim Alert Uji End-to-End

Sekarang uji seluruh pipeline: Alertmanager → bridge → Ntfy.

### Alert Uji Pertama

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "critical",
      "instance": "test-instance",
      "job": "test"
    },
    "annotations": {
      "summary": "Ini alert uji coba",
      "description": "Tes integrasi ntfy-alertmanager"
    },
    "startsAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }]'
```

### Alert Uji Kedua (Fingerprint Berbeda)

Alertmanager melakukan deduplikasi berdasarkan fingerprint (kombinasi label). Jika Anda mengirim alert dengan label identik, alert kedua tidak akan memicu notifikasi baru — ini fitur anti-spam. Untuk memicu notifikasi baru, gunakan label yang berbeda:

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {
      "alertname": "TestAlert2",
      "severity": "critical",
      "instance": "test-instance-2",
      "job": "test"
    },
    "annotations": {
      "summary": "Alert uji kedua",
      "description": "Fingerprint berbeda, harus muncul"
    },
    "startsAt": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
  }]'
```

### Cek Notifikasi di Ntfy

Buka topik Ntfy di browser:

```
http://localhost:8010/alertmanager
```

Notifikasi "Ini alert uji coba" dan "Alert uji kedua" seharusnya muncul.

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-19 23-21-34.webp>)

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-19 23-23-23.webp>)

> Catatan tentang deduplikasi Alertmanager:
> - `curl` pertama dengan label A → notifikasi terkirim
> - `curl` kedua dengan label A sama → tidak ada notifikasi (deduplikasi)
> - `curl` dengan label B berbeda → notifikasi terkirim
> - `curl` setelah `repeat_interval` (default 12 jam) lewat → notifikasi terkirim ulang
>
> Ini bukan bug, melainkan fitur anti-spam bawaan Alertmanager.
{: .prompt-info}

## Konfigurasi Grafana

### Login ke Grafana

Buka browser ke `http://localhost:3003` (perhatikan port 3003, bukan 3000). Login dengan:

- Username: `admin`
- Password: nilai `GRAFANA_ADMIN_PASSWORD` dari `.env`

### Setup Data Source Prometheus

1. Cari Data Sources
   ![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 18-25-32.webp>)

2. Klik Prometheus
   ![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 18-25-59.webp>)

4. Scroll ke bawah → klik Save & Test
   ![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 18-26-17.webp>)

Output yang diharapkan:

```
Successfully queried the Prometheus API.
```

Mengapa perlu Save & Test? Grafana tidak otomatis tahu apakah URL `http://prometheus:9090` bisa diakses dari dalam container Grafana. Test ini melakukan HTTP request aktual ke Prometheus API dan memvalidasi response. Jika gagal, cek: 
1. Apakah kedua container di network yang sama 
2. Apakah URL benar (bukan `localhost`)

### Import Dashboard

Download dashboard dari [cloud.ricalnet.my.id](https://cloud.ricalnet.my.id/s/TLa5HKPWJdPM4KN) atau langsung dari [Grafana.com](https://grafana.com).

Cara import:

1. Klik Dashboard → New → Import
   ![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 18-26-45.webp>)

2. Klik Upload JSON file → pilih file
   ![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 19-04-57.webp>)

4. Pilih data source Prometheus
5. Klik Import

Dashboard yang direkomendasikan:

| Dashboard                 | ID    | Fungsi                                 |
| ------------------------- | ----- | -------------------------------------- |
| Node Exporter Full        | 1860  | Host metrics (CPU, RAM, disk, network) |
| Alertmanager              | 9578  | Status & history alert                 |
| Prometheus                | 19105 | Prometheus internal metrics            |
| Podman Exporter Dashboard | 21559 | Container metrics (44 container)       |

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 18-29-01.webp>)

Mengapa 4 dashboard ini:
- `1860` — dashboard paling komprehensif untuk host metrics, mendukung Raspberry Pi
- `9578` — visibility ke alert routing
- 19105 — versi terbaru, kompatibel dengan Prometheus 3.x (3662 sudah outdated)
- `21559` — dashboard resmi untuk Podman Exporter, menampilkan CPU/memory/network per container

### Tampilan Dashboard

Alertmanager:

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 12-15-35.webp>)

Menampilkan status cluster, receiver, dan riwayat alert. Berguna untuk debugging mengapa notifikasi tidak terkirim.

Node Exporter Full:

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 12-15-40.webp>)

Dashboard paling kaya — CPU per core, memory breakdown, disk I/O, network traffic, uptime, dll. Cocok untuk monitoring host harian.

Podman Exporter Dashboard:

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 12-15-46.webp>)

Panel CPU, memory, network, block I/O per container. Dengan 44 container, dashboard ini memberikan visibility granular ke setiap service.

Prometheus:

![alt text](<../assets/img/posts/2026-09-16-panduan-lengkap-deploy-monitoring-stack-self-hosted-dengan-podman-prometheus-dan-grafana/Screenshot From 2026-09-16 12-15-54.webp>)

Menampilkan Prometheus version, TSDB head series, discovered targets, config reload status. Berguna untuk memastikan Prometheus sendiri sehat.

## Kesimpulan

Anda telah berhasil membangun monitoring stack lengkap untuk infrastruktur self-hosted:

- Prometheus scrape 5 target + 44 container
- Grafana dengan 4 dashboard production-ready
- Node Exporter untuk host metrics
- Podman Exporter untuk container metrics dengan label human-readable
- Alertmanager dengan 17 alert rules
- Ntfy-Alertmanager bridge untuk notifikasi push end-to-end

Yang perlu diingat:
- Grafana di port 3003 (bukan 3000)
- Ntfy di dua network (`monitoring_network` + `ntfy_network`)
- Password di `.env`
- Bridge `ntfy-alertmanager` listen di `:8080` (bukan `127.0.0.1:8080`)
- `topic` di config bridge harus URL lengkap dengan protokol `http://` dan port `80`
- Token Ntfy butuh ACL `write-only` ke topik `alertmanager`
- Deduplikasi Alertmanager mencegah notifikasi duplikat dalam `repeat_interval`

Monitoring stack ini akan menjadi mata dan telinga infrastruktur Anda — mendeteksi masalah sebelum user melapor, dan memberikan data historis untuk capacity planning.

## Referensi

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/)
- [Podman Exporter](https://github.com/navidys/prometheus-podman-exporter)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [Ntfy Access Control](https://docs.ntfy.sh/config/#access-control)