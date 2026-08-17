---
title: Cara Melakukan Google Dorking | Panduan Teknis untuk OSINT & Penilaian Kerentanan
description: Pelajari sintaks pencarian spesifik untuk menemukan file konfigurasi, panel login, data sensitif, dan celah keamanan. Dilengkapi contoh kueri dan langkah mitigasi untuk melindungi aset digital Anda.
categories: [Cybersecurity]
tags: [information gathering, attacking]
author: rical
last_modified_at: 2026-08-17
---

> Dokumen ini dibuat untuk kepentingan edukasi dan pengujian keamanan yang sah. Setiap penggunaan di luar kerangka hukum dan etika merupakan tanggung jawab pribadi. Selalu dapatkan otorisasi tertulis sebelum melakukan pengujian terhadap sistem pihak ketiga.
{: .prompt-warning}

## 1. Latar Belakang Teknis

Google Dorking adalah teknik eksploitasi terhadap indeksasi mesin pencari. Setiap halaman yang di-crawl oleh Googlebot akan diparsing dan disimpan dalam indeks terstruktur. Operator pencarian memungkinkan kita mengakses metadata dan konten spesifik dari indeks ini—tanpa harus mengakses server target secara langsung.

Dorking adalah bagian dari fase reconnaissance pasif dalam siklus penetrasi testing. Informasi yang terkumpul bisa digunakan untuk:

- Memetakan attack surface organisasi.
- Mengidentifikasi sensitive data exposure.
- Menemukan endpoint tersembunyi atau file konfigurasi yang tidak seharusnya publik.
- Memvalidasi efektivitas kebijakan `robots.txt` dan *access control*.

## 2. Ruang Lingkup dan Tujuan Penggunaan

Dokumen ini mencakup:

- Operator dasar dan lanjutan Google Search beserta perilaku teknisnya.
- Kombinasi operator untuk membentuk*query presisi tinggi.
- Studi kasus dorking untuk skenario umum di lingkungan enterprise Indonesia.
- Interpretasi hasil dan korelasi dengan kerentanan (CWE, OWASP).
- Rekomendasi mitigasi berdasarkan defense-in-depth.

## 3. Operator Dasar dan Perilaku Teknis

Google search engine menggunakan inverted index. Setiap operator mempengaruhi query parsing dan result ranking secara berbeda.

### 3.1. Operator Fundamental

| Operator      | Fungsi                  | Implementasi Teknis                                                        | Contoh                   |
| ------------- | ----------------------- | -------------------------------------------------------------------------- | ------------------------ |
| `" "` (kutip) | Pencarian frasa eksak   | Memaksa token adjacency dan urutan tetap. Tidak ada stemming atau sinonim. | `"db_password = "`       |
| `OR` / `\|`   | Logika OR               | Menggabungkan dua set hasil. Prioritas lebih rendah dari AND.              | `"secret" OR "rahasia"`  |
| `AND`         | Logika AND (default)    | Semua term harus ada. Diimplisitkan oleh spasi.                            | `admin AND config`       |
| `-`           | Eksklusi                | Menghilangkan hasil yang mengandung term.                                  | `-github -stackoverflow` |
| `*`           | Wildcard (single token) | Menggantikan satu kata dalam frasa. Berguna untuk pattern yang bervariasi. | `"API_KEY = *"`          |

> Google tidak mendukung wildcard untuk sebagian kata (partial matching) karena menggunakan tokenisasi berbasis kata penuh.
{: .prompt-info}

### 3.2. Operator Lanjutan (Digunakan dalam Dorking)

| Operator    | Target           | Fungsi                                                                             | Contoh Aplikasi              |
| ----------- | ---------------- | ---------------------------------------------------------------------------------- | ---------------------------- |
| `site:`     | Domain/subdomain | Membatasi crawl index ke domain tertentu. Mendukung wildcard `*.domain.com`.       | `site:*.go.id`               |
| `filetype:` | Ekstensi file    | Memfilter hasil berdasarkan MIME type atau ekstensi. Dikenal juga dengan `ext:`.   | `filetype:env`               |
| `inurl:`    | String dalam URL | Mencocokkan substring di path, query parameter, atau fragment.                     | `inurl:phpinfo.php`          |
| `intitle:`  | Tag `<title>`    | Hanya mencocokkan konten dalam judul halaman.                                      | `intitle:"Index of /backup"` |
| `intext:`   | Body HTML        | Mencari string di seluruh konten halaman (termasuk teks alternatif gambar).        | `intext:"mysql_connect"`     |
| `cache:`    | Cache Google     | Menampilkan versi terakhir yang diindeks. Berguna untuk konten yang sudah dihapus. | `cache:target.com`           |

## 4. Membangun Query Presisi

Dorking yang efektif tidak hanya menggunakan satu operator, tetapi menggabungkannya untuk meminimalkan false positive dan memaksimalkan signal-to-noise ratio.

### 4.1. Logika Kombinasi

Google menerapkan operator precedence secara implisit:

1. `""` (frasa eksak) dievaluasi terlebih dahulu.
2. `OR` dievaluasi setelah token biasa.
3. Operator filter (`site:`, `inurl:`, dll.) bersifat mandatory dan tidak terpengaruh oleh urutan.

Contoh logika:
```
inurl:config site:.id filetype:php "database" -"example"
```
Artinya:  
`(inurl:config) AND (site:.id) AND (filetype:php) AND ("database") AND NOT ("example")`

### 4.2. Teknik Kombinasi untuk Berbagai Skenario

#### a. Menemukan `.env` atau File Konfigurasi
```
filetype:env "DB_HOST" OR "APP_ENV" -github -gitlab
```
- Mengapa: File `.env` sering menyimpan kredensial dan kunci API.  
- Risiko: Eksposur ini termasuk dalam CWE-312 (Cleartext Storage of Sensitive Information).

#### b. Mendeteksi Direktori Terbuka (Directory Listing)
```
intitle:"Index of /" "Parent Directory" -apache -nginx
```
- Mengapa: Direktori listing memungkinkan enumerasi file tanpa otentikasi.  
- Risiko: Menyebabkan informasi struktural terekspos—berguna untuk path traversal.

#### c. Panel Admin dengan Pola URL Umum
```
inurl:login OR inurl:admin OR inurl:dashboard site:target.co.id
```
- Mengapa: Identifikasi login portal untuk diuji kerentanannya (default credentials, IDOR, dll.).  
- Risiko: Jika tidak dilindungi WAF atau rate limiting, menjadi sasaran *brute force*.

#### d. Log Error yang Mengandung Stack Trace
```
intext:"Warning:" OR "Fatal error:" filetype:log
```
- Mengapa: Log error sering memuat path absolut, versi library, atau bahkan query SQL.  
- Risiko: Memberi informasi internal yang memudahkan reconnaissance lanjutan.

#### e. Backup Database (SQL Dump)
```
filetype:sql "INSERT INTO" "CREATE TABLE" site:go.id
```
- Mengapa: Dump database bisa berisi data PII, hash password, dan struktur skema.  
- Risiko: Termasuk OWASP Top 10: Sensitive Data Exposure.

#### f. Mencari Kamera CCTV atau IoT yang Ekspos
```
inurl:viewerframe?mode= OR intitle:"Live View" -youtube
```
- Mengapa: Banyak perangkat IoT menggunakan antarmuka default yang tidak diamankan.  
- Risiko: Pelanggaran privasi dan bisa dimanfaatkan untuk pengintaian fisik.

## 5. Skenario Penggunaan dalam Assessment Keamanan

Anda dapat menggunakan dorking dalam beberapa tahap:

### 5.1. Asset Discovery
- Identifikasi subdomain, path tersembunyi, atau endpoint yang tidak terdokumentasi.
- Contoh: `site:bank.co.id inurl:api -inurl:docs`

### 5.2. Vulnerability Triage
- Temukan indikasi kerentanan seperti:
  - `phpinfo()` terekspos → informasi lingkungan.
  - `.git/HEAD` terbaca → potensi source code leakage.
  - `/backup/` direktori → file lama yang tidak dipatch.

### 5.3. Post-Exploitation (dalam pengujian terkendali)
- Cari kredensial yang bocor di pastebin, GitHub, atau forum publik.
- Gunakan operator `site:pastebin.com` dengan kata kunci spesifik perusahaan.

### 5.4. Validasi Kebijakan Keamanan
- Periksa apakah `robots.txt` benar-benar dihormati? (Google tetap mengindeks jika ada tautan dari halaman lain).
- Uji apakah file `crossdomain.xml` atau `clientaccesspolicy.xml` membuka akses berlebihan.

## 6. Analisis Risiko dan Pemetaan Ke CWE/OWASP

| Temuan Umum                        | CWE              | OWASP                                                 | Dampak                                     |
| ---------------------------------- | ---------------- | ----------------------------------------------------- | ------------------------------------------ |
| File konfigurasi dengan kredensial | CWE-312, CWE-359 | A04:2021 - Insecure Design                            | Akses tidak sah ke database/API            |
| Directory listing                  | CWE-548          | A05:2021 - Security Misconfiguration                  | Enumerasi file & path discovery            |
| Error log terbuka                  | CWE-209          | A03:2021 - Injection (information leakage)            | Informasi teknis untuk penyusunan serangan |
| Backup SQL                         | CWE-359          | A02:2021 - Cryptographic Failures                     | Eksposur data pribadi                      |
| Panel admin tanpa proteksi         | CWE-284          | A07:2021 - Identification and Authentication Failures | Kemungkinan brute force & takeover         |

## 7. Strategi Mitigasi dan Hardening

Berikut adalah pendekatan teknis untuk melindungi aset dari eksposur melalui Google Dorking:

### 7.1. Kontrol Akses & Autentikasi
- Gunakan autentikasi berbasis token atau SSO untuk semua area administratif.
- Terapkan IP whitelisting untuk panel internal.
- Jangan mengandalkan security by obscurity (URL unik tanpa auth tetap rentan).

### 7.2. Manajemen Indeksasi
- Gunakan `robots.txt` untuk melarang crawler mengakses direktori sensitif:
  ```
  User-agent: *
  Disallow: /admin/
  Disallow: /config/
  Disallow: /*.env$
  Disallow: /*.sql$
  ```
- Gunakan meta tag `noindex` pada halaman yang tidak perlu diindeks.
- Manfaatkan Google Search Console untuk memantau dan menghapus URL yang terindeks secara tidak sengaja.

### 7.3. Keamanan Aplikasi
- Hindari menampilkan stack trace ke pengguna (gunakan `display_errors = Off` di production).
- Konfigurasi server untuk mencegah directory listing (misal: `Options -Indexes` di Apache).
- Gunakan Content Security Policy (CSP) untuk membatasi sumber daya.

### 7.4. Pemantauan Proaktif
- Lakukan dorking mandiri secara berkala dengan query khusus organisasi Anda.
- Pantau pastebin dan GitHub untuk kemungkinan kebocoran kredensial.
- Gunakan layanan Dark Web Monitoring jika diperlukan.

### 7.5. Respons Insiden
- Jika ditemukan informasi sensitif terindeks, segera:
  1. Hapus file dari server publik.
  2. Minta penghapusan cache via Google Search Console (URL Removal Tool).
  3. Rotasi semua kredensial yang mungkin terekspos.

## 8. Contoh Query

Berikut adalah kumpulan dork yang relevan:

```text
# 1. Mencari file .env di domain pemerintah
filetype:env "DB_PASSWORD" site:go.id -github

# 2. Mencari panel phpMyAdmin
inurl:phpmyadmin site:.id -"example"

# 3. Mencari file konfigurasi backup
filetype:bak OR filetype:old "config" site:co.id

# 4. Mencari log kesalahan dari aplikasi berbasis Laravel
intitle:"Whoops! There was an error." site:sch.id

# 5. Mencari direktori backup wordpress
inurl:/wp-content/backup-* site:or.id

# 6. Mencari API key yang terbuka
"api_key" filetype:txt site:ac.id

# 7. Mencari berkas spreadsheet yang berisi data karyawan
filetype:xlsx "NIK" OR "NIP" site:co.id

# 8. Mencari file git yang tidak sengaja terekspos
inurl:.git/config site:net.id
```

## 9. Kesimpulan dan Rekomendasi

Google Dorking adalah alat reconnaissance yang sangat kuat—baik untuk red team maupun blue team. Memahami dorking bukan hanya tentang bagaimana mencari, tetapi juga:

- Mengapa informasi tertentu bisa terindeks.
- Apa dampak dari eksposur tersebut.
- Bagaimana mencegahnya secara sistemik.

Gunakan dorking sebagai bagian dari continuous security assessment dan attack surface monitoring. Integrasikan temuan dari dorking ke dalam program vulnerability management Anda.

> Google hanya mengindeks apa yang diizinkan oleh server dan kebijakan akses. Jika data Anda terindeks, itu berarti data tersebut secara teknis publik. Oleh karena itu, pendekatan defense-in-depth yang meliputi autentikasi, enkripsi, dan kebijakan indeksasi adalah kunci utama.
{: .prompt-info}
