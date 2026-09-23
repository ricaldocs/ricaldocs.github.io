---
title: Enabling and Disabling Monitor Mode in Kali Linux
description: Menjelaskan prosedur konfigurasi untuk mengaktifkan dan menonaktifkan mode monitor pada antarmuka Wireless LAN (WLAN) dalam lingkungan Kali Linux.
categories: Cybersecurity
tags: [linux, information gathering, adaptor wifi]
author: rical
last_modified_at: 2026-06-01
---

## Aktivasi Mode Monitor

### Prosedur Konfigurasi
1. **Akses Terminal**  
   Buka antarmuka terminal pada sistem Kali Linux.

2. **Identifikasi Antarmuka Jaringan**  
   Verifikasi nama antarmuka WLAN menggunakan perintah:
   ```bash
   iwconfig
   ```
   Catat nama antarmuka target (contoh: wlan1).

3. **Nonaktifkan Antarmuka**  
   Matikan antarmuka target sebelum konfigurasi:
   ```bash
   sudo ip link set wlan1 down
   ```

4. **Konfigurasi Mode Monitor**  
   Terapkan mode monitor pada antarmuka:
   ```bash
   sudo iw dev wlan1 set type monitor
   ```

5. **Aktifkan Kembali Antarmuka**  
   Hidupkan kembali antarmuka setelah konfigurasi:
   ```bash
   sudo ip link set wlan1 up
   ```

6. **Verifikasi Konfigurasi**  
   Konfirmasi status mode monitor dengan perintah:
   ```bash
   iwconfig
   ```
   Output harus menampilkan `Mode:Monitor` untuk antarmuka wlan1.

> Penggunaan mode monitor untuk penangkapan paket jaringan harus dilakukan hanya pada lingkungan yang diizinkan. Aktivitas monitoring tanpa otorisasi dapat melanggar ketentuan hukum yang berlaku.
{: .prompt-warning}

## Deaktivasi Mode Monitor

### Prosedur Konfigurasi
1. **Nonaktifkan Antarmuka**  
   Matikan antarmuka yang beroperasi dalam mode monitor:
   ```bash
   sudo ip link set wlan1 down
   ```

2. **Kembalikan ke Mode Managed**  
   Setel ulang antarmuka ke mode standar:
   ```bash
   sudo iw dev wlan1 set type managed
   ```

3. **Aktifkan Kembali Antarmuka**  
   Hidupkan kembali antarmuka dengan konfigurasi baru:
   ```bash
   sudo ip link set wlan1 up
   ```

4. **Verifikasi Konfigurasi**  
   Pastikan antarmuka telah kembali ke mode normal:
   ```bash
   iwconfig
   ```
   Output harus menampilkan `Mode:Managed` untuk antarmuka wlan1.
