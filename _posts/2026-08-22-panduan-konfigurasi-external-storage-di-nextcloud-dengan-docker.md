---
title: Panduan Konfigurasi External Storage di Nextcloud dengan Docker
description: Panduan implementasi external storage pada Nextcloud menggunakan Docker, mencakup konfigurasi volume mount, permission management, dan integrasi storage eksternal untuk scalable cloud storage solution.
categories: [Digital Independence, Cloud]
tags: [self-hosted, nextcloud]
author: rical
last_modified_at: 2026-08-22
---

## 1. Pendahuluan dan Konsep Dasar

External storage di Nextcloud memungkinkan integrasi dengan sistem penyimpanan eksternal, memberikan fleksibilitas dalam manajemen data dan skalabilitas infrastruktur. Implementasi ini penting untuk:
- Pemisahan data dari aplikasi core
- Skalabilitas penyimpanan tanpa mengganggu container
- Backup strategis dengan lokasi storage terpisah
- Performance optimization melalui dedicated storage volume


## 2. Prasyarat dan Persiapan

### 2.1 Verifikasi Instalasi
Pastikan Nextcloud telah terinstal dari repository:
```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence/nextcloud
```

### 2.2 Direktori Storage
Buat direktori untuk mount external storage pada host system:
```bash
# Lokasi storage eksternal (sesuaikan dengan kebutuhan)
sudo mkdir -p /media/rpi/BACKUP/nextcloud
sudo chown -R 1000:1000 /media/rpi/BACKUP/nextcloud
```

## 3. Implementasi Teknis

### 3.1 Persiapan Container Nextcloud
Masuk ke direktori Nextcloud:
```bash
cd /path/to/digital-independence/nextcloud
```

Masuk ke container Nextcloud:
```bash
docker exec -it nextcloud_app bash
```

Buat direktori mount di dalam container:
```bash
mkdir -p /var/www/html/data/external

# Keluar dari container
exit
```

Direktori ini akan menjadi titik mount untuk volume eksternal. Meskipun Docker akan membuat direktori otomatis saat volume dimount, pembuatan manual memastikan permission yang tepat dan struktur direktori yang konsisten.

### 3.2 Konfigurasi Environment Variables
Edit file .env:
```bash
nano .env
```

Tambahkan atau sesuaikan konfigurasi berikut:
```
# External Storage Configuration
EXTERNAL_STORAGE_PATH=/path/to/your-external-storage
EXTERNAL_STORAGE_MOUNT=/var/www/html/data/external/
```

- `EXTERNAL_STORAGE_PATH`: Lokasi absolut direktori storage di host system
- `EXTERNAL_STORAGE_MOUNT`: Path mount di dalam container Nextcloud

### 3.3 Deployment dengan Docker Compose
```bash
docker compose down
docker compose up -d
```

Docker Compose membaca ulang konfigurasi volume mount dari `.env` file. Restart diperlukan untuk menerapkan binding mount baru tanpa rebuild image.

## 4. Konfigurasi di Nextcloud Web Interface

### 4.1 Aktivasi External Storage App
1. Login ke Nextcloud sebagai admin
2. Navigasi ke Settings → Apps
3. Cari "External Storage" atau "External Storage Support"
4. Aktifkan aplikasi
   ![alt text](../assets/img/posts/2026-08-22-panduan-konfigurasi-external-storage-di-nextcloud-dengan-docker/image.png)

### 4.2 Konfigurasi External Storage
1. Buka Settings → Administration → External Storage
   ![alt text](<../assets/img/posts/2026-08-22-panduan-konfigurasi-external-storage-di-nextcloud-dengan-docker/image copy.png>)

3. Tambahkan External Storage:
   - Folder name: `External Storage`
   - External storage: `Local (server storage)`
   - Location: `/var/www/html/data/external/`
     ![alt text](<../assets/img/posts/2026-08-22-panduan-konfigurasi-external-storage-di-nextcloud-dengan-docker/image copy 2.png>)

## 5. Manajemen Permission dan Security

### 5.1 Permission Sistem
```bash
sudo chown -R 1000:1000 /media/rpi/BACKUP/nextcloud
sudo chmod 755 /media/rpi/BACKUP/nextcloud
sudo find /media/rpi/BACKUP/nextcloud -type f -exec chmod 644 {} \;
```

## 6. Validasi dan Testing

### 6.1 Test Upload
Buat file test:
```bash
touch /media/rpi/BACKUP/nextcloud/test.txt
```

### 6.2 User Access Test
1. Login sebagai user biasa
2. Navigasi ke Files → External Storage
3. Create/upload file
4. Verify file creation dan permission

Catatan Penting:
- Selalu backup konfigurasi sebelum perubahan
- Gunakan environment yang sama untuk production
- Monitoring rutin untuk optimalisasi storage
- Document setiap perubahan konfigurasi untuk audit trail

## 7. Enkripsi Server-Side untuk External Storage

### 7.1 Latar Belakang dan Konsep

Setelah berhasil mengkonfigurasi external storage, langkah selanjutnya yang krusial adalah memastikan keamanan data saat at-rest. Secara default, file yang disimpan melalui external storage tidak terenkripsi dan dapat diakses langsung dari filesystem host. Untuk melindungi data dari akses tidak sah, Nextcloud menyediakan fitur Server-Side Encryption (SSE).

SSE bekerja dengan mengenkripsi konten file sebelum ditulis ke storage menggunakan kunci yang dikelola oleh server. Hal ini memastikan bahwa meskipun penyimpanan fisik (hard disk, SSD, atau cloud storage) diakses langsung, data tetap tidak dapat dibaca tanpa kunci dekripsi yang valid.

### 7.2 Prasyarat Aktivasi Enkripsi

Sebelum menjalankan proses enkripsi, pastikan kondisi berikut terpenuhi:

| Prasyarat         | Keterangan                                                                                   |
| ----------------- | -------------------------------------------------------------------------------------------- |
| Mode Maintenance  | Nextcloud harus dalam mode pemeliharaan untuk mencegah perubahan data selama proses enkripsi |
| Backup Data       | Backup penuh direktori data dan database sebelum memulai untuk mitigasi risiko               |
| Koneksi Stabil    | Pastikan koneksi antara container dan storage tidak terputus selama proses                   |
| Kapasitas Storage | Pastikan ruang penyimpanan mencukupi (proses enkripsi membutuhkan ruang tambahan)            |

### 7.3 Aktivasi Modul Enkripsi

Langkah pertama adalah mengaktifkan modul enkripsi default melalui antarmuka web:

1. Login sebagai admin Nextcloud
2. Navigasi ke Settings → Administration → Server-side encryption
3. Centang opsi Enable server-side encryption
4. Klik Save untuk menyimpan konfigurasi

### 7.4 Menjalankan Proses Enkripsi

Setelah modul enkripsi diaktifkan, jalankan perintah berikut untuk mengenkripsi seluruh file yang sudah ada, termasuk yang berada di external storage:

Masuk ke dalam container Nextcloud:
```bash
docker exec -it nextcloud_app bash
```

```bash
# Aktifkan maintenance mode
php occ maintenance:mode --on

# Jalankan proses enkripsi untuk semua file
php occ encryption:encrypt-all

# Nonaktifkan maintenance mode setelah selesai
php occ maintenance:mode --off
```

Perintah `encryption:encrypt-all` akan mengenkripsi seluruh file yang telah diunggah ke sistem, baik yang berada di storage internal maupun external. Proses ini berjalan secara bertahap dan dapat memakan waktu cukup lama tergantung pada jumlah dan ukuran file.

### 7.5 Verifikasi Status Enkripsi

Untuk memastikan enkripsi berhasil diterapkan, cek status enkripsi dari command line:
```bash
php occ encryption:status

# Output yang diharapkan:
# - Enabled: true
# - Default module: OC_DEFAULT_MODULE
```

### 7.6 Rekomendasi Setelah Enkripsi

- Uji akses file dari beberapa user untuk memastikan enkripsi tidak mengganggu fungsionalitas
- Lakukan backup kunci enkripsi secara berkala untuk menghindari kehilangan akses data
- Monitor log Nextcloud selama beberapa hari setelah enkripsi untuk mendeteksi potensi error