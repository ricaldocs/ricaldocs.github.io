---
title: Solusi Build Native GlobaLeaks di ARM64 Tanpa Emulasi QEMU
description: Mengatasi keterbatasan image resmi GlobaLeaks yang hanya tersedia untuk x86_64 dengan membangun image native ARM64 menggunakan Podman. Dibahas pula konfigurasi Tor onion service, setup wizard, dan integrasi domain publik untuk Raspberry Pi 5, AWS Graviton, serta server berbasis Apple Silicon.
categories: [The Onion Router]
tags: [onion, tor, privacy, globaleaks]
author: rical
last_modified_at: 2026-09-23
---

## Apa itu GlobaLeaks?

GlobaLeaks adalah platform open-source untuk whistleblowing yang dirancang untuk memungkinkan pelaporan anonim yang aman. Dikembangkan oleh Hermes Center for Transparency and Digital Human Rights, GlobaLeaks menyediakan infrastruktur yang memungkinkan organisasi — mulai dari media investigatif, lembaga antikorupsi, hingga korporasi — untuk menerima laporan sensitif tanpa mengungkap identitas pelapor.

Secara arsitektural, GlobaLeaks mengombinasikan beberapa teknologi keamanan:

- Tor Hidden Service sebagai lapisan anonimitas jaringan
- End-to-end encryption untuk perlindungan data pelapor
- Application-level encryption dengan keyring terpisah
- Secure deletion untuk metadata yang sensitif

### Mengapa Arsitektur ARM64 Menjadi Relevan?

ARM64 (aarch64) telah bergeser dari sekadar arsitektur mobile menjadi tulang punggung infrastruktur modern. AWS Graviton, Ampere Altra, Apple Silicon, dan Raspberry Pi 5 semuanya menggunakan ARM64. Keuntungan utamanya:

1. Rasio performa per watt jauh lebih tinggi dibanding x86_64
2. Instance cloud ARM64 umumnya 20-40% lebih murah
3. Perangkat SBC seperti Raspberry Pi memungkinkan deployment di lokasi fisik yang terbatas

Namun, ekosistem container masih didominasi oleh image x86_64. Inilah akar masalah yang mendorong diperlukannya build kustom.

### Konsep Multi-Architecture Build

Container image modern mengikuti spesifikasi OCI (Open Container Initiative) yang mendukung manifest list — sebuah indeks yang memetakan arsitektur (linux/amd64, linux/arm64, linux/arm/v7) ke image spesifik. Ketika Anda menjalankan `podman pull globaleaks/globaleaks:latest`, container runtime akan memilih image yang sesuai dengan arsitektur host.

Masalahnya, jika upstream hanya menyediakan manifest untuk amd64, runtime di ARM64 tidak akan menemukan image yang cocok. Ada dua solusi:

1. Menggunakan QEMU binfmt_misc untuk menjalankan binary x86_64 di ARM64. Ini bekerja, tetapi menambahkan overhead 2-10x dan sering bermasalah pada operasi syscall tertentu (terutama yang berkaitan dengan network namespace dan Tor control protocol).
2. Mengompilasi ulang image dari source untuk ARM64. Hasilnya adalah image native yang berjalan tanpa overhead emulasi.

Panduan ini menggunakan pendekatan kedua.

### Podman vs Docker

Podman (Pod Manager) adalah container engine yang dikembangkan oleh Red Hat sebagai alternatif daemonless untuk Docker. Perbedaan fundamentalnya:

| Aspek | Docker | Podman |
|-------|--------|--------|
| Arsitektur | Client-server daemon | Daemonless, fork-exec model |
| Rootless | Opsional (perlu konfigurasi) | Default |
| Cgroup | cgroup v1/v2 (konflik umum) | Native cgroup v2 |
| Compose | docker-compose plugin | podman-compose / quadlet |
| Attack surface | Daemon privileged | Setiap container isolated |

### Prinsip Kerja Tor Onion Service

GlobaLeaks bergantung pada Tor Hidden Service (kini disebut Onion Service) untuk anonimitas. Secara teori:

1. GlobaLeaks menjalankan Tor daemon internal dengan ControlPort aktif
2. Melalui ControlPort, GlobaLeaks memerintahkan Tor untuk membuat ephemeral onion service (versi 3, menggunakan Ed25519)
3. Tor menghasilkan onion address 56 karakter yang merupakan hash dari public key service
4. Private key disimpan di direktori `globaleaks-data` — inilah mengapa direktori ini kritis dan tidak boleh hilang

Onion Service v3 menggunakan rendezvous protocol di mana klien dan service bertemu di titik netral tanpa pernah mengetahui IP satu sama lain. Inilah yang membuat GlobaLeaks dapat dihosting bahkan di balik NAT tanpa port forwarding.

### Threat Model Singkat

Panduan ini mengasumsikan threat model berikut:

- Adversary: Pihak yang ingin mengidentifikasi pelapor atau menyadap komunikasi
- Aset: Identitas pelapor, isi laporan, metadata submission
- Mitigasi: Anonimitas jaringan (Tor), enkripsi at-rest (keyring), enkripsi in-transit (TLS), isolasi container (Podman rootless)

Yang tidak dicakup: serangan fisik terhadap server, kompromi host OS, atau serangan side-channel tingkat lanjut.

## Prasyarat

- Server ARM64 dengan Debian-based OS
- Akses root atau sudo
- Koneksi internet stabil (build memerlukan unduhan dependensi)
- Minimal 4 GB RAM dan 10 GB storage kosong

## Prosedur Instalasi

### Langkah 1: Clone Repositori

```bash
git clone https://git.ricalnet.my.id/rical/ricalnet-web.git ~/ricalnet-web
cd ~/ricalnet-web/globaleaks
```

Repositori ini menyediakan `Containerfile` yang telah dikonfigurasi untuk build ARM64. Direktori `globaleaks` berisi seluruh konteks build yang diperlukan.

### Langkah 2: Instal Podman

```bash
curl -fLO https://git.ricalnet.my.id/rical/digital-independence/raw/branch/main/install-podman-on-debian.sh
chmod +x install-podman-on-debian.sh
./install-podman-on-debian.sh
```

Script installer dari repositori digital-independence mengonfigurasi Podman beserta dependensi (crun, slirp4netns, fuse-overlayfs) yang dioptimalkan untuk ARM64. Flag `-fLO` memastikan curl mengikuti redirect, gagal pada HTTP error, dan menyimpan dengan nama file asli.

### Langkah 3: Build Image dan Jalankan Container

```bash
mkdir -p ./globaleaks-data

podman build -t localhost/globaleaks-arm64:latest -f Containerfile .
podman compose up -d
sleep 180
podman-compose logs -f
```

Penjelasan setiap perintah:

| Perintah | Fungsi |
|----------|--------|
| `mkdir -p ./globaleaks-data` | Membuat direktori persistensi data GlobaLeaks (database, konfigurasi, keyring Tor) |
| `podman build -t localhost/globaleaks-arm64:latest` | Build image native ARM64 dengan tag lokal |
| `podman compose up -d` | Menjalankan service dalam mode detached |
| `sleep 180` | Jeda inisialisasi — GlobaLeaks memerlukan waktu untuk bootstrap Tor dan generate onion service |
| `podman-compose logs -f` | Stream log real-time untuk verifikasi |

## Verifikasi Output

Tunggu hingga koneksi Tor dan alamat onion dihasilkan. Output yang diharapkan:

```
[globaleaks] | [stdout#info] GlobaLeaks is now running and accessible at the following urls:
[globaleaks] | [stdout#info] - [HTTPS]: https://0.0.0.0
[globaleaks] | [stdout#info] - [Tor]:  http://abcdefghijkl1234.onion
[globaleaks] | [stdout#info] [E] Successfully connected to Tor control port
[globaleaks] | [stdout#info] [E] [1] Setting up the onion service abcdefghijkl1234.onion
[globaleaks] | [stdout#info] [E] [1] Initialization of onion-service abcdefghijkl1234.onion completed.
```

Interpretasi log:

- `Successfully connected to Tor control port` — koneksi ke Tor daemon berhasil
- `Setting up the onion service` — pembuatan hidden service sedang berlangsung
- `Initialization ... completed` — onion service siap diakses

Mengapa ini penting? Alamat `.onion` bersifat persisten selama direktori `globaleaks-data` tidak dihapus. Kehilangan direktori ini berarti kehilangan identitas onion service.

## Akses Aplikasi

Dua jalur akses tersedia:

1. Via Tor Browser: akses `http://abcdefghijkl1234.onion` (ganti dengan alamat aktual dari log)
2. Via Setup Wizard lokal akses `https://localhost:4443`

> Akses `https://localhost:4443` menggunakan self-signed certificate. Browser akan menampilkan peringatan — terima untuk melanjutkan ke wizard.
{: .prompt-warning}

![alt text](<../assets/img/posts/2026-09-23-solusi-build-native-globaleaks-di-arm64-tanpa-emulasi-qemu/Screenshot From 2026-09-23 16-44-33.png>)

## Konfigurasi Awal (Setup Wizard)

### 1. Project Name

```
Project name: GLOBALEAKS
```

### 2. Akun Administrator

Buat kredensial admin. Gunakan password kuat (minimal 16 karakter, campuran huruf, angka, simbol). Akun ini memiliki kontrol penuh atas platform.

![alt text](<../assets/img/posts/2026-09-23-solusi-build-native-globaleaks-di-arm64-tanpa-emulasi-qemu/Screenshot From 2026-09-23 16-46-20.png>)

### 3. Akun Recipient (Opsional)

Recipient adalah penerima laporan whistleblowing. Dapat dikonfigurasi nanti melalui panel admin.

![alt text](<../assets/img/posts/2026-09-23-solusi-build-native-globaleaks-di-arm64-tanpa-emulasi-qemu/Screenshot From 2026-09-23 16-48-28.png>)

### 4. Persetujuan

Centang "I have read and agree" terhadap terms of service.

![alt text](<../assets/img/posts/2026-09-23-solusi-build-native-globaleaks-di-arm64-tanpa-emulasi-qemu/Screenshot From 2026-09-23 16-49-18.png>)

Klik Proceed.

Instalasi selesai. Platform siap menerima submission.

## Domain Publik (Opsional)

Jika Anda memiliki domain publik dan ingin mengakses GlobaLeaks melalui clearnet (bukan hanya Tor):

### Langkah 1: Login Admin

Akses wizard login melalui slug onion:

```
http://abcdefghijkl1234.onion/login
```

### Langkah 2: Konfigurasi Hostname

1. Navigasi ke Network → HTTPS
2. Masukkan domain yang diinginkan (contoh: `leaks.example.com`)
3. Pilih metode certificate:
   - Manual configuration: upload sertifikat X.509 dan private key Anda sendiri
   - Automatic configuration: GlobaLeaks akan request dan renew certificate
     ![alt text](<../assets/img/posts/2026-09-23-solusi-build-native-globaleaks-di-arm64-tanpa-emulasi-qemu/Screenshot From 2026-09-23 17-39-12.png>)

Let's Encrypt memerlukan port 80 dan 443 dapat diakses dari internet publik untuk validasi HTTP-01. Jika server berada di belakang NAT atau firewall ketat, gunakan manual certificate dengan validasi DNS-01.

## Troubleshooting Umum

| Gejala | Penyebab | Solusi |
|--------|---------|--------|
| Build gagal pada `crun` | Kernel terlalu lama | Update kernel ke 5.10+ |
| Onion address tidak muncul setelah 120 detik | Tor bootstrap lambat | Tunggu hingga 300 detik, cek log |
| `podman compose` command not found | Plugin belum terinstal | `apt install podman-compose` |
| Port 4443 tidak accessible | Firewall lokal | `ufw allow 4443/tcp` |

## Catatan Akhir

Pendekatan build native ARM64 ini menghilangkan overhead emulasi QEMU dan memastikan kompatibilitas penuh dengan Tor control protocol. Untuk production deployment, pertimbangkan:

- Backup rutin direktori `globaleaks-data`
- Monitoring log Tor untuk anomali koneksi
- Isolasi network namespace untuk defense-in-depth
- Update berkala terhadap base image untuk patch keamanan