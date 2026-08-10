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

| Keunggulan              | Penjelasan                                                                       |
| ----------------------- | -------------------------------------------------------------------------------- |
| Bebas Iklan & Pelacakan | Tidak ada algoritma yang memanipulasi konten Anda                                |
| Format Universal        | Mendukung berbagai format media di semua perangkat (TV, ponsel, tablet, desktop) |
| Transcoding Cerdas      | Menyesuaikan kualitas dengan kemampuan perangkat dan bandwidth                   |
| Multi-User              | Kontrol akses perpustakaan per pengguna                                          |
| Open Source             | Transparan, dapat diaudit, dikembangkan komunitas global                         |

## Langkah 1: Clone Repository dan Persiapan Awal

Repositori `digital-independence` berisi kumpulan script dan konfigurasi untuk berbagai layanan self-hosted. Dengan mengkloningnya, Anda mendapatkan akses ke konfigurasi Jellyfin yang telah teruji dan siap pakai.

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

Mengapa clone repository?
- Konfigurasi sudah teruji dan siap pakai
- Tidak perlu menulis `docker-compose.yml` dari nol
- Update konfigurasi mudah dengan `git pull`

## Langkah 2: Instalasi Docker Engine

Untuk Debian:
```bash
./install-docker-engine-on-debian.sh
```

Untuk Ubuntu:
```bash
./install-docker-engine-on-ubuntu.sh
```

### Apa yang Dilakukan Script Instalasi?

| Langkah                     | Fungsi                                            | Mengapa                                                                           |
| --------------------------- | ------------------------------------------------- | --------------------------------------------------------------------------------- |
| Update repository           | Memperbarui daftar paket                          | Mendapatkan versi terbaru yang tersedia                                           |
| Install dependencies        | `ca-certificates`, `curl`, `gnupg`, `lsb-release` | Diperlukan untuk mengunduh dan memverifikasi Docker                               |
| Tambah GPG key              | Memverifikasi keaslian paket                      | Mencegah instalasi paket yang dimodifikasi (man-in-the-middle)                    |
| Konfigurasi repository      | Mengarahkan ke repo resmi Docker                  | Mendapatkan versi terbaru, bukan versi dari repo distro (yang biasanya lebih tua) |
| Install Docker              | Docker Engine, CLI, Containerd                    | Komponen inti untuk menjalankan kontainer                                         |
| Tambah user ke group docker | Menghindari `sudo` setiap perintah                | Kemudahan penggunaan; tapi tetap perlu logout/login                               |

> Docker menyediakan isolasi lingkungan yang sempurna untuk Jellyfin. Dengan kontainer, Anda mendapatkan:
> - Berjalan identik di semua sistem (tidak ada "di komputer saya jalan kok")
> - Tidak ada konflik dependensi dengan aplikasi lain
> - Update: cukup pull image baru dan restart kontainer
> - Rollback: kembali ke versi sebelumnya dengan satu perintah
{: .prompt-info}

## Langkah 3: Persiapan Direktori Jellyfin

```bash
cd jellyfin
mkdir -p config cache media media2
```

### Struktur Direktori dan Fungsinya

| Direktori | Fungsi                                                  | Mengapa Dipisah?                                                 |
| --------- | ------------------------------------------------------- | ---------------------------------------------------------------- |
| `config`  | Pengaturan, database, metadata, preferensi pengguna     | Data kritis; harus di-backup rutin                               |
| `cache`   | Cache thumbnail, gambar, data sementara                 | Bisa dihapus tanpa kehilangan konfigurasi; meningkatkan performa |
| `media`   | Lokasi utama koleksi media (film, serial TV)            | Pemisahan memudahkan manajemen storage dan backup                |
| `media2`  | Direktori tambahan (musik, foto, atau storage terpisah) | Fleksibilitas untuk multiple storage mount                       |

Pertimbangan Penyimpanan:

| Media              | Lokasi    | Alasan                                                       |
| ------------------ | --------- | ------------------------------------------------------------ |
| `config`           | SSD       | Metadata dan database butuh akses cepat                      |
| `media` / `media2` | HDD besar | File media besar; kecepatan baca HDD cukup                   |
| Backup             | Eksternal | Backup rutin folder `config` (metadata sulit direkonstruksi) |

## Langkah 4: Deployment dengan Docker Compose

```bash
docker compose up -d
```

### Memahami Perintah `docker compose up -d`

| Komponen        | Fungsi                                          |
| --------------- | ----------------------------------------------- |
| `up`            | Membuat dan menjalankan kontainer               |
| `-d` (detached) | Menjalankan di background; terminal tetap bebas |

**Apa yang terjadi di balik layar?**

1. Docker Compose membaca file `docker-compose.yml` (atau `compose.yaml`)
2. Menarik image Jellyfin dari Docker Hub jika belum ada
3. Membuat volume dan network sesuai definisi
4. Menjalankan kontainer dengan konfigurasi yang ditentukan
5. Melakukan health check untuk memastikan layanan berjalan normal

---

## Langkah 5: Monitoring Log Awal

```bash
docker compose logs -f
```

| Opsi          | Fungsi                                |
| ------------- | ------------------------------------- |
| `-f` (follow) | Mengikuti output log secara real-time |

### Mengapa Memeriksa Log?

Log memberikan informasi kritis tentang status deployment:

- Tahapan inisialisasi Jellyfin
- Potensi masalah seperti port conflict atau permission error
- Proses pembuatan database pertama kali
- Aktivitas awal scanning media (jika ada)

Apa yang harus diperhatikan di log?
- `[INF]` → Informasi normal; tidak perlu khawatir
- `[WRN]` → Peringatan; mungkin perlu diperhatikan, tapi biasanya tidak kritis
- `[ERR]` → Error; perlu diinvestigasi (biasanya permission atau port)

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

1. Buat Pengguna Admin
   - Isi username dan password untuk pengguna pertama
   - Pengguna ini akan memiliki hak akses penuh (admin)

2. Tambahkan Media Library

   | Pengaturan        | Keterangan                                     |
   | ----------------- | ---------------------------------------------- |
   | Content Type      | Film, TV Shows, Music, Photos, dll.            |
   | Folder            | `/media` atau `/media2` (path dalam kontainer) |
   | Metadata Language | Pilih bahasa (Indonesia jika tersedia)         |

3. Konfigurasi Metadata
   - Pilih provider metadata: **TMDB** (The Movie Database), **TVDB** (The TV Database), dll.
   - Metadata provider menyediakan sinopsis, poster, rating, dan informasi lain secara otomatis

## Pemeliharaan dan Update

### Update Jellyfin

```bash
docker compose pull jellyfin
docker compose up -d
```

| Perintah        | Fungsi                                                       |
| --------------- | ------------------------------------------------------------ |
| `pull jellyfin` | Mengunduh image versi terbaru (tanpa menghentikan kontainer) |
| `up -d`         | Memulai ulang kontainer dengan image baru                    |

Dengan pull terlebih dahulu, downtime minimal. Kontainer lama tetap berjalan selama proses download image baru.

### Backup Konfigurasi

```bash
tar -czf jellyfin-backup-$(date +%Y%m%d).tar.gz jellyfin/config/
```

Mengapa backup config penting?
- Database metadata berisi semua informasi koleksi Anda
- Konfigurasi pengguna dan preferensi tersimpan di sini
- Jika hilang, Anda harus mensetup ulang dari awal

## Troubleshooting Umum

| Masalah                      | Kemungkinan Penyebab                       | Solusi                                                             |
| ---------------------------- | ------------------------------------------ | ------------------------------------------------------------------ |
| Port 8096 sudah digunakan    | Ada aplikasi lain di port yang sama        | Ubah port di `docker-compose.yml`                                  |
| Permission denied pada media | User dalam kontainer tidak punya akses     | Pastikan folder media readable: `chmod -R 755 media/`              |
| Transcoding gagal            | Hardware acceleration tidak terkonfigurasi | Cek dokumentasi hardware acceleration Jellyfin                     |
| Tidak bisa scan media        | Format file tidak dikenali                 | Periksa format file; Jellyfin mendukung sebagian besar format umum |

## Kesimpulan

Dengan menyelesaikan panduan ini, Anda telah membangun media server pribadi yang:

- Mandiri → Tidak bergantung pada layanan pihak ketiga
- Privat → Data tetap di infrastruktur Anda sendiri
- Kustom → Dapat dikonfigurasi sesuai kebutuhan
- Gratis → Tidak ada biaya langganan berulang

Langkah selanjutnya yang bisa dieksplorasi:

| Fitur Lanjutan                 | Fungsi                                        |
| ------------------------------ | --------------------------------------------- |
| Hardware Acceleration          | Menggunakan GPU untuk transcoding lebih cepat |
| SSL/TLS                        | Mengamankan akses dengan HTTPS                |
| Reverse Proxy                  | Mengakses Jellyfin melalui domain sendiri     |
| Integrasi dengan media lainnya | Musik, foto, audiobook                        |
| Plugins                        | Plugin Jellyfin untuk fitur tambahan          |

## Referensi dan Sumber Daya

- [Digital Independence Repository](https://github.com/ricalnet/digital-independence)
- [Dokumentasi Resmi Jellyfin](https://jellyfin.org/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Hardware Acceleration Guide](https://jellyfin.org/docs/general/administration/hardware-acceleration/)
- [Jellyfin Clients](https://jellyfin.org/clients/)