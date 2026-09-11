---
title: Panduan Lengkap Instalasi MediaWiki untuk Digital Independence
description: Tutorial teknis instalasi MediaWiki menggunakan Podman di lingkungan Linux. Panduan langkah demi langkah untuk mengelola wiki pribadi dengan konfigurasi optimal dan keamanan terjamin.
categories: [Digital Independence, Wiki]
tags: [mediawiki, podman]
author: rical
last_modified_at: 2026-09-11
---

## Mengapa MediaWiki? Membangun Basis Pengetahuan yang Anda Kendalikan

Wikipedia adalah salah satu pencapaian terbesar internet — sebuah ensiklopedia yang dibangun oleh jutaan kontributor, bebas diakses siapa saja, dan tidak dimiliki oleh korporasi mana pun. Di baliknya ada MediaWiki, mesin wiki open-source yang telah terbukti skalabilitasnya selama lebih dari dua dekade.

Namun MediaWiki bukan hanya untuk Wikipedia. Ini adalah alat yang sempurna untuk:

- SOP, panduan teknis, catatan proyek
- Catatan belajar, riset, jurnal
- Klaborasi pengetahuan terbuka
- Sejarah, resep, tradisi yang terdokumentasi

Dengan self-hosting MediaWiki, Anda mendapatkan:

- Kendali penuh atas data — tidak ada pihak ketiga yang membaca atau menghapus konten Anda
- Tanpa biaya berulang — bayar sekali untuk perangkat keras, gratis selamanya
- Kustomisasi tak terbatas — instal ekstensi, ubah tampilan, atur hak akses
- Pembelajaran DevOps nyata — kelola database, web server, dan container sendiri

Dalam ekosistem Digital Independence, MediaWiki melengkapi layanan seperti Nextcloud (produktivitas), Immich (foto), dan Forgejo (kode) dengan kemampuan manajemen pengetahuan yang terstruktur.

## Memahami Komponen Inti

MediaWiki bukan aplikasi monolitik. Ia terdiri dari beberapa komponen yang bekerja sama:

### 1. MediaWiki (PHP/Apache) — Antarmuka Pengguna

Container `mediawiki` menjalankan aplikasi PHP di atas web server Apache. Ini menangani:

- Antarmuka web (halaman, editor, riwayat revisi)
- API untuk integrasi eksternal
- Manajemen pengguna dan hak akses
- Proses instalasi dan konfigurasi

Dalam konfigurasi `compose.yaml`, MediaWiki di-deploy dengan:

```yaml
mediawiki:
  image: docker.io/mediawiki:latest
  ports:
    - "127.0.0.1:8002:80"
  environment:
    - MEDIAWIKI_DB_HOST=db
    - MEDIAWIKI_DB_USER=mediawiki
    - MEDIAWIKI_DB_PASSWORD=${MYSQL_PASSWORD}
    - MEDIAWIKI_DB_NAME=mediawiki
  depends_on:
    - db
  volumes:
    - mediawiki_data:/var/www/html/images
    # - ./LocalSettings.php:/var/www/html/LocalSettings.php:ro
```

### 2. MariaDB — Penyimpanan Data

Semua konten wiki, riwayat revisi, akun pengguna, dan pengaturan disimpan dalam database MariaDB. Konfigurasi ini menggunakan MariaDB 10.11 dengan:

- Health check untuk memastikan database siap sebelum MediaWiki dimulai
- Volume persisten `db_data` untuk mencegah kehilangan data
- Resource limits (384MB memory) untuk efisiensi

### 3. LocalSettings.php — Jantung Konfigurasi

File `LocalSettings.php` adalah file konfigurasi utama MediaWiki. Ia berisi:

- Kredensial database
- Nama dan URL situs
- Secret key untuk sesi
- Pengaturan ekstensi
- Hak akses pengguna

Mengapa file ini penting? Tanpa `LocalSettings.php`, MediaWiki akan selalu masuk ke mode instalasi. File ini tidak dibuat otomatis — Anda harus mengunduhnya dari wizard instalasi dan menempatkannya di direktori yang benar.

### Diagram Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                         INTERNET                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREWALL (IPC)                           │
│                  Default-Deny, Port 8002                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    MEDIAWIKI (Apache/PHP)                   │
│              Port 8002 → 80 (localhost binding)             │
│         /var/www/html/images (volume persisten)             │
│         /var/www/html/LocalSettings.php (bind mount)        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                      MARIADB 10.11                          │
│         Database: mediawiki, User: mediawiki                │
│         Volume: mediawiki_db_data (persisten)               │
└─────────────────────────────────────────────────────────────┘
```

## Prasyarat

Sebelum memulai, pastikan sistem Anda memenuhi persyaratan berikut:

| Komponen       | Versi Minimum         | Catatan                             |
| -------------- | --------------------- | ----------------------------------- |
| Podman         | 5.4+                  | Mode rootless untuk keamanan        |
| podman-compose | v1.3+                 | Orkestrasi container                |
| Git            | Terbaru               | Clone repositori                    |
| OS             | Linux (Debian/Ubuntu) | Atau WSL2                           |
| Memori         | 2GB+                  | MediaWiki + MariaDB                 |
| Penyimpanan    | 5GB+                  | Tergantung ukuran konten dan gambar |

### Instalasi Podman dan Dependensi

Repositori Digital Independence menyediakan script instalasi otomatis:

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence/wiki
./install-podman-on-debian.sh
```

Script ini akan:
1. Memperbarui sistem dan menginstal Podman
2. Menginstal `uidmap`, `slirp4netns`, `dbus-user-session`, dan `fuse-overlayfs`
3. Mengaktifkan `linger` untuk user Anda
4. Menginstal `podman-compose`
5. Mengonfigurasi registri container
6. Mengaktifkan Podman socket
7. Menyiapkan wrapper `dipen` di `.bashrc` dan `.zshrc`

Mengapa rootless? Podman rootless menjalankan container tanpa hak akses root, mengurangi risiko eskalasi privilege jika terjadi kompromi. Ini adalah praktik keamanan terbaik untuk self-hosting.

## Langkah Deployment

### Langkah 1: Konfigurasi Environment

Setiap layanan dalam ekosistem Digital Independence memiliki file `.env.example` yang perlu disalin dan disesuaikan. Gunakan alat `dipen` untuk membuat dan mengedit file `.env` secara otomatis:

```bash
dipen env mediawiki
```

Perintah ini akan:
- Menyalin `.env.example` menjadi `.env` jika belum ada
- Membuka editor (default: `nano`) untuk Anda edit

Variabel kunci yang wajib dikonfigurasi:

| Variabel              | Deskripsi               | Contoh                    |
| --------------------- | ----------------------- | ------------------------- |
| `MYSQL_ROOT_PASSWORD` | Password root MariaDB   | `openssl rand -base64 32` |
| `MYSQL_PASSWORD`      | Password user mediawiki | `openssl rand -base64 32` |

> Gunakan `openssl rand -base64 32` untuk menghasilkan password yang kuat dan unik. Jangan pernah menggunakan password default atau yang mudah ditebak.
{: .prompt-tip}

### Langkah 2: Memulai Layanan (Mode Instalasi)

Pada tahap ini, biarkan baris mount `LocalSettings.php` tetap dikomentari di `compose.yaml`. Ini memungkinkan MediaWiki berjalan dalam mode instalasi:

```bash
dipen up mediawiki
```

Perintah ini akan:
1. Membaca file `compose.yaml`
2. Membuat network `mediawiki_network`
3. Membuat volume `mediawiki_data` dan `mediawiki_db_data`
4. Memulai container MariaDB terlebih dahulu
5. Health check memastikan database siap
6. Memulai container MediaWiki

Apa yang terjadi di balik layar?

MediaWiki mendeteksi bahwa `LocalSettings.php` tidak ada, sehingga ia menampilkan halaman instalasi web alih-alih halaman utama wiki.

### Langkah 3: Verifikasi Deployment

Pantau log untuk memastikan semua komponen berjalan dengan baik:

```bash
dipen logs mediawiki
```

Atau periksa status container:

```bash
dipen ps mediawiki
```

Anda akan melihat output seperti:

```
CONTAINER ID  IMAGE                      COMMAND     CREATED         STATUS                   PORTS
abc123def456  docker.io/mediawiki:latest  apache2     2 minutes ago   Up 2 minutes (healthy)   127.0.0.1:8002->80/tcp
def456ghi789  mariadb:10.11               mariadbd    2 minutes ago   Up 2 minutes (healthy)
```

### Langkah 4: Akses Wizard Instalasi

Buka browser dan akses:

```
http://localhost:8002
```

Anda akan disambut dengan halaman setup awal MediaWiki. Ikuti wizard instalasi dengan mengisi informasi berikut:

| Field             | Nilai yang Diisi           | Keterangan                                   |
| ----------------- | -------------------------- | -------------------------------------------- |
| Database host     | `db`                       | Nama service MariaDB di compose file         |
| Database name     | `mediawiki`                | Nama database (tanpa tanda hubung)           |
| Database username | `mediawiki`                | User database                                |
| Database password | `CHANGE_ME_MYSQL_PASSWORD` | Harus sama dengan `MYSQL_PASSWORD` di `.env` |

> Nama database tidak boleh mengandung tanda hubung (`-`). Gunakan `mediawiki` atau `wiki_db`, bukan `my-wiki`.
{: .prompt-info}

Setelah mengisi semua field, klik "Continue" dan ikuti langkah-langkah selanjutnya hingga wizard selesai.

### Langkah 5: Unduh dan Simpan LocalSettings.php

Di akhir wizard, MediaWiki akan menawarkan file `LocalSettings.php` untuk diunduh. Unduh file tersebut dan simpan di direktori:

```
/path/to/digital-independence/wiki/LocalSettings.php
```

Mengapa harus diunduh manual? MediaWiki tidak menulis file konfigurasi ke filesystem host secara langsung karena alasan keamanan. File tersebut berisi kredensial database dan secret key, sehingga Anda harus secara eksplisit menempatkannya di lokasi yang benar.

Setelah diunduh, atur izin file:

```bash
chmod 600 /path/to/digital-independence/wiki/LocalSettings.php
```

### Langkah 6: Aktifkan Persistensi Konfigurasi

Edit file `compose.yaml` di direktori `wiki/` dan hapus tanda komentar pada baris mount `LocalSettings.php`:

```yaml
# Sebelum:
# - ./LocalSettings.php:/var/www/html/LocalSettings.php:ro

# Sesudah:
- ./LocalSettings.php:/var/www/html/LocalSettings.php:ro
```

Ini akan memount file konfigurasi ke dalam container, sehingga MediaWiki dapat membacanya setiap kali aplikasi dijalankan.

### Langkah 7: Restart Layanan

Setelah mount diaktifkan, restart layanan agar perubahan berlaku:

```bash
dipen fresh mediawiki
```

Perintah `dipen fresh` adalah singkatan dari Down → Up, yang akan:
1. Menghentikan container MediaWiki
2. Menghapus container (volume tetap aman)
3. Memulai ulang container dengan konfigurasi baru

Verifikasi bahwa layanan berjalan dengan baik:

```bash
dipen ps mediawiki
dipen logs mediawiki
```

Sekarang akses kembali `http://localhost:8002` — Anda akan melihat halaman utama wiki, bukan wizard instalasi.

## Konfigurasi Firewall dengan IPC: Keamanan Berlapis

Digital Independence menyertakan IPC (Iptables Port Controller) — alat manajemen firewall yang menerapkan kebijakan default-deny. Ini berarti semua koneksi masuk ditolak kecuali port yang secara eksplisit dibuka.

### Mengapa Default-Deny?

Pendekatan default-deny adalah prinsip keamanan fundamental: "apa yang tidak diizinkan, dilarang." Dengan hanya membuka port yang benar-benar diperlukan, Anda meminimalkan attack surface secara drastis.

### Setup Awal IPC

```bash
# Setup persistence (aturan tetap berlaku setelah reboot)
sudo ipc setup-persistence

# Inisialisasi firewall (default-deny)
sudo ipc init

# Buka port SSH (jika belum)
sudo ipc enable 22 both tcp

# Buka port MediaWiki (jika perlu akses eksternal)
sudo ipc enable 8002 both tcp
```

### Verifikasi Aturan Firewall

```bash
sudo ipc status
```

> Untuk layanan yang terikat ke `127.0.0.1` (localhost), Anda tidak perlu membuka port di firewall. Ini adalah konfigurasi default yang aman untuk layanan yang hanya diakses melalui reverse proxy atau Cloudflare Tunnel.
{: .prompmt-info}

## Kustomisasi MediaWiki: Menyesuaikan dengan Kebutuhan

Setelah instalasi selesai, Anda dapat menyesuaikan MediaWiki dengan mengedit `LocalSettings.php`. Berikut beberapa konfigurasi umum:

### 1. Mengubah Nama dan Logo Situs

```php
$wgSitename = "Wiki Pribadi Saya";
$wgLogo = "$wgScriptPath/images/logo.png";
```

Letakkan file logo di volume `mediawiki_data` (direktori `/var/www/html/images` di dalam container).

### 2. Mengatur Hak Akses

Secara default, siapa saja bisa membaca, tetapi hanya pengguna terdaftar yang bisa mengedit. Untuk membatasi akses baca:

```php
# Hanya pengguna terdaftar yang bisa membaca
$wgGroupPermissions['*']['read'] = false;
$wgGroupPermissions['user']['read'] = true;

# Hanya sysop yang bisa menghapus
$wgGroupPermissions['*']['delete'] = false;
$wgGroupPermissions['user']['delete'] = false;
$wgGroupPermissions['sysop']['delete'] = true;
```

### 3. Mengaktifkan Upload File

```php
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";
$wgFileExtensions = array_merge(
    $wgFileExtensions,
    ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'zip']
);
```

### 4. Menginstal Ekstensi

MediaWiki memiliki ribuan ekstensi. Untuk menginstalnya:

1. Unduh ekstensi dari [MediaWiki Extensions](https://www.mediawiki.org/wiki/Category:Extensions)
2. Ekstrak ke direktori `/var/www/html/extensions/` di dalam container
3. Tambahkan baris berikut ke `LocalSettings.php`:

```php
wfLoadExtension( 'NamaEkstensi' );
```

### 5. Mengaktifkan Caching

Untuk performa yang lebih baik, aktifkan caching:

```php
$wgMainCacheType = CACHE_ACCEL;
$wgMemCachedServers = [];
```

## Kesimpulan

MediaWiki adalah lebih dari sekadar perangkat lunak wiki — ini adalah fondasi untuk membangun basis pengetahuan yang Anda kendalikan sepenuhnya. Dengan self-hosting MediaWiki:

- Anda memiliki data — tidak ada pihak ketiga yang bisa menghapus atau membaca konten Anda
- Anda mengontrol akses — atur siapa yang bisa membaca, menulis, dan mengelola
- Anda membangun warisan — dokumentasi yang akan bertahan selama perangkat keras Anda berfungsi
- Anda belajar DevOps — kelola database, web server, dan container sendiri

Dalam ekosistem Digital Independence yang lebih luas, MediaWiki adalah tempat di mana pengetahuan terstruktur disimpan dan dibagikan. Dikombinasikan dengan Podman rootless, firewall IPC, backup terenkripsi Chantik, dan otomatisasi cron, Anda memiliki infrastruktur pengetahuan yang sepenuhnya mandiri, aman, dan dapat diandalkan.

Langkah selanjutnya:
1. Jelajahi layanan lain dalam ekosistem Digital Independence (`dipen list`)
2. Integrasikan MediaWiki dengan Authentik untuk SSO
3. Instal ekstensi yang Anda butuhkan
4. Setup backup rutin dengan Chantik
5. Pantau dengan Uptime Kuma

Pengetahuan adalah kekuatan — dan dengan MediaWiki self-hosted, kekuatan itu ada di tangan Anda.

## Referensi

| Sumber Daya                     | Tautan                                                                                                                                                 |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Repositori Digital Independence | [github.com/ricalnet/digital-independence](https://github.com/ricalnet/digital-independence)                                                           |
| Wiki Resmi                      | [Digital Independence Wiki](https://git.ricalnet.my.id/rical/digital-independence/wiki)                                                                |
| Dokumentasi IPC                 | [Iptables Port Controller](https://git.ricalnet.my.id/rical/digital-independence/wiki/Iptables-Port-Controller-%E2%80%94-Firewall)                     |
| Chantik Backup Tool             | [Encrypted Backup Protection](https://git.ricalnet.my.id/rical/digital-independence/wiki/Chantik+%E2%80%94+ChaCha20-Authenticated+Backup+Protection.-) |
| MediaWiki Official              | [mediawiki.org](https://www.mediawiki.org/)                                                                                                            |
| Podman Documentation            | [podman.io/docs](https://podman.io/docs)                                                                                                               |