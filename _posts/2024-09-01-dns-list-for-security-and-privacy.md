---
title: DNS List for Security & Privacy
description: Koleksi resolver DNS terenkripsi yang memblokir malware, pelacak, dan konten berbahaya. Lengkap dengan panduan konfigurasi untuk desktop dan Android.
categories: [Cybersecurity, Privacy]
tags: [privacy, dns]
author: rical
last_modified_at: 2026-06-01
---

## Pengantar

DNS (Domain Name System) sering menjadi titik lemah kebocoran privasi. ISP atau penyedia layanan dapat mencatat, memanipulasi, atau bahkan menjual data penelusuran Anda. Solusinya adalah dengan menggunakan DNS terenkripsi (DNS over HTTPS/TLS) dan memilih resolver yang berkomitmen pada privasi serta keamanan.

Dokumen ini menyajikan daftar layanan DNS yang dapat diandalkan, lengkap dengan parameter konfigurasi untuk berbagai platform. Selain itu, juga menyertakan opsi self-hosted menggunakan Pi-hole bagi Anda yang menginginkan kendali penuh atas infrastruktur DNS di jaringan lokal.

## 1. LibreDNS — Privasi Tanpa Kompromi

> **Situs Resmi**: [https://libredns.gr/](https://libredns.gr/)  
> **Fitur unggulan**: Blokir iklan & pelacak secara default (noads), berbasis di Eropa dengan kebijakan privasi ketat.

| Endpoint                                                                 | Protokol       |
| :----------------------------------------------------------------------- | :------------- |
| `https://doh.libredns.gr/dns-query` <br> `https://doh.libredns.gr/noads` | DNS over HTTPS |
| `dot.libredns.gr` <br> `noads.libredns.gr`                               | DNS over TLS   |

> **Catatan Konfigurasi**  
> - **DNS over HTTPS (DoH)** cocok untuk peramban (Firefox, Chrome) atau aplikasi yang mendukung DoH.  
> - **DNS over TLS (DoT)** ideal untuk diterapkan di sistem operasi (Windows, Linux, macOS) karena lebih ringan dan terintegrasi.  
{: .prompt-info}

## 2. Quad9 — Proteksi Ancaman Siber Global

> **Situs Resmi**: [https://quad9.net/](https://quad9.net/)  
> **Fitur unggulan**: Memanfaatkan intelijen ancaman dari lebih dari 19 vendor keamanan, memblokir domain berbahaya, malware, dan phishing.

### Quad9 — Desktop

| IPv4            | IPv6        |
| :-------------- | :---------- |
| 9.9.9.9         | 2620:fe::fe |
| 149.112.112.112 | 2620:fe::9  |

### Quad9 — Android  
Aktifkan **Private DNS** (atau DNS Pribadi) di pengaturan jaringan, lalu masukkan hostname:  
`dns.quad9.net`

## 3. Cloudflare 1.1.1.1 — Kecepatan & Privasi

> **Situs Resmi**: [https://developers.cloudflare.com/1.1.1.1/encryption/](https://developers.cloudflare.com/1.1.1.1/encryption/)  
> **Fitur unggulan**: Resolver tercepat dengan komitmen tidak mencatat log (audit tahunan oleh KPMG). Mendukung WARP untuk privasi tambahan.

### Cloudflare — Desktop

| IPv4    | IPv6                 |
| :------ | :------------------- |
| 1.1.1.1 | 2606:4700:4700::1111 |
| 1.0.0.1 | 2606:4700:4700::1001 |

### Cloudflare — Android  
Hostname untuk Private DNS:  
`security.cloudflare-dns.com` (versi dengan proteksi malware)

## 4. OpenDNS — Kontrol Keluarga & Filter Konten

> **Situs Resmi**: [https://www.opendns.com/](https://www.opendns.com/)  
> **Fitur unggulan**: Kustomisasi filter konten dewasa, phishing, dan botnet. Cocok untuk lingkungan keluarga atau pendidikan.

| IPv4           | IPv6            |
| :------------- | :-------------- |
| 208.67.222.222 | 2620:119:35::35 |
| 208.67.220.220 | 2620:119:53::53 |

> Untuk konfigurasi lanjutan (parental control), daftar akun di situs OpenDNS dan atur preferensi jaringan Anda.
{: .prompt-info}

## 5. AdGuard DNS — Blokir Iklan & Pelacak di Level Jaringan

> **Situs Resmi**: [https://adguard-dns.io/](https://adguard-dns.io/)  
> **Fitur unggulan**: Basis data filter iklan dan pelacak yang terus diperbarui, tanpa perlu memasang ekstensi di perangkat.

### AdGuard — Desktop

| IPv4         | IPv6              |
| :----------- | :---------------- |
| 94.140.14.14 | 2a10:50c0:8000::1 |
| 94.140.15.15 | 2a10:50c0:8001::1 |

### AdGuard — Android  
Hostname untuk Private DNS:  
`dns.adguard.com`

## 6. NextDNS — Kendali Penuh & Analitik Real-Time

> **Situs Resmi**: [https://nextdns.io/](https://nextdns.io/)  
> **Fitur unggulan**: Dashboard analitik, pilih sendiri blokir dari berbagai kategori, dukungan DoH/DoT/DoQ, dan enkripsi DNSCrypt.

### NextDNS — Desktop

| IPv4       | IPv6               |
| :--------- | :----------------- |
| 45.90.28.0 | 2a07:a8c0::e2:4ddc |
| 45.90.30.0 | 2a07:a8c1::e2:4ddc |

### NextDNS — Android  
Hostname untuk Private DNS: `e24ddc.dns.nextdns.io`  

> Ganti `e24ddc` dengan ID konfigurasi pribadi Anda setelah mendaftar
{: .prompt-tip}

## 7. Pi-hole — Solusi Self-Hosted untuk Kedaulatan DNS

> **Dokumentasi Resmi**: [https://pi-hole.net/](https://pi-hole.net/)  
> **Fitur unggulan**: Blokir iklan dan pelacak di seluruh jaringan tanpa perlu klien tambahan, dashboard analitik real-time, dan kemampuan memilih sendiri daftar blokir.

Pi-hole adalah DNS sinkhole yang berjalan di server lokal (Raspberry Pi, VPS, atau Docker). Dengan menjadi administrator DNS Anda sendiri, data penelusuran tidak pernah meninggalkan jaringan kecuali untuk resolusi yang sah. Keuntungan utama:

- **Privasi maksimal** — Semua kueri DNS diproses di dalam jaringan Anda.
- **Kontrol penuh** — Anda dapat menambahkan daftar blokir kustom, wildcard, dan aturan sendiri.
- **Efisiensi bandwidth** — Iklan dan pelacak diblokir sebelum diunduh.
- **Integrasi dengan enkripsi** — Pi-hole dapat dikonfigurasi menggunakan forwarder DoH/DoT seperti Cloudflared untuk mengenkripsi lalu lintas keluar.

### Implementasi dengan Docker

Untuk memudahkan deployment dan manajemen, Pi-hole dapat dijalankan dalam kontainer Docker. Berikut adalah dua panduan praktis dari penulis:

- **[Instalasi dan Konfigurasi Pi-Hole untuk Blokir Iklan di Seluruh Jaringan](https://docs.ricalnet.my.id/posts/instalasi-dan-konfigurasi-pi-hole-untuk-blokir-iklan-di-seluruh-jaringan/)**  
- **[Integrasi Cloudflared DoH dengan Pi-hole di Docker](https://docs.ricalnet.my.id/posts/integrasi-cloudflared-doh-dengan-pi-hole-di-docker/)**

Setelah Pi-hole aktif, cukup atur setiap perangkat atau router Anda untuk menggunakan IP Pi-hole sebagai DNS server. Semua kueri akan melewati filter Anda, dan dunia luar hanya melihat lalu lintas DoH terenkripsi ke Cloudflare (jika dikonfigurasi).

> Pi-hole bukan layanan publik; ia berjalan di jaringan lokal Anda. Pastikan untuk tidak mengekspos port-nya ke internet tanpa otentikasi yang kuat. Gunakan VPN jika perlu mengakses dari luar rumah.
{: .prompt-info}

## Strategi Implementasi

| Platform        | Metode Utama                 | Catatan                                                                   |
| --------------- | ---------------------------- | ------------------------------------------------------------------------- |
| **Windows**     | Pengaturan jaringan → DNS    | Gunakan IPv4/IPv6 statis, atau konfigurasi DoH via registry               |
| **Linux**       | systemd-resolved atau stubby | Konfigurasi DoT/DoH dengan file `/etc/systemd/resolved.conf`{: .filepath} |
| **macOS**       | Preferensi Sistem → Jaringan | Set DNS server manual untuk antarmuka aktif                               |
| **Android**     | Private DNS (DoT)            | Paling mudah, gunakan hostname dari penyedia                              |
| **Router**      | DHCP / DNS forwarder         | Seluruh perangkat di rumah otomatis menggunakan DNS terpilih              |
| **Browser**     | Pengaturan keamanan → DoH    | Firefox, Chrome, Edge mendukung DoH native                                |
| **Self-hosted** | Pi-hole + Cloudflared        | Solusi privat maksimal, kendali penuh atas filtering                      |

> Selalu gunakan DNS dengan enkripsi (DoH/DoT) saat tersedia, terutama di jaringan publik. Untuk privasi maksimal, kombinasikan dengan VPN atau jalankan Pi-hole di jaringan lokal Anda.
{: .prompt-tip}

## Referensi Lanjutan

- [Instalasi dan Konfigurasi Pi-Hole untuk Blokir Iklan di Seluruh Jaringan](https://docs.ricalnet.my.id/posts/instalasi-dan-konfigurasi-pi-hole-untuk-blokir-iklan-di-seluruh-jaringan/)  
- [Integrasi Cloudflared DoH dengan Pi-hole di Docker](https://docs.ricalnet.my.id/posts/integrasi-cloudflared-doh-dengan-pi-hole-di-docker/)