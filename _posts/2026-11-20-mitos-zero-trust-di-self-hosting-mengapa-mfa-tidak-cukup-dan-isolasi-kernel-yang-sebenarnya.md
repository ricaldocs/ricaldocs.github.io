---
title: "Mitos Zero Trust di Self-Hosting: Mengapa MFA Tidak Cukup dan Isolasi Kernel yang Sebenarnya"
description: Mengapa MFA saja tidak cukup untuk Zero Trust? Pelajari isolasi kernel, rootless Podman, dan binding localhost untuk membatasi blast radius di infrastruktur self-hosted.
categories: [Cybersecurity, Privacy]
tags: [privacy, globaleaks]
author: rical
last_modified_at: 2026-11-21
pin: true
image:
  path: /assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/thumbnail.webp
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
---

> Perlu dicatat bahwa Zero Trust adalah ekosistem keamanan yang jauh lebih luas daripada yang dibahas di sini. Artikel ini berfokus pada aspek isolasi teknis dalam konteks self-hosting, bukan merupakan panduan lengkap untuk mengimplementasikan Zero Trust secara menyeluruh di organisasi besar.
{: .prompt-info}

Dalam ekosistem self-hosting, ada kesalahpahaman yang persisten: menempatkan Reverse Proxy (seperti Caddy atau Nginx) yang dilindungi oleh Multi-Factor Authentication (MFA) di depan sebuah layanan dianggap sudah cukup untuk mengklaim arsitektur tersebut sebagai "Zero Trust".

Ini adalah sebuah mitos. MFA hanyalah pengamanan pintu depan (front door). Zero Trust yang sesungguhnya berlandaskan pada satu asumsi arsitektural: pintu depan pada akhirnya akan ditembus, dan sistem harus dirancang untuk membatasi radius kerusakan (blast radius) ketika hal itu terjadi.

Artikel ini menguraikan mengapa MFA saja gagal melindungi infrastruktur modern, dan bagaimana menerapkan isolasi nyata di level kernel Linux dan runtime kontainer — berdasarkan arsitektur yang saya operasikan sehari-hari di Privoss.

## 1. Mengapa MFA Tidak Cukup?

MFA memvalidasi siapa yang masuk, tetapi tidak memvalidasi apa yang dilakukan kode aplikasi di dalam sistem setelah otentikasi berhasil.

Pertimbangkan skenario berikut: sebuah aplikasi web di dalam kontainer memiliki kerentanan Remote Code Execution (RCE) atau Server-Side Request Forgery (SSRF). Penyerang tidak perlu melewati MFA sama sekali. Mereka memanfaatkan celah pada aplikasi untuk mengeksekusi perintah langsung di dalam lingkungan kontainer.

![Gambar 1. Bypass MFA dan Lateral Movement pada Arsitektur Flat Network.](<../assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/Bypass-MFA-dan-Lateral-Movement-pada-Arsitektur-Flat-Network.webp>)
_Gambar 1. Bypass MFA dan Lateral Movement pada Arsitektur Flat Network._

Pada arsitektur jaringan tradisional yang datar (flat network), begitu penyerang berhasil masuk ke satu kontainer, mereka bebas melakukan lateral movement (pergerakan lateral):
- Memindai jaringan internal untuk menemukan database kontainer lain.
- Mengakses port administrasi yang tidak diproteksi.
- Mencoba container breakout untuk mendapatkan akses ke mesin host utama.

Pada titik ini, MFA menjadi sepenuhnya tidak relevan. Autentikasi yang kuat di pintu depan tidak berguna jika penyerang masuk melalui jendela yang terbuka.

## 2. Tiga Pilar Isolasi Nyata

Untuk mencapai Zero Trust yang sebenarnya, kita harus membatasi hak istimewa (privilege) dan pergerakan (movement) secara default. Berikut adalah tiga pilar implementasinya, beserta alasan teknis di balik masing-masing keputusan.

### A. Eksekusi Rootless (Tanpa Hak Root)

![Gambar 2. Perbandingan Isolasi User Namespace: Root vs. Rootless.](<../assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/Perbandingan-Isolasi-User-Namespace-Root-vs-Rootless.webp>)
_Gambar 2. Perbandingan Isolasi User Namespace: Root vs. Rootless._

- **Bagaimana:** Menjalankan kontainer menggunakan mesin tanpa daemon (seperti Podman) di bawah pengguna non-root (unprivileged user), bukan sebagai root atau dengan sudo.
- **Mengapa:** Dalam konfigurasi kontainer tradisional, proses di dalam sering berjalan sebagai root. Jika terjadi container breakout (misalnya melalui eksploitasi kernel), penyerang mendapatkan akses root penuh ke mesin host. Dengan rootless, user namespace di Linux memetakan UID 0 (root) di dalam kontainer menjadi UID pengguna biasa (misalnya 1000) di host. Kegagalan isolasi hanya akan memberikan hak akses yang sangat terbatas, bukan kendali penuh atas server.

### B. Binding Jaringan Ketat (127.0.0.1)

![Gambar 3. Eliminasi Attack Surface melalui Binding Localhost (127.0.0.1).](<../assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/Eliminasi-Attack-Surface-melalui-Binding-Localhost-127.0.0.1.webp>)
_Gambar 3. Eliminasi Attack Surface melalui Binding Localhost (127.0.0.1)._

- **Bagaimana:** Mengonfigurasi semua layanan internal (database, cache, aplikasi backend) untuk hanya mendengarkan (listen) pada antarmuka 127.0.0.1 (localhost), bukan 0.0.0.0 (semua antarmuka). Hanya Reverse Proxy yang diizinkan menangani trafik dari luar.
- **Mengapa:** Ini menghilangkan attack surface jaringan secara drastis. Meskipun penyerang berhasil mengeksploitasi satu kontainer, mereka tidak dapat secara langsung mengakses port database atau layanan administrasi dari jaringan eksternal, atau bahkan dari kontainer tetangga yang tidak berada dalam jaringan yang sama.

### C. Pembatasan Sumber Daya dan Capabilities

![Gambar 4. Tiga Lapis Pertahanan Runtime: Cgroups, Capabilities, dan Read-Only FS.](<../assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/Tiga-Lapis-Pertahanan-Runtime-Cgroups-Capabilities-dan-Read-Only-FS.webp>)
_Gambar 4. Tiga Lapis Pertahanan Runtime: Cgroups, Capabilities, dan Read-Only FS._

- **Bagaimana:** 
  1. Menetapkan batas memori dan CPU via cgroups.
  2. Menjatuhkan (drop) Linux capabilities yang tidak diperlukan, seperti `CAP_NET_RAW` (mencegah packet sniffing) dan `CAP_SYS_ADMIN` (mencegah mounting filesystem).
  3. Mengaktifkan Read-Only Root Filesystem untuk kontainer yang tidak memerlukan penulisan data secara lokal, dengan pengecualian direktori spesifik via tmpfs.
- **Mengapa:** Ini membatasi dampak jika kode berbahaya berhasil dieksekusi. Penyerang tidak dapat melakukan serangan Denial of Service (DoS) dengan menghabiskan seluruh RAM host, tidak dapat memasang sniffer pada antarmuka jaringan, dan tidak dapat memodifikasi biner sistem di dalam kontainer.

## 3. Visualisasi Arsitektur

Diagram berikut membandingkan arsitektur "Zero Trust Palsu" (hanya mengandalkan MFA) dengan "Zero Trust Nyata" (berbasis isolasi kernel dan jaringan).

![Gambar 5. Perbandingan Arsitektur: "Zero Trust Nyata" vs. "Zero Trust Palsu".](<../assets/img/posts/2026-11-20-mitos-zero-trust-di-self-hosting-mengapa-mfa-tidak-cukup-dan-isolasi-kernel-yang-sebenarnya/Perbandingan-Arsitektur-Zero-Trust-Nyata-vs-Zero-Trust-Palsu.webp>)
_Gambar 5. Perbandingan Arsitektur: "Zero Trust Nyata" vs. "Zero Trust Palsu"._

## 4. Implementasi Praktis: Konfigurasi Nyata

Teori tanpa implementasi hanyalah opini. Berikut adalah contoh konfigurasi nyata dari Privoss (Authentik dan Vaultwarden) yang menerapkan ketiga pilar di atas. Perhatikan bagaimana setiap layanan di-bind ke 127.0.0.1, menggunakan isolasi ketat, dan memiliki batasan sumber daya.

```yaml
# Contoh: Authentik Server (Identity Provider)
services:
  server:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik_server
    ports:
      # 1. BINDING JARINGAN KETAT: Hanya localhost yang bisa mengakses.
      # Reverse Proxy (Caddy) akan meneruskan trafik ke port ini.
      - "127.0.0.1:9500:9000"
      - "127.0.0.1:9443:9443"
    
    # 2. PEMBATASAN SUMBER DAYA: Mencegah DoS melalui resource exhaustion.
    mem_limit: 1g
    mem_reservation: 256m
    cpus: 1.0
    pids_limit: 500
    oom_score_adj: 0 # Prioritas OOM killer normal
    
    # 3. ISOLASI KERNEL & FILESYSTEM
    security_opt:
      - no-new-privileges=true # Mencegah eskalasi hak akses via setuid binaries
    cap_drop:
      - ALL # Jatuhkan SEMUA capabilities Linux secara default
    cap_add:
      - NET_BIND_SERVICE # Izinkan binding ke port < 1024 (jika diperlukan)
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - FOWNER
    read_only: true # Filesystem root tidak dapat ditulis
    tmpfs:
      # Direktori yang perlu ditulis di-mount sebagai tmpfs dengan flag keamanan ketat
      - /tmp:rw,noexec,nosuid,size=256M
      - /run:rw,noexec,nosuid,size=64M
      - /var/run:rw,noexec,nosuid,size=64M

networks:
  authentik:
    driver: bridge
    internal: true # 4. ISOLASI JARINGAN: Kontainer tidak bisa akses internet outbound
```

Poin Kunci dari Konfigurasi di Atas:
1. `127.0.0.1:PORT:PORT` memastikan layanan tidak terekspos ke jaringan publik, bahkan jika firewall host gagal.
2. `cap_drop: ALL` adalah garis pertahanan terakhir. Bahkan jika penyerang mendapatkan shell di dalam kontainer, mereka tidak dapat menjalankan alat seperti tcpdump (`CAP_NET_RAW`) atau memodifikasi kernel (`CAP_SYS_ADMIN`).
3. `read_only: true` dikombinasikan dengan `tmpfs` yang memiliki flag `noexec,nosuid` mencegah penyerang menulis dan mengeksekusi payload berbahaya di direktori sementara.
4. `internal: true` pada network memastikan kontainer tidak memiliki akses internet outbound, memutus rantai serangan command and control (C2).

## 5. Kesimpulan

Zero Trust bukan tentang membeli produk keamanan tertentu atau sekadar menambahkan lapisan autentikasi. Zero Trust adalah tentang desain arsitektur.

Ketika Anda membangun infrastruktur self-hosted, pertanyaannya bukan "Bagaimana cara mencegah orang masuk?", melainkan "Jika seseorang atau sesuatu berhasil masuk, seberapa sedikit kerusakan yang bisa mereka timbulkan?"

Dengan memaksakan batasan sumber daya, menjalankan layanan tanpa hak root, dan mengisolasi jaringan secara ketat ke localhost, Anda tidak lagi sekadar berharap sistem Anda aman. Anda membuktikan bahwa sistem Anda tangguh, bahkan saat berada di bawah tekanan.

> "Privacy and security are the architecture, not just a policy."