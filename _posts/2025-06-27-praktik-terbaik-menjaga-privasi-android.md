---
title: Praktik Terbaik Menjaga Privasi di Android
description: Implementasi kontrol keamanan dan privasi pada platform Android, mencakup manajemen izin granular, strategi isolasi data, hardening jaringan, enkripsi, dan teknik minimasi telemetri sistem.
categories: [Cybersecurity, Privacy]
tags: [android, privacy]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Android sebagai sistem operasi mobile berbasis AOSP (Android Open Source Project) mengimplementasikan arsitektur keamanan berlapis yang mencakup fitur seperti sandbox aplikasi, enkripsi disk, dan model izin runtime. Namun, kompleksitas ekosistem yang melibatkan OEM, operator, dan pengembang aplikasi pihak ketiga menciptakan tantangan privasi multidimensi. Dokumen ini mendokumentasikan praktik teknis untuk mitigasi risiko privasi pada perangkat Android (versi 10/Q ke atas).

### 1. Manajemen Izin Granular
- **Kontrol Akurasi Lokasi** (Android 12+):  
  Batasi aplikasi ke akses lokasi perkiraan melalui izin `ACCESS_COARSE_LOCATION` sebagai alternatif `ACCESS_FINE_LOCATION`.
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/izin-lokasi.jpg)
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/permission-control.jpg)

- **Photo Picker Terisolasi** (Android 11+):  
  Gunakan intent sistem untuk membatasi akses penyimpanan hanya pada file yang dipilih pengguna.
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/permission.jpg)

- **Pencabutan Izin Sistem via ADB**:  
  ```bash
  adb shell pm revoke <package_name> <permission>
  ```
  > Pencabutan izin sistem tertentu dapat mengganggu fungsi aplikasi.
  {: .prompt-info}

### 2. Kontrol Telemetri dan Layanan
- **Deaktivasi Google Advertising ID**:  
  Pengaturan → Google → Iklan → Nonaktifkan Akses ke ID Iklan
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/personalization.png)

- **Manajemen Riwayat Aktivitas**:  
  - Nonaktifkan pelacakan aktivitas web dan aplikasi
  - Konfigurasi penghapusan data otomatis
  - Matikan koleksi data diagnostik
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/history-settings.png)

### 3. Isolasi Data dengan Profil
- **Profil Kerja**:  
  Implementasi kontainer terpisah dengan kebijakan keamanan independen menggunakan MDM atau aplikasi khusus.

- **Profil Pengguna Ganda**:  
  Partisi data terpisah melalui Pengaturan → Sistem → Beberapa Pengguna
  ![](/assets/img/posts/2025-06-27-praktik-terbaik-menjaga-privasi-android/users.jpg)

### 4. Hardening Jaringan
- **DNS Terenkripsi**:  
  [Implementasi DoH/DoT](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/) melalui Pengaturan → Jaringan & Internet → DNS Pribadi

- **Firewall Aplikasi**:  
  Gunakan solusi berbasis VPN untuk kontrol koneksi per-aplikasi

### 5. Enkripsi dan Autentikasi
- **Enkripsi Berbasis File**:  
  Status dapat diverifikasi di Pengaturan → Keamanan → Enkripsi & Kredensial

- **Autentikasi FIDO2**:  
  Implementasi kunci keamanan hardware melalui Pengaturan → Keamanan → Kunci Keamanan

### 6. Minimasi Telemetri Sistem
- **Konfigurasi Opsi Pengembang**:  
  Nonaktifkan:
  - Laporan Kesalahan Aplikasi
  - Statistik Layanan Seluler
  - Otentikasi Wi-Fi yang Ditingkatkan

### 7. Pemeliharaan Keamanan
- **Project Mainline Updates**:  
  Verifikasi melalui Pengaturan → Keamanan → Pembaruan Keamanan Google Play

- **Custom ROM (Opsional)**:  
  Pertimbangan implementasi ROM khusus untuk kebutuhan keamanan spesifik

## Pertimbangan Implementasi
1. **Kompatibilitas Aplikasi**: Pembatasan izin dapat memengaruhi fungsi aplikasi tertentu
2. **Dependensi Layanan**: Beberapa fitur memerlukan integrasi dengan layanan Google
3. **Kinerja Sistem**: Implementasi kontrol tambahan dapat memengaruhi konsumsi resource

## Pranala Luar
- [Android permissions](https://source.android.com/docs/core/permissions)
- [How do I find my GAID (Google Advertising ID)? (Google Play devices only)](https://support.spryfox.com/hc/en-us/articles/360005168034-How-do-I-find-my-GAID-Google-Advertising-ID-Google-Play-devices-only)
- [Privacy International](https://privacyinternational.org/)
- [Surveillance Self-Defense: Android](https://ssd.eff.org/)