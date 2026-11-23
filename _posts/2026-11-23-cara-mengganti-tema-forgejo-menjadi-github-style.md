---
title: Cara Mengganti Tema Forgejo Menjadi GitHub Style
description: Panduan teknis langkah demi langkah menginstal dan mengaktifkan tema GitHub pada Forgejo. Meliputi konfigurasi app.ini, ekstraksi aset CSS, dan restart layanan.
categories: [Digital Independence]
tags: [forgejo]
author: rical
last_modified_at: 2026-11-23
---

## Pendahuluan

Forgejo merupakan fork dari Gitea yang berfokus pada kemandirian perangkat lunak (software freedom), skalabilitas, dan fitur kolaborasi yang kaya. Meskipun tema bawaan Forgejo sudah fungsional, banyak organisasi atau pengembang yang menginginkan antarmuka yang lebih familier untuk mengurangi kurva pembelajaran pengguna baru. 

Dokumentasi ini menjelaskan prosedur teknis untuk mengganti tema default Forgejo menjadi tema yang meniru estetika dan tata letak GitHub menggunakan paket `forgejo-github-theme`. Panduan ini tidak hanya menyajikan urutan perintah (how), tetapi juga rasional teknis di balik setiap langkah (why), memastikan administrator sistem memahami dampak dari setiap modifikasi yang dilakukan pada instans.

## Prasyarat

Sebelum memulai, pastikan hal berikut telah terpenuhi:
1. Instans Forgejo telah terinstal dan berjalan dengan stabil.
2. Instalasi berasal dari repositori resmi [digital-independence](https://git.ricalnet.my.id/Privoss/digital-independence) untuk menjamin kompatibilitas struktur direktori.
3. Anda memiliki akses shell ke server dengan hak istimewa yang cukup untuk memodifikasi direktori data Forgejo.

## Langkah-langkah Implementasi

### 1. Navigasi dan Unduh Paket Tema

Aset kustom Forgejo harus ditempatkan di dalam direktori `custom` agar tidak tertimpa saat pembaruan versi perangkat lunak inti.

```bash
cd ~/.local/share/containers/storage/volumes/forgejo_data/_data/custom
wget https://github.com/whereareiam/forgejo-github-theme/releases/download/<version>/theme-github-accessibility.tar.gz
wget https://github.com/whereareiam/forgejo-github-theme/releases/download/<version>/theme-github-base.tar.gz
wget https://github.com/whereareiam/forgejo-github-theme/releases/download/<version>/theme-github-extras.tar.gz
wget https://github.com/whereareiam/forgejo-github-theme/releases/download/<version>/theme-github-templates.tar.gz
```

Rasional Teknis:
- Direktori `custom` adalah lokasi yang ditentukan oleh arsitektur Forgejo/Gitea untuk menimpa (override) aset dan templat bawaan.
- Pengunduhan dipisahkan menjadi empat modul (`accessibility`, `base`, `extras`, `templates`) untuk memisahkan tanggung jawab: CSS dasar, peningkatan aksesibilitas, fitur tambahan, dan templat HTML yang disesuaikan.
- Ganti `<version>` dengan tag rilis terbaru yang valid dari repositori sumber.

### 2. Ekstraksi dan Penempatan Berkas

Setelah diunduh, arsip harus diekstraksi dan dipindahkan ke lokasi yang sesuai agar dapat disajikan oleh server web internal Forgejo.

```bash
# Ekstraksi dan pindahkan CSS dasar
tar -xvf theme-github-base.tar.gz
mv *.css public/assets/css/

# Ekstraksi dan pindahkan CSS aksesibilitas
tar -xvf theme-github-accessibility.tar.gz
mv *.css public/assets/css/

# Ekstraksi templat HTML kustom
tar -xvf theme-github-templates.tar.gz
```

Rasional Teknis:
- Perintah `tar -xvf` mengekstrak konten arsip dengan output verbose untuk verifikasi visual.
- Berkas `.css` dipindahkan secara eksplisit ke `public/assets/css/` karena ini adalah jalur statis yang dilayani langsung oleh router aset Forgejo. Menempatkannya di sini memastikan browser dapat memuat stylesheet tanpa hambatan rute.
- `theme-github-templates.tar.gz` diekstraksi langsung ke direktori `custom` saat ini, karena berisi struktur direktori templat (misalnya, `templates/`) yang perlu mencerminkan hierarki templat internal Forgejo untuk di-override dengan benar.

### 3. Pembersihan Berkas Sementara

Hapus arsip sumber yang tidak lagi diperlukan setelah ekstraksi berhasil.

```bash
rm -r *.gz
```

Mengurangi jejak penyimpanan dan menjaga kebersihan direktori `custom`. Berkas `.gz` tidak dibutuhkan oleh runtime Forgejo setelah konten di dalamnya diekstraksi, sehingga menghapusnya mencegah kebingungan administratif di masa depan.

### 4. Konfigurasi Aplikasi (`app.ini`)

Forgejo perlu diinstruksikan secara eksplisit untuk mengenali dan mengaktifkan tema baru tersebut melalui berkas konfigurasi utamanya.

```bash
nano conf/app.ini
```

Tambahkan atau modifikasi bagian `[ui]` sebagai berikut:

```ini
[ui]
THEMES = gitea-auto, gitea-light, gitea-dark, github-auto, github-light, github-dark, github-soft-dark
DEFAULT_THEME = github-dark
```

Rasional Teknis:
- Variabel `THEMES` mendaftarkan semua tema yang diizinkan untuk dipilih oleh pengguna di antarmuka pengaturan akun. Menyertakan tema bawaan (`gitea-*`) bersama tema baru (`github-*`) memberikan fleksibilitas fallback.
- Variabel `DEFAULT_THEME` menetapkan tema yang akan dimuat secara otomatis untuk semua pengunjung yang belum autentikasi atau belum memiliki preferensi tema yang disimpan. `github-dark` dipilih sebagai default untuk mengurangi kelelahan mata dan konsistensi dengan preferensi pengembang modern.

### 5. Restart Layanan Forgejo

Modifikasi pada `app.ini` dan penambahan aset statis baru memerlukan muat ulang (reload) atau restart pada proses Forgejo agar perubahan diterapkan ke dalam memori.

```bash
dipen fresh forgejo
```

Forgejo memuat konfigurasi `app.ini` dan mendaftar rute aset statis hanya saat inisialisasi (boot). Tanpa restart, server akan terus menyajikan templat dan konfigurasi lama yang di-cache dalam memori proses, mengabaikan perubahan yang baru saja dibuat di sistem berkas.

## Verifikasi

1. Buka instans Forgejo melalui peramban web.
2. Bersihkan cache peramban (hard reload: `Ctrl + F5` atau `Cmd + Shift + R`) untuk memastikan aset CSS baru diunduh, bukan diambil dari cache lokal.
3. Periksa antarmuka: tata letak, warna, dan tipografi harus kini mencerminkan estetika GitHub Dark Mode.
4. Navigasi ke Settings > Appearance untuk memverifikasi bahwa semua tema `github-*` tersedia dalam dropdown pilihan tema.

## Penutup

Dokumentasi ini memberikan pendekatan yang terstruktur dan dapat diulang (repeatable) untuk kustomisasi antarmuka Forgejo. Dengan memisahkan aset kustom ke dalam direktori `custom` dan mengonfigurasi `app.ini` secara eksplisit, integritas pembaruan versi Forgejo di masa depan tetap terjaga, sementara kebutuhan spesifik UX organisasi terpenuhi.