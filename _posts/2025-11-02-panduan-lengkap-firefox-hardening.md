---
title: Panduan Lengkap Firefox Hardening
description: Panduan teknis lengkap hardening Firefox untuk meningkatkan privasi dan keamanan browsing. Pelajari konfigurasi native Settings, DNS over HTTPS, hingga implementasi ekstensi essential uBlock Origin dan Firefox Containers.
categories: [Cybersecurity, Privacy]
tags: [privacy, firefox hardening]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Dokumen ini menyajikan metodologi untuk mengonfigurasi Mozilla Firefox guna meningkatkan postur keamanan dan privasi pengguna. Panduan ini mencakup konfigurasi sistem native, implementasi DNS over HTTPS, serta integrasi ekstensi esensial yang terbukti efektif dalam membatasi pelacakan digital dan mengurangi vektor serangan.

## 1. Pendahuluan

### 1.1 Latar Belakang

Browser web berfungsi sebagai portal utama interaksi online, menjadikannya target utama bagi pelacakan iklan, pengumpulan data, dan potensi eksploitasi keamanan. Firefox, sebagai browser open-source yang dikembangkan di bawah Mozilla Foundation, menawarkan granular control yang signifikan atas pengaturan privasi dan keamanan, menjadikannya platform ideal untuk implementasi strategi hardening.

### 1.2 Tujuan dan Ruang Lingkup

Panduan teknis ini bertujuan untuk menyediakan instruksi terperinci yang dapat ditindaklanjuti untuk:
- Mengoptimalkan konfigurasi privasi native Firefox
- Menerapkan mekanisme keamanan berlapis
- Mengintegrasikan ekstensi yang meningkatkan proteksi tanpa mengorbankan usability
- Menetapkan best practices untuk browsing yang aman

### 1.3 Prinsip Desain Keamanan

Pendekatan hardening ini mengikuti beberapa prinsip inti:
- Membatasi akses hanya pada fungsi yang diperlukan
- Menerapkan multiple layer of protection
- Mempertahankan fungsionalitas inti sambil meningkatkan keamanan

## 2. Konfigurasi General Settings

### 2.1 Optimalisasi Preferensi Dasar

Pada tab `General`, sesuaikan konfigurasi berikut untuk meminimalkan telemetri dan gangguan yang tidak diperlukan:

```plaintext
Path: Settings → General
```

**Rekomendasi Konfigurasi:**
- **Recommend extensions as you browse**: Nonaktifkan
- **Recommend features as you browse**: Nonaktifkan

![General Settings Tab](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-22-47.png)

![General Settings Browsing](<../assets/img/posts/2025-11-02-firefox-hardening/Screenshot From 2025-11-02 19-23-33.png>)

> Pengaturan ini mencegah Firefox mengirimkan data penggunaan ke server Mozilla untuk analisis rekomendasi, mengurangi jejak digital dan koneksi eksternal yang tidak diperlukan.
{: .prompt-info}

## 3. Konfigurasi Homepage

### 3.1 Minimalisasi Elemen Antarmuka

Simplifikasi antarmuka beranda dengan menonaktifkan komponen yang berpotensi mengkomunikasikan data pengguna:

```plaintext
Path: Settings → Home
```

**Rekomendasi Konfigurasi:**
- **Web Search**: Nonaktifkan
- **Shortcuts**: Nonaktifkan  
- **Recent Activity**: Nonaktifkan

![Homepage Configuration](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-23-46.png)

> Pengurangan elemen dinamis pada homepage menurunkan kompleksitas attack surface dan membatasi kemampuan third-party untuk memantau pola browsing.
{: .prompt-info}

## 4. Optimalisasi Mesin Pencari

### 4.1 Seleksi Search Engine Berbasis Privasi

Ganti mesin pencari default dengan penyedia yang menerapkan praktik privasi yang ketat:

```plaintext
Path: Settings → Search
```

**Rekomendasi Provider:**
- **DuckDuckGo**: Tidak melacak pencarian atau memprofil pengguna
- **Startpage**: Menyediakan hasil Google dengan lapisan privasi
- **Searx** (self-hosted): Solusi open-source yang terdesentralisasi

**Konfigurasi Tambahan:**
- **Show search suggestions**: Nonaktifkan
- **Show recent searches**: Nonaktifkan

![Search Engine Selection](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-24-02.png)

> Menonaktifkan suggestions mencegah pengiriman partial query ke server pencarian, sementara menonaktifkan recent searches dari address bar mengurangi risiko eksfiltrasi data historis.
{: .prompt-info}

## 5. Konfigurasi Privasi & Keamanan Komprehensif

### 5.1 Enhanced Tracking Protection

Implementasi mekanisme pemblokiran pelacak native Firefox:

```plaintext
Path: Settings → Privacy & Security
```

**Level Proteksi Rekomendasi:**
- **Strict**: Memblokir semua tracker yang terdeteksi (mungkin mempengaruhi kompatibilitas situs)
- **Standard**: Memblokir tracker sosial media, cross-site cookies, fingerprinters (balance optimal)

![Tracking Protection Settings](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-24-39.png)

> Sistem ETP Firefox menggunakan daftar pemblokiran yang dikurasi untuk mengidentifikasi dan memblokir script pelacakan, cryptocurrency miners, dan fingerprinters.
{: .prompt-info}

### 5.2 Manajemen Cookies dan Site Data

Konfigurasi kebijakan cookies yang ketat dengan pengecualian terkontrol:

```plaintext
Path: Settings → Privacy & Security
```

**Konfigurasi Utama:**
- **Tell websites not to sell or share my data**: Aktifkan (mengimplementasikan DNT signal)
- **Delete cookies and site data when Firefox is closed**: Aktifkan
- **Manage Exceptions**: Konfigurasi untuk domain tepercaya (banking, services essential)

![Privacy Preferences](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-24-55.png)

> Pendekatan ini menerapkan model "whitelist-based persistence" di mana hanya situs yang secara eksplisit diizinkan yang dapat menyimpan data persisten.
{: .prompt-info}

### 5.3 Manajemen Password Terintegrasi

Implementasi kebijakan penyimpanan kredensial yang aman:

```plaintext
Path: Settings → Privacy & Security
```

**Rekomendasi Konfigurasi:**
- **Ask to save logins and passwords for websites**: Nonaktifkan
- **Show alerts about passwords for breached websites**: Aktifkan

> Meskipun penyimpanan password native dinonaktifkan, fitur breach monitoring tetap dipertahankan untuk memberikan alert proaktif terhadap kebocoran data.
{: .prompt-tip}

![Password Settings](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-24-59.png)

### 5.4 Kebijakan Pembersihan Data Historis

Implementasi automatic data purging untuk mencegah akumulasi jejak digital:

```plaintext
Path: Settings → Privacy & Security
```

**Konfigurasi Custom:**
- **Always use private browsing mode**: Opsional (untuk kebutuhan keamanan tinggi)
- **Remember browsing and download history**: Nonaktifkan
- **Clear history when Firefox closes**: Aktifkan

![History Configuration](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-25-13.png)

> Firefox akan secara otomatis menghapus cache, cookies, dan data sesi saat proses browser dihentikan, menerapkan prinsip "data minimization by default".
{: .prompt-info}

### 5.5 Manajemen Izin Sistem yang Restriktif

Pembatasan akses resource sistem untuk mencegah eksploitasi:

```plaintext
Path: Settings → Privacy & Security
```

**Konfigurasi Izin:**
- **Location**: Blocked
- **Camera**: Blocked  
- **Microphone**: Blocked
- **Notifications**: Blocked
- **Autoplay**: Block audio and video

**Proteksi Tambahan:**
- **Block pop-up windows**: Aktifkan
- **Warn you when websites try to install add-ons**: Aktifkan

![Permissions Settings](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-25-26.png)

> Pembatasan izin hardware mencegah eksploitasi melalui drive-by attacks yang mencoba mengakses kamera atau mikrofon tanpa persetujuan.
{: .prompt-info}

### 5.6 Konfigurasi Data Collection dan Telemetri

Minimalkan pengiriman data analitik ke server Mozilla:

```plaintext
Path: Settings → Privacy & Security
```

> Semua opsi dalam bagian ini dinonaktifkan
{: .prompt-tip}

> Meskipun data telemetri membantu pengembangan Firefox, untuk pengguna yang memprioritaskan privasi, menonaktifkan fitur ini menghilangkan potensi kebocoran data penggunaan.
{: .prompt-info}

![Data Collection Settings](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-25-37.png)

### 5.7 Pembatasan Profil Iklan

Nonaktifkan mekanisme yang memungkinkan pembuatan profil iklan berbasis perilaku:

```plaintext
Path: Settings → Privacy & Security
```

**Konfigurasi:**
- **Allow websites to ask to use your advertising preferences**: Nonaktifkan

> Pengaturan ini membatasi kemampuan advertiser untuk membangun profil pengguna berdasarkan minat dan perilaku browsing.
{: .prompt-info}

![Advertising Settings](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-25-44.png)

### 5.8 Implementasi DNS over HTTPS (DoH)

Enkripsi kueri DNS untuk mencegah eavesdropping dan manipulasi:

```plaintext
Path: Settings → Privacy & Security
```

**Konfigurasi Rekomendasi:**
- **Enable DNS over HTTPS**: Aktifkan
- **Provider**: [LibreDNS](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/#1-libredns-rekomendasi) atau [Quad9](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/#2-quad9)

**Penyedia DNS yang Direkomendasikan:**
- [LibreDNS](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/#1-libredns-rekomendasi): Tidak melakukan logging, memblokir domain malicious
- [Quad9](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/#2-quad9): Memiliki reputasi kuat dalam keamanan, memblokir malware/phishing

![DoH Configuration](../assets/img/posts/2025-11-02-firefox-hardening/Screenshot%20From%202025-11-02%2019-26-08.png)

> DoH mengenkripsi seluruh kueri DNS, mencegah ISP dan pihak ketiga memantau atau memanipulasi traffic DNS.
{: .prompt-info}

## 6. Ekstensi Keamanan Esensial

### 6.1 uBlock Origin untuk Advanced Content Filtering

uBlock Origin adalah ekstensi pemblokir konten yang ringan dan efisien, memberikan kontrol granular atas elemen halaman web.

```plaintext
Path: Extensions & Themes → Find more add-ons → Search "uBlock Origin"
```

> uBlock Origin tidak hanya memblokir iklan tetapi juga mencegah loading tracker dan script berbahaya, secara signifikan mengurangi attack surface.
{: .prompt-info}

### 6.2 Firefox Multi-Account Containers untuk Isolation Contextual

Container menyediakan lingkungan terisolasi dengan session, cookies, dan storage terpisah, mencegah cross-site tracking.

```plaintext
Path: Extensions & Themes → Find more add-ons → Search "Firefox Multi-Account Containers"
```

**Strategi Segmentasi Rekomendasi:**
- **Banking Container**: Untuk akses layanan finansial
- **Social Media Container**: Mengisolasi tracker platform sosial
- **Work Container**: Memisahkan aktivitas profesional
- **Shopping Container**: Mengandung tracker e-commerce
- **Temporary Containers**: Untuk situs one-time visit
    
    ![Firefox Multi-Account Containers](<../assets/img/posts/2025-11-02-firefox-hardening/Screenshot From 2025-11-02 20-33-59.png>)

**Konfigurasi Otomasi:**
- Atur situs tertentu untuk selalu membuka di container dedicated
- Gunakan ekstensi "Temporary Containers" untuk isolasi otomatis situs baru

> Pendekatan containerization membatasi dampak kebocoran data dan mencegah teknik cross-site tracking yang canggih.
{: .prompt-info}

Tentu, berikut adalah pembaruan untuk bagian 6.3 dengan gaya dokumentasi teknis profesional yang selaras dengan keseluruhan artikel Anda.

---

### 6.3 Implementasi Encrypted Client Hello (ECH)

Encrypted Client Hello (ECH) adalah evolusi dari Encrypted Server Name Indication (ESNI) yang mengenkripsi seluruh handshake TLS, termasuk Server Name Indication (SNI). Hal ini mencegah pihak ketiga, seperti ISP atau penyedia jaringan, memantau domain spesifik yang diakses, menutup celah privasi signifikan meskipun koneksi sudah menggunakan TLS dan DoH.

```plaintext
Path: about:config
```

Untuk mengaktifkan dan mengonfigurasi ECH, ubah preferensi berikut melalui antarmuka `about:config`. Mekanisme ini bergantung sepenuhnya pada DNS-over-HTTPS (DoH) yang telah dikonfigurasi di langkah 5.8.

**Konfigurasi Preferensi:**

| Preferensi                                                 | Nilai        | Status      | Deskripsi Fungsional                                                                                                                                                                                                                                   |
| :--------------------------------------------------------- | :----------- | :---------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `network.dns.echconfig.enabled`                            | `true`       | Default     | Mengaktifkan dukungan dasar untuk ECH.                                                                                                                                                                                                                 |
| `network.dns.echconfig.fallback_to_origin_when_all_failed` | `true`       | Default     | Mengizinkan koneksi fallback tanpa ECH jika negosiasi gagal, mencegah kerusakan akses situs.                                                                                                                                                           |
| `network.dns.use_https_rr_as_altsvc`                       | `true`       | Diperlukan  | Mengizinkan Firefox menggunakan catatan sumber daya HTTPS (HTTPS RR) dari DNS, yang krusial untuk proses negosiasi ECH.                                                                                                                                |
| `network.trr.mode`                                         | `3` atau `5` | Disesuaikan | Menentukan mode resolver TRR (Trusted Recursive Resolver). Atur ke `3` untuk memprioritaskan DoH tetapi fallback ke DNS sistem jika gagal. Atur ke `5` untuk menonaktifkan resolver DoH secara eksplisit jika menggunakan proxy lokal (mis., Pi-hole). |

> Jika Anda menggunakan Pi-hole atau resolver DNS lokal serupa, atur `network.trr.mode` ke `5` untuk menonaktifkan DoH di Firefox. Hal ini mencegah Firefox mem-bypass resolver lokal Anda dan tetap memungkinkannya menerima konfigurasi ECH dari catatan DNS lokal jika disediakan, meskipun implementasi ini jarang. Tanpa koneksi DoH yang berfungsi, ECH tidak akan beroperasi. Evaluasi konfigurasi ini secara seksama terhadap model ancaman Anda.
{: .prompt-tip}

Setelah menerapkan konfigurasi, lakukan verifikasi fungsionalitas ECH melalui endpoint pengujian berikut:

1.  **Uji Sinyal Cloudflare:**
    Buka URL: [https://crypto.cloudflare.com/cdn-cgi/trace](https://crypto.cloudflare.com/cdn-cgi/trace)
    Verifikasi bahwa output teks menampilkan `sni=encrypted`. Jika menampilkan `sni=plaintext`, berarti ECH tidak berfungsi.

2.  **Uji Komprehensif oleh TCD (Trinity College Dublin):**
    Buka URL: [https://defo.ie](https://defo.ie)
    Situs ini menyediakan analisis mendalam tentang status ECH dan komponen pendukungnya, membantu mendiagnosis potensi kesalahan konfigurasi.

> Implementasi ECH adalah lapisan pertahanan privasi yang krusial, memastikan bahwa pengawasan pasif pada jalur jaringan tidak dapat mengungkap domain situs yang dikunjungi. Ini secara efektif melengkapi DoH untuk mengenkripsi metadata penjelajahan web sepenuhnya.
{: .prompt-info}

## 7. Kesimpulan dan Best Practices

### 7.1 Ringkasan Implementasi

Konfigurasi hardening yang dijelaskan dalam dokumen ini memberikan postur keamanan melalui pendekatan berlapis:

1. Memanfaatkan fitur keamanan built-in Firefox
2. Mengenkripsi traffic melalui DoH
3. Memblokir elemen berbahaya dengan uBlock Origin
4. Memisahkan aktivitas melalui Containers

### 7.2 Rekomendasi Pemeliharaan

- Pastikan Firefox dan semua ekstensi selalu updated
- Evaluasi konfigurasi secara berkala berdasarkan kebutuhan
- Verifikasi fungsionalitas situs web critical setelah perubahan
- Simpan profil Firefox untuk recovery cepat

### 7.3 Pertimbangan Kinerja dan Kompatibilitas

Implementasi hardening ini dirancang untuk meminimalkan dampak pada:
- Konfigurasi dipilih untuk menjaga responsivitas browser
- Fungsionalitas inti browsing dipertahankan
- Mayoritas situs web tetap berfungsi normal

Dokumen ini menyediakan baseline security configuration yang dapat disesuaikan lebih lanjut berdasarkan requirement spesifik organisasi atau individu. Pendekatan bertahap direkomendasikan untuk memastikan stabilitas dan kompatibilitas selama proses implementasi.