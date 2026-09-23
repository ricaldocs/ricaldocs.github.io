---
title: Deploy MQTT Broker dengan Podman — Panduan Teknis Eclipse Mosquitto
description: Panduan teknis lengkap untuk deploy Eclipse Mosquitto MQTT Broker menggunakan Podman. Mencakup konfigurasi ACL, manajemen password, pengujian publish-subscribe, dan hardening keamanan untuk infrastruktur IoT.
categories: [Digital Independence, Telecommunications]
tags: [internet of things, mqtt, podman]
author: rical
last_modified_at: 2026-09-15
---

## Ringkasan

Dokumen ini menjelaskan prosedur deployment Eclipse Mosquitto MQTT Broker menggunakan Podman dalam lingkungan terisolasi. Mosquitto berfungsi sebagai message broker yang menerapkan protokol MQTT (Message Queuing Telemetry Transport) — protokol ringan berbasis publish-subscribe yang dirancang untuk perangkat dengan sumber daya terbatas dan jaringan tidak stabil.

Mengapa Mosquitto? Mosquitto mendukung MQTT yang menyediakan fitur persistence, bridge, TLS, dan WebSocket — menjadikannya pilihan ideal untuk infrastruktur IoT skala kecil hingga menengah.

Mengapa Podman? Podman berjalan tanpa daemon (daemonless) dan mendukung rootless container, mengurangi permukaan serangan dibandingkan Docker daemon yang berjalan sebagai root.

## 1. Prasyarat

| Komponen                          | Keterangan                            |
| --------------------------------- | ------------------------------------- |
| Podman                            | Runtime container                     |
| `podman-compose`                  | Orkestrasi multi-container            |
| Akses `sudo`                      | Konfigurasi port dan kepemilikan file |
| Repositori `digital-independence` | Sumber konfigurasi dan skrip          |

Mengapa perlu `sudo`? Operasi `ipc enable` memodifikasi aturan firewall kernel-level, dan `chown` mengubah kepemilikan file yang dimiliki UID container — keduanya memerlukan privilege elevated.

## 2. Kloning Repositori

```bash
git clone https://git.ricalnet.my.id/rical/digital-independence.git ~/digital-independence
./install-podman-on-debian.sh
dipen cd mqtt
```

Penjelasan:
- `git clone` — mengambil repositori ke direktori home pengguna.
- `install-podman-on-debian.sh` — skrip instalasi Podman untuk Debian; memastikan dependensi terpasang sebelum deployment.
- `dipen cd mqtt` — berpindah ke direktori kerja yang berisi `compose.yaml` dan folder `config/`.

## 3. Membuka Port yang Dibutuhkan

```bash
sudo ipc enable 1883 both both
sudo ipc enable 9001 both both
sudo ipc status
```

Port yang dibuka:

| Port | Protokol | Fungsi               |
| ---- | -------- | -------------------- |
| 1883 | TCP/UDP  | MQTT native          |
| 9001 | TCP/UDP  | MQTT over WebSocket  |
| 9883 | TCP/UDP  | Dashboard monitoring |

Mengapa TCP dan UDP? MQTT standar menggunakan TCP untuk koneksi persisten. UDP diaktifkan untuk skenario MQTT-SN (Sensor Network) atau fallback. Parameter `both both` berarti kedua protokol dan kedua arah (inbound/outbound).

> `ipc status` memastikan aturan firewall aktif sebelum container dijalankan — mencegah kegagalan koneksi yang sulit didiagnosis.
{: .prompt-info}

## 4. Menjalankan dan Menghentikan Stack

```bash
dipen up mqtt
```

`dipen` adalah wrapper CLI internal yang membungkus `podman-compose`. Perintah `up mqtt` membuat dan menjalankan container beserta volume dan network yang didefinisikan.

Mengapa wrapper? Menyederhanakan perintah kompleks dan menstandardisasi lifecycle management (up, fresh, ps, logs) di seluruh stack.

## 5. Menyalin Konfigurasi ke Volume

```bash
sudo cp config/acl ~/.local/share/containers/storage/volumes/mosquitto_config/_data
sudo cp config/mosquitto.conf ~/.local/share/containers/storage/volumes/mosquitto_config/_data
ls -la ~/.local/share/containers/storage/volumes/mosquitto_config/_data
cat ~/.local/share/containers/storage/volumes/mosquitto_config/_data/mosquitto.conf
```

Mengapa volume, bukan bind mount? Podman volume dikelola penuh oleh runtime, memberikan isolasi lebih baik dan portabilitas antar sistem. Path `_data` adalah direktori fisik tempat volume menyimpan data.

File konfigurasi:
- `mosquitto.conf` — konfigurasi utama: listener, autentikasi, persistence, logging.
- `acl` — Access Control List: mendefinisikan hak akses per-user per-topik.

> `cat` memastikan file tersalin utuh dan tidak terpotong.
{: .prompt-info}

## 6. Manajemen Password

Mosquitto menggunakan autentikasi password file berbasis hash. Setiap user memiliki kredensial terpisah untuk menerapkan prinsip least privilege.

### 6.1 Membuat Password File (User `admin`)

```bash
podman run --rm -it \
  -v mosquitto_config:/mosquitto/config \
  docker.io/eclipse-mosquitto:latest \
  mosquitto_passwd -c -b /mosquitto/config/passwd admin changeme
```

Parameter kunci:
- `--rm` — hapus container setelah eksekusi (one-shot).
- `-v` — mount volume yang sama dengan container utama.
- `-c` — buat file password baru (overwrite jika ada).
- `-b` — mode batch: password diberikan via argumen, bukan prompt interaktif.

### 6.2 Menambahkan User `mqtt_user`

```bash
podman run --rm -it \
  -v mosquitto_config:/mosquitto/config \
  docker.io/eclipse-mosquitto:latest \
  mosquitto_passwd -b /mosquitto/config/passwd mqtt_user changeme
```

Flag `-c` dihilangkan agar file password yang sudah ada tidak ditimpa. Menambahkan `-c` akan menghapus semua user sebelumnya.

### 6.3 Menambahkan User `user`

```bash
podman run --rm -it \
  -v mosquitto_config:/mosquitto/config \
  docker.io/eclipse-mosquitto:latest \
  mosquitto_passwd -b /mosquitto/config/passwd user changeme2
```

### 6.4 Kepemilikan dan Permission

```bash
sudo chown -R 101882:101882 ~/.local/share/containers/storage/volumes/mosquitto_config/_data/acl
sudo chown -R 101882:101882 ~/.local/share/containers/storage/volumes/mosquitto_config/_data/passwd

sudo chmod 0700 ~/.local/share/containers/storage/volumes/mosquitto_config/_data/acl
sudo chmod 600 ~/.local/share/containers/storage/volumes/mosquitto_config/_data/passwd
ls -la ~/.local/share/containers/storage/volumes/mosquitto_config/_data
```

Mengapa UID 101882? Container Mosquitto berjalan sebagai user `mosquitto` dengan UID/GID spesifik di dalam image. File di host harus dimiliki UID yang sama agar container dapat membacanya.

Mengapa permission ketat?
- `0700` pada `acl` — hanya owner dapat read/write/execute; mencegah eskalasi privilege.
- `600` pada `passwd` — hanya owner dapat read/write; melindungi hash password.

## 7. Restart dan Monitoring

```bash
dipen fresh mqtt
sleep 10
dipen ps mqtt
dipen logs mqtt
```

Penjelasan:
- `fresh` — recreate container dari image (bukan sekadar restart), memastikan konfigurasi baru dimuat.
- `sleep 10` — memberi waktu inisialisasi sebelum verifikasi.
- `ps` — menampilkan status container.
- `logs` — menampilkan stdout container.

Output yang diharapkan:

```
[1/1] Processing mqtt...
▶ mqtt...
2026-09-12T05:19:28: Info: running mosquitto as user: mosquitto.
2026-09-12T05:19:28: Restored 0 base messages
2026-09-12T05:19:28: Restored 0 retained messages
2026-09-12T05:19:28: Restored 0 clients
2026-09-12T05:19:28: Restored 0 subscriptions
2026-09-12T05:19:28: mosquitto version 2.1.2 starting
2026-09-12T05:19:28: Config loaded from /mosquitto/config/mosquitto.conf.
2026-09-12T05:19:28: Bridge support available.
2026-09-12T05:19:28: Persistence support available.
2026-09-12T05:19:28: TLS support available.
2026-09-12T05:19:28: TLS-PSK support available.
2026-09-12T05:19:28: Websockets support available.
2026-09-12T05:19:28: Restored 0 client messages
2026-09-12T05:19:28: Plugin builtin-security has registered to receive 'basic-auth' events.
2026-09-12T05:19:28: Plugin builtin-security has registered to receive 'acl-check' events.
2026-09-12T05:19:28: Opening ipv4 listen socket on port 1883.
2026-09-12T05:19:28: Opening ipv4 listen socket on port 9001.
2026-09-12T05:19:28: mosquitto version 2.1.2 running
```

Interpretasi log:
- `Restored 0 ...` — tidak ada state yang dipulihkan (fresh start).
- `Plugin builtin-security` — modul autentikasi dan ACL aktif.
- `Opening ipv4 listen socket` — listener berhasil bind ke port 1883 dan 9001.
- `mosquitto version 2.1.2 running` — broker siap menerima koneksi.

## 8. Pengujian MQTT

Pengujian dilakukan dari dalam container (`podman exec`) untuk memvalidasi konektivitas internal dan eksternal secara simultan.

### 8.1 Menggunakan User `admin`

#### Subscribe ke Semua Topik

```bash
podman exec mosquitto-local mosquitto_sub \
  -h 192.168.195.219 -p 1883 \
  -t "#" \
  -i sub-admin-01 \
  -u admin -P changeme \
  -v -W 10
```

Parameter:
- `-t "#"` — wildcard multi-level; berlangganan semua topik.
- `-i` — client ID unik; mencegah konflik sesi.
- `-v` — verbose; menampilkan topik bersama payload.
- `-W 10` — timeout 10 detik; keluar otomatis.

#### Publish ke Berbagai Topik

```bash
podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "sensors/temperature" \
  -m "25" \
  -i pub-admin-01 \
  -u admin -P changeme

podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "commands/device1/reboot" \
  -m "reboot" \
  -i pub-admin-02 \
  -u admin -P changeme

podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "home/admin/status" \
  -m "online" \
  -i pub-admin-03 \
  -u admin -P changeme
```

Tujuan pengujian adalah memvalidasi bahwa `admin` memiliki akses publish ke topik sensor, command, dan status — sesuai ACL.

Output yang diharapkan:

```
2026-09-12T05:22:44: mosquitto version 2.1.2 running
2026-09-12T05:23:34: New connection from 10.89.1.1:43036 on port 1883.
2026-09-12T05:23:34: New client connected from 10.89.1.1:43036 as sub-admin-01 (p4, c1, k60, u'admin').
2026-09-12T05:23:34: sub-admin-01 0 #
2026-09-12T05:23:38: New connection from 10.89.1.1:43040 on port 1883.
2026-09-12T05:23:38: New client connected from 10.89.1.1:43040 as pub-admin-01 (p4, c1, k60, u'admin').
2026-09-12T05:23:38: Client pub-admin-01 [10.89.1.1:43040] disconnected.
2026-09-12T05:23:38: New connection from 10.89.1.1:43042 on port 1883.
2026-09-12T05:23:38: New client connected from 10.89.1.1:43042 as pub-admin-02 (p4, c1, k60, u'admin').
2026-09-12T05:23:38: Client pub-admin-02 [10.89.1.1:43042] disconnected.
2026-09-12T05:23:38: New connection from 10.89.1.1:43046 on port 1883.
2026-09-12T05:23:38: New client connected from 10.89.1.1:43046 as pub-admin-03 (p4, c1, k60, u'admin').
```

Interpretasi kode:
- `p4` — MQTT protocol level 4 (v3.1.1).
- `c1` — clean session aktif.
- `k60` — keepalive 60 detik.
- `u'admin'` — user terautentikasi.

### 8.2 Menggunakan User `mqtt_user`

#### Subscribe ke Semua Topik

```bash
podman exec mosquitto-local mosquitto_sub \
  -h 192.168.195.219 -p 1883 \
  -t "#" \
  -i sub-admin-01 \
  -u mqtt_user -P changeme \
  -v -W 10
```

#### Publish ke Berbagai Topik

```bash
podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "sensors/temperature" \
  -m "25" \
  -i pub-admin-01 \
  -u mqtt_user -P changeme

podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "commands/device1/reboot" \
  -m "reboot" \
  -i pub-admin-02 \
  -u mqtt_user -P changeme

podman exec mosquitto-local mosquitto_pub \
  -h 192.168.195.219 -p 1883 \
  -t "home/admin/status" \
  -m "online" \
  -i pub-admin-03 \
  -u mqtt_user -P changeme
```

Tujuannya adalah memvalidasi bahwa `mqtt_user` memiliki hak akses terbatas sesuai ACL — kemungkinan hanya dapat publish ke topik tertentu, bukan semua.

## 9. Catatan Keamanan

| Risiko                 | Mitigasi                                |
| ---------------------- | --------------------------------------- |
| Password default       | Ganti `changeme` dan `changeme2` segera |
| Akses topik berlebihan | Batasi via file `acl` per-user          |
| Port terekspos         | Batasi akses ke jaringan tepercaya      |
| Sniffing traffic       | Aktifkan TLS/SSL untuk produksi         |

Mengapa TLS kritis? MQTT native mengirim kredensial dalam plaintext. Tanpa TLS, password dapat diintersepsi via packet capture.

## 10. Referensi Cepat

| Komponen       | Nilai                                |
| -------------- | ------------------------------------ |
| Port MQTT      | 1883                                 |
| Port WebSocket | 9001                                 |
| Volume Config  | `mosquitto_config`                   |
| Container Name | `mosquitto-local`                    |
| Image          | `docker.io/eclipse-mosquitto:latest` |