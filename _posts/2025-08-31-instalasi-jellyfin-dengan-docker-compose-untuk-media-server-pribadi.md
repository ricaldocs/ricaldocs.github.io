---
title: Instalasi Jellyfin dengan Docker Compose untuk Media Server Pribadi
description: Panduan lengkap instalasi Jellyfin media server menggunakan Docker Compose. Tutorial self-hosted untuk streaming film, musik, dan foto tanpa biaya langganan.
categories: [Digital Independence, Multimedia]
tags: [self-hosted, docker, jellyfin]
author: rical
last_modified_at: 2026-07-01
---

## Pendahuluan

Jellyfin merupakan solusi media server open-source yang memungkinkan Anda mengelola dan menikmati koleksi media digital secara mandiri. Berbeda dengan layanan streaming komersial seperti Netflix atau Spotify, Jellyfin memberikan kendali penuh atas data, privasi, dan infrastruktur Anda tanpa biaya langganan bulanan.

### Mengapa Jellyfin?

- Tidak ada iklan, tidak ada pelacakan, tidak ada batasan konten buatan algoritma
- Dukungan untuk berbagai format media dan perangkat (smart TV, ponsel, tablet, desktop)
- Menyesuaikan kualitas streaming dengan kemampuan perangkat dan bandwidth
- Dukungan untuk banyak pengguna dengan kontrol akses perpustakaan
- Transparan, dapat diaudit, dan dikembangkan oleh komunitas global

## Langkah 1: Clone Repository dan Persiapan Awal

Repositori `digital-independence` berisi kumpulan script dan konfigurasi untuk berbagai layanan self-hosted. Dengan mengkloningnya, Anda mendapatkan akses ke konfigurasi Jellyfin yang telah teruji dan siap pakai.

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

## Langkah 2: Instalasi Docker Engine

**Untuk Debian:**
```bash
./install-docker-engine-on-debian.sh
```

**Untuk Ubuntu:**
```bash
./install-docker-engine-on-ubuntu.sh
```

### Apa yang Dilakukan Script Instalasi?
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

## Langkah 3: Persiapan Direktori Jellyfin

```bash
cd jellyfin
mkdir -p config cache media media2
```

### Struktur Direktori dan Fungsinya

| Direktori | Fungsi                                                                     | Mengapa Dipisah?                                        |
| --------- | -------------------------------------------------------------------------- | ------------------------------------------------------- |
| `config`  | Menyimpan pengaturan, database, metadata, dan preferensi pengguna          | Data kritis yang harus dibackup secara rutin            |
| `cache`   | Cache thumbnail, gambar, dan data sementara                                | Performance; dapat dihapus tanpa kehilangan konfigurasi |
| `media`   | Lokasi utama koleksi media (film, serial TV)                               | Pemisahan memudahkan manajemen storage dan backup       |
| `media2`  | Direktori tambahan untuk media (misal: musik, foto, atau storage terpisah) | Fleksibilitas untuk multiple storage mount              |

Pertimbangan Penyimpanan:
- Tempatkan `media` dan `media2` pada volume terpisah dengan kapasitas besar (HDD)
- Simpan `config` pada SSD untuk akses cepat ke metadata dan database
- Backup rutin folder `config` karena berisi konfigurasi dan metadata yang sulit direkonstruksi

## Langkah 4: Deployment dengan Docker Compose

```bash
docker compose up -d
```

### Memahami Perintah `docker compose up -d`
- `up`: Membuat dan menjalankan kontainer
- `-d` (detached): Menjalankan di background, terminal tetap bebas untuk perintah lain

Apa yang terjadi di balik layar?
1. Docker Compose membaca file `docker-compose.yml` (atau `compose.yaml`)
2. Menarik image Jellyfin dari Docker Hub jika belum ada
3. Membuat volume dan network sesuai definisi
4. Menjalankan kontainer dengan konfigurasi yang ditentukan
5. Melakukan health check untuk memastikan layanan berjalan normal

## Langkah 5: Monitoring Log Awal

```bash
docker compose logs -f
```

### Mengapa Memeriksa Log?

Log memberikan informasi kritis tentang status deployment:
- Tahapan inisialisasi Jellyfin
- Menangkap masalah seperti port conflict atau permission error
- Proses pembuatan database pertama kali
- Aktivitas awal scanning media (jika ada)

## Langkah 6: Akses dan Konfigurasi Awal

Buka browser dan akses:
```
http://localhost:8096
```
atau jika menggunakan server jarak jauh:
```
http://[IP_SERVER]:8096
```

### Setup Wizard Awal

1. Isi username dan password untuk pengguna pertama
2. Tambahkan Media Library:
   - Pilih tipe konten (Film, TV Shows, Music, Photos, dll.)
   - Folder: `/media` atau `/media2` (path dalam kontainer)
   - Pilih bahasa metadata (preferensi Indonesia jika tersedia)
3. Konfigurasi Metadata: Pilih preferensi provider metadata (TMDB, TVDB, dll.)

## Pemeliharaan dan Update

### Update Jellyfin
```bash
docker compose pull jellyfin
docker compose up -d
```

## Kesimpulan

Dengan menyelesaikan panduan ini, Anda telah membangun media server pribadi yang:
- Tidak bergantung pada layanan pihak ketiga
- Data tetap di infrastruktur Anda sendiri
- Dapat dikustomisasi sesuai kebutuhan
- Tidak ada biaya langganan berulang

## Referensi dan Sumber Daya

- [Digital Independence Repository](https://github.com/ricalnet/digital-independence)
- [Panduan Implementasi Hidden Service Tor](https://ricaldocs.github.io/posts/panduan-implementasi-hidden-service-tor/)
- [Dokumentasi Resmi Jellyfin](https://jellyfin.org/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Hardware Acceleration Guide](https://jellyfin.org/docs/general/administration/hardware-acceleration/)
- [Jellyfin Clients](https://jellyfin.org/clients/)