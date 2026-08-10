---
title: Instalasi dan Konfigurasi Pi-Hole dengan Docker untuk Blokir Iklan di Seluruh Jaringan
description: Panduan lengkap instalasi Pi-Hole menggunakan Docker di Debian. Pelajari cara mengatur DNS server lokal untuk memblokir iklan dan pelacak di seluruh perangkat jaringan rumah Anda.
categories: [Digital Independence, Communications]
tags: [self-hosted, docker, pi-hole, dns, privacy]
author: rical
last_modified_at: 2026-07-05
---

Pi-Hole adalah DNS server yang berfungsi sebagai penyaring konten (ad blocker) di tingkat jaringan. Dengan memasang Pi-Hole, Anda dapat memblokir iklan, pelacak, dan domain berbahaya untuk semua perangkat yang terhubung ke jaringan rumah atau kantor, tanpa perlu menginstal aplikasi tambahan di setiap perangkat.

Artikel ini akan memandu Anda menginstal Pi-Hole menggunakan Docker di server Debian. Pendekatan ini memudahkan pengelolaan, pembaruan, dan isolasi layanan. Kita juga akan mengonfigurasi router agar semua perangkat menggunakan Pi-Hole sebagai DNS utama.

> Dokumen ini adalah panduan konfigurasi dasar. Untuk konfigurasi keamanan dan privasi tingkat lanjut, lihat [panduan terpisah](https://ricaldocs.github.io/posts/integrasi-cloudflared-doh-dengan-pi-hole-di-docker/).
{: .prompt-info}

> **Referensi Penting:** [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

## Prasyarat

- Server atau komputer dengan Debian (trixie atau lebih baru) yang terhubung ke jaringan lokal.
- Hak akses `sudo` atau root.
- Router yang dapat diatur DNS-nya (hampir semua router rumahan mendukung).
- Alamat IP statis untuk server yang akan menjalankan Pi-Hole (disarankan). Dalam panduan ini kita menggunakan `192.168.0.50`.
  > Jika ingin mengatur IP statis untuk server, lihat dokumentasi [berikut](https://ricaldocs.github.io/posts/cara-mengatur-ip-statis-di-raspberry-pi-os-dengan-networkmanager/) untuk panduan konfigurasi network di Debian.
  {: .prompt-tip}

## 1. Instalasi Docker

Docker adalah prerequisite mutlak sebelum menjalankan Pi-Hole. Ricalnet menyediakan script instalasi otomatis yang telah teruji di berbagai distribusi Linux.

### Clone Repository dan Instalasi Otomatis

```bash
git clone https://github.com/ricalnet/digital-independence.git
cd digital-independence
```

### Instalasi Docker Engine

**Untuk Debian:**
```bash
./install-docker-engine-on-debian.sh
```

**Untuk Ubuntu:**
```bash
./install-docker-engine-on-ubuntu.sh
```

#### Apa yang Dilakukan Script Instalasi?
Script ini mengotomatiskan proses yang biasanya memakan waktu dan rawan kesalahan:
1. Update package repository sistem
2. Install dependencies (ca-certificates, curl, gnupg, lsb-release)
3. Tambahkan GPG key resmi Docker untuk verifikasi keamanan
4. Konfigurasi repository Docker agar menggunakan paket resmi
5. Install Docker Engine, CLI, dan Containerd
6. Tambahkan user saat ini ke group docker (menghindari penggunaan `sudo` setiap kali)

> Docker menyediakan isolasi lingkungan yang sempurna untuk SearXNG. Dengan kontainer, Anda mendapatkan:
- Berjalan identik di semua sistem
- Tidak ada konflik dengan aplikasi lain di server
- Cukup pull image baru dan restart kontainer untuk update
- Kembali ke versi sebelumnya dengan satu perintah
{: .prompt-info}

## 2. Masuk ke Direktori dan Environment

Masuk ke direktori `pi-hole` dan sesuaikan variabel `.env`.

```bash
cd pi-hole
cp .env.example .env
nano .env
```

### Membuat Password

Sebelum menjalankan container, buat password untuk admin panel:

```bash
openssl rand --hex 32
```

Salin output-nya, lalu tempelkan sebagai nilai `FTLCONF_webserver_api_password` di file `.env`. Contoh:

```yaml
FTLCONF_webserver_api_password=a1b2c3d4e5f67890abcdef1234567890
```

## 3. Menjalankan Pi-Hole

Download image dan jalankan container dengan perintah:

```bash
docker compose up -d
```

Flag `-d` (detach mode) menjalankan kontainer di background, memungkinkan terminal tetap digunakan.

Tunggu beberapa saat hingga container siap. Untuk melihat log:

```bash
docker compose logs -f
```

Tekan `Ctrl+C` untuk keluar dari log.

## 4. Mengakses Admin Panel Pi-Hole

Buka browser dan akses alamat IP server Pi-Home dengan port 8443 (HTTPS) atau 8080 (HTTP):

```
https://192.168.0.50:8443/admin
```

atau

```
http://192.168.0.50:8080/admin
```

Anda akan melihat halaman login Pi-Hole. Gunakan password yang telah dibuat sebelumnya.

![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/pi-hole-login.png)

> Jika menggunakan HTTPS, browser mungkin memperingatkan koneksi tidak aman karena menggunakan sertifikat self-signed. Anda bisa melanjutkan dengan mengklik "Advanced" dan "Proceed".
{: .prompt-info}

## 5. Mengatur Router agar Menggunakan Pi-Hole sebagai DNS

Agar semua perangkat di jaringan otomatis menggunakan Pi-Hole, atur DHCP server di router untuk memberikan alamat Pi-Hole sebagai DNS utama. Langkah-langkahnya bergantung pada merek router, namun pada umumnya seperti berikut:

1. Login ke antarmuka router (biasanya `192.168.0.1` atau `192.168.1.1`).
   ![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/login-router.png)

2. Cari menu DHCP Server.
3. Aktifkan DHCP jika belum.
4. Atur parameter seperti contoh di bawah (sesuaikan dengan jaringan Anda):
   ![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/dhcp-server.png)

   - IP Address Pool: `192.168.0.100` – `192.168.0.199` (rentang IP yang diberikan ke client)
   - Address Lease Time: `120` menit (bisa disesuaikan)
   - Default Gateway: `192.168.0.1` (IP router)
   - Primary DNS: `192.168.0.50` (IP server Pi-Hole)
   - Secondary DNS: `192.168.0.50` (juga Pi-Hole, agar jika satu gagal tetap menggunakan yang sama)

5. Simpan pengaturan dan reboot router.

Setelah itu, semua perangkat yang terhubung ke jaringan akan mendapatkan IP dan DNS baru. Untuk memastikan, periksa pengaturan jaringan di salah satu perangkat (misalnya smartphone) dan lihat apakah DNS yang digunakan adalah `192.168.0.50`.

![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/android-network.jpg)

## 6. Menambahkan Blocklist dan Allowlist

Pi-Hole menggunakan blocklist (daftar domain yang diblokir) yang diperbarui secara berkala. Anda dapat menambahkan sumber blocklist tambahan untuk meningkatkan efektivitas.

1. Masuk ke admin panel Pi-Hole.
2. Buka menu Lists → Add a new subscribed list.
   ![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/subscribed-list-group-management.png)

3. Masukkan URL blocklist. Contoh sumber populer:
   ```
   https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/tif.txt https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/adblock/pro.txt
   ```
   > Beberapa daftar dapat ditambahkan dengan memisahkan setiap URL unik menggunakan spasi atau koma.
   {: .prompt-tip}
   URL tersebut berisi gabungan beberapa blocklist terkenal.
4. Klik Add blocklist untuk menyimpan.
5. Setelah menambahkan, jalankan Update Gravity (tombol `online` di bagian atas) untuk mengunduh dan memproses blocklist baru. Proses ini bisa memakan waktu beberapa menit.
   ![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/update-gravity.png)

Anda juga dapat menambahkan allowlist (domain yang diizinkan) melalui menu yang sama jika ada situs yang tidak sengaja terblokir.

## 7. Melihat Statistik dan Query Log

Admin panel Pi-Hole menyediakan dasbor informatif:

- Query Log : menampilkan riwayat permintaan DNS dari setiap client, termasuk yang diblokir (ditandai merah) dan yang diizinkan (hijau).
- Analytics : grafik dan statistik tentang total query, persentase blokir, domain teratas, client teratas, dll.

Anda bisa melihat situs apa saja yang dikunjungi oleh perangkat tertentu, sehingga berguna untuk pemantauan dan evaluasi.

![alt text](../assets/img/posts/2026-03-08-instalasi-dan-konfigurasi-pi-hole-dengan-docker-untuk-blokir-jaringan-iklan-di-seluruh-jaringan/network-overview.png)

## 8. Pemeliharaan Rutin

### Menghapus Log Secara Otomatis dengan Cron

Pi-Hole menyimpan log query dalam database dan file log. Agar tidak memenuhi disk, Anda bisa menjadwalkan pembersihan log setiap hari pukul 02.00 dini hari.

Tambahkan cron job di host (bukan di dalam container):

```bash
sudo crontab -e
```

Tambahkan baris berikut:

```
0 2 * * * docker exec pihole pihole -f
```

Simpan dan keluar. Perintah ini akan menjalankan `pihole -f` (flush logs) di dalam container setiap jam 2 pagi.

### Menghapus Log Secara Manual

Jika ingin membersihkan log saat itu juga, masuk ke shell container:

```bash
docker exec -it pihole bash
```

Kemudian jalankan:

```bash
pihole flush
```

Output yang muncul kurang lebih seperti ini:

```
  [✓] Flushed /var/log/pihole/pihole.log ...
  [✓] Flushed /var/log/pihole/FTL.log ...
  [✓] Flushed /var/log/pihole/webserver.log ...
  [i] Flushing database, DNS resolution temporarily unavailable ...
  [✓] Deleted  queries from long-term query database
```

Perhatikan pesan `service: command not found` dapat diabaikan karena Pi-Hole berjalan di container tanpa systemd.

### Memperbarui Image Pi-Hole

Secara berkala, periksa apakah ada versi baru Pi-Hole:

```bash
docker compose pull
docker compose up -d
```

Container akan di-restart dengan image terbaru jika ada perubahan.

## Kesimpulan

Dengan mengikuti panduan ini, Anda berhasil memasang Pi-Hole menggunakan Docker dan mengonfigurasinya sebagai DNS server lokal. Seluruh perangkat di jaringan kini terlindungi dari iklan dan pelacak tanpa perlu konfigurasi tambahan.

Pi-Hole juga memberikan wawasan berharga tentang lalu lintas DNS di jaringan Anda. Anda dapat terus mengeksplorasi fitur-fitur seperti pengaturan grup, penjadwalan, dan integrasi dengan layanan pihak ketiga.

## Referensi Tambahan
- [Digital Independence](https://github.com/ricalnet/digital-independence)
- [Integrasi Cloudflared DoH dengan Pi-hole di Docker](https://ricaldocs.github.io/posts/integrasi-cloudflared-doh-dengan-pi-hole-di-docker/)
- [DNS List for Security & Privacy](https://ricaldocs.github.io/posts/dns-list-for-security-and-privacy/)
- [Dokumentasi Resmi Pi-Hole](https://docs.pi-hole.net/)
- [Dokumentasi Docker Compose](https://docs.docker.com/compose/)