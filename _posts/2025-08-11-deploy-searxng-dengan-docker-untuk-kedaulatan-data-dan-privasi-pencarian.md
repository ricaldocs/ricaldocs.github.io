---
title: Deploy SearXNG dengan Docker untuk Kedaulatan Data dan Privasi Pencarian
description: Tingkatkan privasi online Anda dengan memandu sendiri mesin pencari SearXNG menggunakan Docker. Panduan langkah demi langkah ini mencakup instalasi, dua metode deployment (dengan Caddy untuk pemula), manajemen kontainer, dan pembaruan sistem. Bebas dari pelacakan dan sensor.
categories: [Digital Independence, Search Engine]
tags: [self-hosted, docker, searxng]
author: rical
last_modified_at: 2026-07-01
---

## Pendahuluan

Mesin pencari seperti Google, Bing, atau Yahoo telah menjadi gerbang utama akses informasi bagi miliaran pengguna. Namun, di balik kemudahan yang ditawarkan, terdapat biaya tersembunyi yang signifikan: data pribadi Anda dikumpulkan, dianalisis, dan dimonetisasi; hasil pencarian dipersonalisasi berdasarkan profil Anda (menciptakan "filter bubble"); dan di beberapa wilayah, sensor serta pembatasan konten menjadi kenyataan pahit yang membatasi akses terhadap informasi.

SearXNG hadir sebagai solusi elegan untuk masalah ini. Sebagai mesin pencari metasearch yang bersifat open-source dan berorientasi privasi, SearXNG bertindak sebagai agregator yang mengumpulkan hasil dari berbagai mesin pencari lain (termasuk Google, Bing, DuckDuckGo, dan lainnya) tanpa pernah menyimpan data pribadi pengguna. Dengan menghosting SearXNG sendiri, Anda mendapatkan kendali penuh atas:
- Tidak ada pihak ketiga yang mengakses riwayat pencarian Anda
- Dapatkan hasil yang tidak difilter berdasarkan lokasi geografis
- Tidak ada cookie pelacak, tidak ada IP logging, tidak ada personalisasi yang mengancam privasi

## Instalasi Docker

Docker adalah prerequisite mutlak sebelum menjalankan SearXNG. Ricalnet menyediakan script instalasi otomatis yang telah teruji di berbagai distribusi Linux.

### Clone Repository dan Instalasi Otomatis

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

### Instalasi Docker Engine

Untuk Debian:
```bash
./install-docker-engine-on-debian.sh
```

Untuk Ubuntu:
```bash
./install-docker-engine-on-ubuntu.sh
```

#### Apa yang Dilakukan Script Instalasi?
Script ini mengotomatiskan proses yang biasanya memakan waktu dan rawan kesalahan:
1. Update package repository sistem
2. Install dependencies (ca-certificates, curl, gnupg, lsb-release)
3. Tambahkan GPG key resmi Docker untuk verifikasi keamanan
4. Konfigurasi repository Docker agar menggunakan paket resmi
5. Install Docker Engine, CLI, dan Containerd
6. Tambahkan user saat ini ke group docker (menghindari penggunaan `sudo` setiap kali)

> Docker menyediakan isolasi lingkungan yang sempurna untuk SearXNG. Dengan kontainer, Anda mendapatkan:
- Berjalan identik di semua sistem
- Tidak ada konflik dengan aplikasi lain di server
- Cukup pull image baru dan restart kontainer untuk update
- Kembali ke versi sebelumnya dengan satu perintah
{: .prompt-info}

## Deployment SearXNG

Metode ini ideal untuk penggunaan awal atau lingkungan pengembangan di localhost.

#### Langkah 1: Navigasi ke Direktori SearXNG

```bash
cd searxng
```

#### Langkah 2: Konfigurasi Environment

```bash
cp .env.example .env
```

File `.env` berisi variabel environment yang digunakan oleh Docker Compose. Beberapa parameter penting yang perlu diperhatikan:

| Variabel           | Deskripsi                                    | Contoh Nilai                          |
| ------------------ | -------------------------------------------- | ------------------------------------- |
| `SEARXNG_HOSTNAME` | Domain atau IP publik tempat SearXNG diakses | `search.example.com` atau `localhost` |

#### Langkah 3: Edit File `.env` (Opsional)

Jika diperlukan, edit file `.env` menggunakan editor teks:
```bash
nano .env
```

#### Langkah 4: Jalankan Kontainer

```bash
docker compose up -d
```

Flag `-d` (detach mode) menjalankan kontainer di background, memungkinkan terminal Anda tetap digunakan.

#### Langkah 5: Verifikasi Status

```bash
docker compose logs -f
```

Perintah ini menampilkan log real-time dari semua kontainer. Anda akan melihat pesan seperti:
```
searxng  | [INFO] Starting granian (main PID: 1)
searxng  | [INFO] Listening at: http://:::8080
```

#### Langkah 6: Akses SearXNG

Buka browser dan akses:
```
http://localhost:8888
```

> Port 8888 dikonfigurasi di `docker-compose.yml` sebagai port publik (host) yang memetakan ke port internal kontainer (8080). Pemetaan ini memungkinkan akses dari host tanpa mengganggu port standar web (80/443).
{: .prompt-info}

## Pembaruan dan Pemeliharaan Sistem

### Pembaruan SearXNG

Untuk memperbarui SearXNG ke versi terbaru:

Langkah 1: Pull image terbaru
```bash
docker compose pull
```

Langkah 2: Re-create kontainer
```bash
docker compose up -d --force-recreate
```

Langkah 3: Bersihkan image lama (opsional)
```bash
docker image prune -f
```

> Dengan `docker compose pull`, kita memastikan image terbaru diunduh sebelum melakukan restart, meminimalkan downtime. Flag `--force-recreate` memaksa pembuatan kontainer baru dari image yang sudah di-pull.
{: .prompt-info}

## Kesimpulan

Dengan menyelesaikan panduan ini, Anda sekarang memiliki mesin pencari pribadi yang:
- Melindungi privasi Anda dari pelacakan komersial
- Memberikan akses informasi tanpa sensor
- Dapat diandalkan dengan konfigurasi Docker yang robust
- Mudah dikelola dengan update dan backup yang terstruktur

Dengan mengikuti prinsip-prinsip dalam panduan ini, Anda tidak hanya menginstal perangkat lunak—Anda mengambil langkah konkret menuju kemerdekaan digital. SearXNG bukan sekadar mesin pencari; ini adalah pernyataan bahwa privasi adalah hak fundamental, bukan komoditas yang dapat diperjualbelikan.

## Referensi dan Sumber Daya

- [Digital Independence Repository](https://github.com/ricalnet/digital-independence)
- [Panduan Implementasi Hidden Service Tor](https://ricaldocs.github.io/posts/panduan-implementasi-hidden-service-tor/)
- [SearXNG Documentation](https://docs.searxng.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Caddy Server Documentation](https://caddyserver.com/docs/)
