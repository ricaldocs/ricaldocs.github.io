---
title: Cara Install Discourse dengan Docker untuk Pengembangan Lokal
description: Panduan instalasi Discourse untuk pengembangan lokal menggunakan Docker. Ikuti langkah-langkahnya untuk menjalankan server Rails dan Ember CLI dari repositori GitHub.
categories: [Digital Independence, Social Networks]
tags: [self-hosted, docker, discourse]
author: rical
last_modified_at: 2026-03-14
---

## Pengantar
Discourse adalah sebuah platform forum internet open source yang dirancang untuk diskusi komunitas yang berkelanjutan. Dibangun dengan menggunakan bahasa pemrograman Ruby on Rails dan Ember.js, Discourse menekankan pada kegunaan, desain yang responsif, dan integrasi yang mulus dengan berbagai layanan web modern. Perangkat lunak ini dikembangkan dengan fokus pada pengalaman pengguna yang intuitif dan modern, serta sering digunakan untuk mendukung komunitas daring, situs dukungan pelanggan, dan platform diskusi internal.

## Sejarah
Discourse pertama kali diumumkan pada tahun 2013 oleh Jeff Atwood, Robin Ward, dan Sam Saffron. Tujuan utama pengembangannya adalah untuk menciptakan alternatif modern untuk platform forum tradisional yang dianggap sudah ketinggalan zaman. Sejak diluncurkan, Discourse telah mendapatkan popularitas yang signifikan berkat pendekatan sumber terbukanya dan komitmen terhadap inovasi berkelanjutan.

## Pengembangan Lokal
Pengembangan lokal Discourse memungkinkan pengembang untuk menguji dan memodifikasi perangkat lunak di lingkungan mereka sendiri.

### Prasyarat
- **Sistem Operasi**: Dapat dijalankan pada Windows (menggunakan WSL), Linux, atau macOS.
- **Docker**: Diperlukan untuk mengelola kontainer dan dependensi.

### Langkah-Langkah Instalasi

1. Pastikan Docker telah terinstal pada sistem. Silakan merujuk ke [panduan instalasi Docker](https://docs.docker.com/engine/install/).

2. Unduh kode sumber Discourse dari repositori GitHub:
   ```bash
   git clone https://github.com/discourse/discourse.git && cd discourse
   ```

3. Jalankan perintah berikut untuk menginisialisasi instance Discourse dan membuat akun administrator:
   ```bash
   d/boot_dev --init
   ```
   Perintah ini akan memandu pengguna melalui proses pembuatan akun administrator.

4. Menjalankan Server
   - Mulai server Rails dengan perintah:
     ```bash
     d/rails s
     ```
   - Di terminal terpisah, jalankan Ember CLI:
     ```bash
     d/ember-cli
     ```
   - Tunggu hingga proses build selesai dan server berjalan pada `http://localhost:4200`.

5. Buka browser dan akses `http://localhost:4200` untuk menggunakan Discourse secara lokal. Pastikan kedua terminal tetap aktif selama pengembangan.

## Penggunaan dan Aplikasi

Discourse digunakan oleh berbagai organisasi dan komunitas untuk:
- Forum diskusi publik dan privat.
- Platform dukungan pelanggan.
- Pusat bantuan dan dokumentasi.
- Komunitas sumber terbuka dan proyek kolaboratif.

## Pranala Luar
- [Situs Resmi Discourse](https://discourse.org/)
- [Setup Discourse for Local Development](https://nspeaks.com/setup-discourse-for-local-development/#install-docker)
