---
title: Active Reconnaissance
description: Perintah untuk melakukan Active Reconnaissance.
categories: [Cybersecurity]
tags: [information gathering]
author: rical
last_modified_at: 2026-06-01
---

Active reconnaissance adalah metode pengumpulan informasi yang melibatkan interaksi langsung dengan sistem target. Proses ini bertujuan untuk mengidentifikasi dan menganalisis potensi kerentanan dalam infrastruktur jaringan dan aplikasi. Berikut adalah langkah-langkah dan perintah yang dapat digunakan dalam active reconnaissance:

#### 1. **Ping Sweep**
Ping sweep digunakan untuk menentukan apakah host tertentu aktif dalam jaringan. Perintah yang digunakan adalah:
```bash
ping -c 4 [alamat_IP_target]
```
Perintah ini mengirimkan empat paket ICMP Echo Request ke alamat IP yang ditentukan dan menunggu balasan.

#### 2. **Port Scanning**
Port scanning dilakukan untuk mengidentifikasi port yang terbuka pada target. Salah satu alat yang umum digunakan adalah `nmap`. Perintah untuk melakukan pemindaian port adalah:
```bash
nmap -sS -p 1-65535 [alamat_IP_target]
```
Perintah ini melakukan pemindaian SYN pada semua port dari 1 hingga 65535.

#### 3. **Service Version Detection**
Untuk mengetahui versi layanan yang berjalan pada port yang terbuka, perintah berikut dapat digunakan:
```bash
nmap -sV [alamat_IP_target]
```
Perintah ini akan mengidentifikasi layanan yang berjalan dan versinya.

#### 4. **Operating System Detection**
Untuk mendeteksi sistem operasi yang digunakan oleh target, perintah berikut dapat diterapkan:
```bash
nmap -O [alamat_IP_target]
```
Perintah ini menganalisis respons dari target untuk menentukan sistem operasi yang digunakan.

#### 5. **Traceroute**
Traceroute digunakan untuk melacak rute yang diambil paket menuju target. Perintah yang digunakan adalah:
```bash
traceroute [alamat_IP_target]
```
Perintah ini memberikan informasi tentang setiap hop yang dilalui paket dalam perjalanan ke alamat IP target.

#### 6. **DNS Enumeration**
Pengumpulan informasi DNS dapat dilakukan menggunakan alat seperti `dig` atau `nslookup`. Contoh perintah menggunakan `dig` adalah:
```bash
dig [domain_target] ANY
```
Perintah ini meminta semua catatan DNS yang tersedia untuk domain yang ditentukan.

#### 7. **Web Application Scanning**
Untuk memindai aplikasi web, alat seperti `Nikto` dapat digunakan. Perintah yang digunakan adalah:
```bash
nikto -h [alamat_IP_target]
```
Perintah ini melakukan pemindaian terhadap aplikasi web untuk mengidentifikasi potensi kerentanan.

#### 8. **SNMP Enumeration**
Jika Simple Network Management Protocol (SNMP) diaktifkan pada target, informasi dapat dikumpulkan menggunakan `snmpwalk`. Perintah yang digunakan adalah:
```bash
snmpwalk -v2c -c [community_string] [alamat_IP_target]
```
Perintah ini mengumpulkan informasi dari perangkat yang mendukung SNMP dengan menggunakan string komunitas yang ditentukan.

### Catatan Penting
Sebelum melakukan active reconnaissance, sangat penting untuk mendapatkan izin eksplisit dari pemilik sistem atau jaringan yang akan diuji. Tindakan ini dapat dianggap ilegal dan melanggar etika jika dilakukan tanpa izin. Selalu patuhi hukum dan regulasi yang berlaku dalam praktik keamanan siber.