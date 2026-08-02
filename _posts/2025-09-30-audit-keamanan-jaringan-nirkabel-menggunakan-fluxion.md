---
title: Audit Keamanan Jaringan Nirkabel Menggunakan Fluxion
description: Panduan melakukan audit keamanan jaringan WiFi melalui teknik social engineering dengan Fluxion, mencakup instalasi, konfigurasi, dan implementasi metode penangkapan handshake serta serangan Evil-Twin dalam konteks pengujian penetrasi yang sah.
categories: [Cybersecurity]
tags: [attacking, fluxion]
author: rical
last_modified_at: 2026-06-01
---

## Gambaran Umum
Fluxion adalah alat penelitian social engineering dan audit keamanan nirkabel yang dirancang untuk mengevaluasi postur keamanan jaringan nirkabel. Dikembangkan sebagai penerus yang ditingkatkan dari proyek [linset](https://github.com/vk496/linset) yang telah dihentikan oleh vk496, Fluxion memperluas fungsionalitas pendahulunya dengan mengimplementasikan teknik canggih untuk menangkap kunci WPA/WPA2 melalui serangan social engineering yang ditargetkan. Alat ini kompatibel secara native dengan lingkungan Kali Linux.

> Pengguna harus mematuhi semua hukum yang berlaku dan mendapatkan otorisasi eksplisit sebelum menguji jaringan yang tidak mereka miliki. Penggunaan alat ini tanpa otorisasi dapat mengakibatkan konsekuensi hukum yang serius dan merusak kredibilitas profesional di bidang keamanan siber. Fluxion harus digunakan secara bertanggung jawab dan etis semata-mata untuk tujuan peningkatan keamanan, bukan untuk mengeksploitasi kerentanan.
{: .prompt-danger}

## Prosedur Instalasi
Proses instalasi Fluxion pada Kali Linux melibatkan langkah-langkah berikut:

1. Clone repositori Fluxion dari GitHub:
```bash
git clone https://github.com/FluxionNetwork/fluxion
```

2. Masuk ke direktori Fluxion:
```bash
cd fluxion
```

3. Jalankan skrip instalasi dengan flag `-i` untuk menginstal dependensi:
```bash
sudo ./fluxion.sh -i
```

Untuk eksekusi selanjutnya, jalankan:
```bash
sudo ./fluxion.sh
```

## Konfigurasi
Setelah instalasi dependensi, aplikasi akan secara otomatis diinisialisasi dan meminta pemilihan bahasa. Pengguna kemudian harus memilih antarmuka nirkabel untuk assessment.

> Antarmuka nirkabel yang dipilih harus mendukung packet injection dan monitor mode. Jika chipset nirkabel bawaan sistem tidak memiliki kemampuan ini, pertimbangkan untuk menggunakan adapter eksternal yang kompatibel seperti [TP-Link Archer T2U Plus](https://ricaldocs.github.io/posts/memperbaiki-masalah-driver-adaptor-wifi-usb-archer-t2u-v3-pada-kali-linux/).
{: .prompt-info}

![Pemilihan Antarmuka Nirkabel](assets/img/posts/2025-03-11-fluxion/select-wireless-interface.png)

## Alur Operasional

### Penemuan Jaringan
Inisiasi pemindaian jaringan nirkabel untuk mengidentifikasi access point yang tersedia:

![Pemilihan Saluran](assets/img/posts/2025-03-11-fluxion/channel.png)

Pengguna dapat mengonfigurasi parameter pemindaian untuk menargetkan sinyal dual-band atau saluran tertentu. Fluxion akan mendeteksi jaringan nirkabel di sekitarnya dan menampilkan informasi relevan termasuk kekuatan sinyal dan jenis enkripsi.

![Antarmuka Pemindai Fluxion](assets/img/posts/2025-03-11-fluxion/fluxion-scanner.png)

Hentikan proses pemindaian menggunakan `Ctrl + C` untuk melihat daftar jaringan yang ditemukan, lengkap dengan SSID, metrik sinyal, dan detail enkripsi.

![Daftar Jaringan Nirkabel](assets/img/posts/2025-03-11-fluxion/wifi-list.png)

### Pemilihan Target dan Penangkapan Handshake
Pilih antarmuka nirkabel yang sesuai untuk pelacakan target. Opsi 3 dapat dipilih untuk melewati langkah ini jika tidak yakin.

![Konfigurasi Pelacakan Target](assets/img/posts/2025-03-11-fluxion/target-tracking.png)

Pilih metodologi penangkapan handshake:

> Utilitas MDK4 memungkinkan serangan de-authentication dengan mengirimkan paket de-auth ke perangkat yang terhubung, memaksa pemutusan koneksi dari jaringan. Ini memfasilitasi penangkapan kredensial otentikasi selama upaya koneksi ulang.
{: .prompt-info}

![Metode Pengambilan Handshake](assets/img/posts/2025-03-11-fluxion/handshake-retrieval.png)

Pilih antarmuka pemantauan untuk operasi jamming. Adapter Archer T2U Plus (diidentifikasi sebagai `wlan0` dalam contoh ini) direkomendasikan untuk kinerja optimal.

![Pemilihan Antarmuka Jamming](assets/img/posts/2025-03-11-fluxion/interface-for-jamming.png)

### Verifikasi Handshake
Fluxion menyediakan beberapa metode verifikasi hash:

> Disarankan untuk menggunakan metode verifikasi default Fluxion untuk efektivitas optimal dan jaminan keamanan.
{: .prompt-tip}

> Cowpatty beroperasi dengan membandingkan hash jaringan yang ditangkap dengan hash yang dihasilkan dari entri wordlist. Kecocokan yang berhasil menunjukkan kata sandi yang berhasil dikompromikan, menjadikannya berharga untuk evaluasi kekuatan kata sandi nirkabel selama penetration testing.
{: .prompt-info}

![Pemilihan Metode Verifikasi](assets/img/posts/2025-03-11-fluxion/verification-method.png)

Setelah konfigurasi selesai, Fluxion memulai de-authentication semua perangkat yang terhubung ke jaringan target. Alat kemudian menangkap handshake WPA/WPA2 selama upaya koneksi ulang klien.

![Proses Penangkapan Handshake](assets/img/posts/2025-03-11-fluxion/handshake-capturing.png)

Meskipun serangan serupa dapat dilakukan menggunakan [aircrack-ng](https://www.aircrack-ng.org/), Fluxion menyediakan pendekatan yang lebih canggih dan ramah pengguna.

![Antarmuka Handshake Snooper](assets/img/posts/2025-03-11-fluxion/handshake-snooper.png)

## Vektor Serangan Lanjutan

### Metodologi Serangan Evil-Twin
Fluxion mengimplementasikan serangan Evil-Twin dengan terus mengirimkan paket de-authentication untuk memutuskan klien dari access point yang sah. Secara bersamaan, ia membuat access point palsu dengan konfigurasi SSID yang identik. Klien yang tidak mencurigai mungkin terhubung ke twin yang jahat, sehingga membuka kredensial mereka kepada penyerang.

Teknik ini merupakan varian phishing yang canggih di mana pengguna tertipu untuk memberikan informasi sensitif kepada jaringan yang tidak sah. Serangan Evil-Twin berfungsi sebagai mekanisme penetration testing yang efektif untuk mengidentifikasi kerentanan jaringan nirkabel.