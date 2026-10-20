---
title: Deploy Technitium DNS Server sebagai DoH Privat di Debian dengan Podman Caddy dan Cloudflare Tunnel
description: Panduan lengkap men-deploy Technitium DNS Server sebagai layanan DNS-over-HTTPS privat di Debian 13 menggunakan Podman rootless, Caddy sebagai reverse proxy TLS, dan Cloudflare Tunnel tanpa membuka port inbound di firewall.
categories: [Digital Independence, Communications]
tags: [self-hosted, podman, technitium, dns, privacy]
author: rical
last_modified_at: 2026-10-21
---

Dokumen ini menjelaskan cara men-deploy Technitium DNS Server sebagai layanan DNS-over-HTTPS (DoH) privat di Debian 13. Stack terdiri dari tiga komponen:

- Podman sebagai container runtime (rootless, tanpa daemon).
- Caddy sebagai reverse proxy yang menangani terminasi TLS dan meneruskan IP asli klien.
- Cloudflare Tunnel untuk mengekspos layanan ke internet tanpa membuka port inbound di firewall.

Pendekatan ini dipilih karena beberapa alasan teknis:

- Podman berjalan rootless secara default sehingga mengurangi attack surface dibanding Docker daemon.
- Caddy menangani TLS otomatis dan meneruskan header IP asli klien yang dibutuhkan Technitium untuk ACL.
- Cloudflare Tunnel membuat koneksi outbound-only, sehingga server tidak perlu IP publik statis maupun port forwarding — cocok untuk lingkungan di balik NAT/CGNAT.

> Perlu dipahami sejak awal bahwa Cloudflare Tunnel melindungi kueri DNS Anda dari ISP, tetapi Cloudflare sebagai titik akhir TLS dapat melihat kueri tersebut. Jika privasi terhadap pihak ketiga menjadi prioritas mutlak, pertimbangkan VPS dengan IP publik dan TLS langsung, atau akses melalui VPN.
{: .prompt-warning}

## Prasyarat

- Debian 13 (minimal install)
- [Panduan Lengkap Mengonfigurasi Cloudflare Tunnel untuk Ekspos Layanan Lokal](https://docs.ricalnet.my.id/posts/panduan-lengkap-mengonfigurasi-cloudflare-tunnel-untuk-ekspos-layanan-lokal/)
- Akses ke [repository Digital Independence](https://git.ricalnet.my.id/RICALNET/digital-independence.git) milik RICALNET

## 1. Clone Repository

```bash
git clone https://git.ricalnet.my.id/RICALNET/digital-independence.git ~/digital-independence
cd ~/digital-independence
```

Repository ini berisi skrip instalasi Podman untuk Caddy serta Technitium. Semua perintah selanjutnya diasumsikan dijalankan dari dalam direktori repository.

## 2. Instalasi Podman

```bash
./install-podman-on-debian.sh
```

Skrip ini memasang Podman beserta dependensi yang diperlukan dan mengaktifkan konfigurasi rootless. Setelah selesai, verifikasi dengan `podman --version`.

## 3. Konfigurasi Caddy sebagai Reverse Proxy

Masuk ke direktori Caddy, salin contoh konfigurasi, lalu edit:

```bash
dipen cd caddy
cp Caddyfile.example Caddyfile
nano Caddyfile
```

Sesuaikan domain Technitium di dalam `Caddyfile`. Caddy akan menerima request DoH dari Cloudflare Tunnel dan meneruskannya ke container Technitium, sambil menyisipkan header IP asli klien.

Jalankan Caddy:

```bash
dipen up caddy
```

> `dipen` adalah wrapper `podman-compose` yang disediakan repository. Perintah `dipen up <service>` setara dengan menjalankan service tersebut secara detached.
{: .prompt-info}

## 4. Menjalankan Technitium

```bash
dipen env technitium
dipen up technitium
sleep 30
dipen ps technitium
dipen logs technitium
```

- `dipen env technitium` menampilkan environment variable yang diekspos ke container.
- `sleep 30` memberi waktu container untuk inisialisasi config pertama sebelum log dibaca.
- `dipen ps technitium` memastikan container berjalan dan status healthcheck-nya.
- `dipen logs technitium` memastikan container berjalan tanpa error dan web service sudah listening.

Akses panel admin awal melalui:

```
http://<ip-address>:9053
```

Saat pertama kali diakses, Technitium akan meminta penggantian password admin. Lakukan segera — panel admin tanpa password kuat adalah risiko serius karena dapat mengubah konfigurasi resolver.

![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-17-22.webp>)

## 5. Konfigurasi Optional Protocols (DoH)

Buka Settings → Optional Protocols.

- Optional DNS Server Protocols: centang hanya `Enable DNS-Over-HTTP`. Protokol lain (DoT, DoQ) dinonaktifkan karena tidak diekspos melalui tunnel.
  ![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-21-45.webp>)

- DNS-over-HTTP(s) Option: uncheck `Enable Redirect to Help Page`. Redirect akan mengganggu klien DoH yang mengharapkan respons `application/dns-message`.
- DNS-over-HTTP Port: `8053`. Port internal container yang akan dituju Caddy.
  ![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-22-49.webp>)

- Reverse Proxy Network ACL:

  ```
  0.0.0.0/0
  ::/0
  ```

  > Batasi ACL hanya ke subnet container Podman (`10.88.0.0/16`) dan loopback. Jika Caddy terhubung ke Technitium melalui `127.0.0.1:9053` di host, alamat sumber yang dilihat Technitium adalah alamat gateway container, bukan `127.0.0.1`. Dalam kasus itu, tambahkan alamat gateway tersebut ke ACL, atau ubah upstream Caddy menjadi `dns-server:8053` agar koneksi terjadi di jaringan Podman internal.
  {: .prompt-tip}

- Real IP Header: `X-Real-IP`
  ![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-23-33.webp>)

Simpan pengaturan.

Mengapa ACL ini penting? Technitium hanya menerima koneksi DoH dari alamat yang ada di ACL. Karena Caddy berjalan di network Podman, subnet `10.88.0.0/16` harus diizinkan agar proxy dapat meneruskan request.

## 6. Konfigurasi Recursion (Opsional untuk Testing)

Buka Settings → Recursion.

Pilih Use specified network access control list (ACL) dan isi:

```
0.0.0.0/0
::/0
```

![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-24-50.webp>)

> Gunakan Allow Only Private Networks (sudah menjadi default di compose) atau Use specified network access control list yang hanya berisi subnet Podman (`10.88.0.0/16`) dan loopback (`127.0.0.1/32, ::1/128`). Membuka rekursi ke `0.0.0.0/0` berpotensi menjadikan server alat serangan amplifikasi jika port 53/5353 terekspos.
{: .prompt-tip}

Simpan pengaturan.

## 7. Verifikasi End-to-End

Uji endpoint DoH menggunakan query DNS biner (format wire-format) untuk `google.com`:

```bash
curl -i 'https://technitium.yourdomain.com/dns-query?dns=AAABAAABAAAAAAAABmdvb2dsZQNjb20AAAEAAQ'
```

Output yang diharapkan:

```
HTTP/2 200
date: Tue, 20 Oct 2026 13:08:48 GMT
content-type: application/dns-message
content-length: 124
via: 1.1 Caddy
cf-cache-status: DYNAMIC
nel: {"report_to":"cf-nel","success_fraction":0.0,"max_age":604800}
strict-transport-security: max-age=15552000; includeSubDomains
speculation-rules: "/cdn-cgi/speculation"
report-to: {"group":"cf-nel","max_age":604800,"endpoints":[{"url":"https://a.nel.cloudflare.com/report/v4?s=2V%2F3LTNAWJ77x1C%2BqJWy84GdjwcJz4c2VTimzAO5uPTsPhJLi3n8pdONwpC91z6rIkaOL7i%2FwhbPFLrFrveA84l8mUAb67%2FGIAjQDgr0Ec7hEGY%2FZ%2BkffDXKddlmiBv%2F0Dj%2B2OmvrwfCj7qt"}]}
server: cloudflare
cf-ray: a4d840d48f62312c-LAX
alt-svc: h3=":443"; ma=86400
```

Indikator keberhasilan yang perlu diperiksa:

| Indikator | Makna |
|---|---|
| `HTTP/2 200` | Request berhasil melewati Caddy dan Cloudflare |
| `content-type: application/dns-message` | Technitium merespons dengan format DNS biner yang benar (bukan halaman HTML) |
| `via: 1.1 Caddy` | Request benar-benar melewati reverse proxy Caddy |
| `cf-cache-status: DYNAMIC` | Cloudflare tidak meng-cache respons DoH (benar, karena query DNS bersifat dinamis) |
| `content-length: 124` | Panjang respons sesuai dengan jawaban DNS untuk `google.com` A record |

Jika `content-type` berupa `text/html`, kemungkinan opsi Redirect to Help Page masih aktif atau ACL menolak koneksi dari Caddy.

## 8. Konfigurasi Forwarders

Buka Settings → Proxy & Forwarders.

Pada bagian Forwarders, pilih Quick select → DNS4EU (DNS-over-HTTPS).

![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-27-06.webp>)

Mengapa menggunakan forwarder DoH? Alih-alih melakukan rekursi penuh dari root, Technitium meneruskan query ke resolver upstream melalui DoH terenkripsi. Ini mengurangi latensi dan menghindari masalah rekursi yang diblokir oleh ISP.

DNS4EU (https://protective.joindns4.eu/dns-query, IP 86.54.11.1 dan 86.54.11.201) dipilih karena merupakan resolver publik yang dikelola di Uni Eropa dengan fokus privasi (alamat IP klien dianonimkan sebelum dicatat), tidak ada data pribadi yang dikumpulkan, dan sepenuhnya selaras dengan GDPR. Varian Protective yang digunakan di sini memblokir domain berbahaya (phishing, malware, C2) di lapisan DNS, sehingga menambah lapisan pertahanan tanpa mengorbankan privasi.

Perlu diperhatikan bahwa DNS4EU Public Service ditujukan untuk penggunaan individu dan memiliki pembatasan laju (rate limit), sehingga tidak cocok untuk organisasi atau penggunaan bersama dalam skala besar. Selain itu, karena infrastrukturnya terpusat di Eropa, latensi dari Indonesia akan lebih tinggi dibandingkan resolver dengan PoP di Jakarta. Jika latensi menjadi prioritas utama, Cloudflare (1.1.1.1) tetap dapat dipertimbangkan dengan catatan bahwa Cloudflare dapat melihat kueri Anda. Pilihan lainnya adalah Quad9, yang juga menganonimkan IP klien dan memiliki jangkauan PoP lebih luas

Simpan pengaturan.

## 9. Konfigurasi Port Forwarding DNS (Opsional)

> Bagian ini hanya diperlukan jika Anda ingin melayani DNS plaintext di port 53 untuk klien di jaringan lokal. Jika hanya DoH, lewati bagian ini dan pastikan port 5353 tetap terikat ke `127.0.0.1`.
{: .prompt-warning}

### Mengapa Perlu Port Forwarding?

Technitium mendengarkan DNS di port 5353 (bukan port 53 standar). Ini karena Podman berjalan dalam mode rootless (tanpa hak akses root) untuk keamanan maksimal. Container rootless tidak dapat mengikat (bind) port di bawah 1024, termasuk port 53. Ini adalah batasan keamanan yang disengaja untuk mencegah container non-root mengambil alih layanan sistem kritis.

> Gunakan iptables untuk redirect traffic dari port 53 ke port 5353.
{: .prompt-tip}

### Setup Iptables

```bash
# Redirect UDP DNS
sudo iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-port 5353

# Redirect TCP DNS
sudo iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-port 5353

# Verifikasi rule
sudo iptables -t nat -L -v -n | grep 5353
```

### Persistensi Setelah Reboot

```bash
# Install iptables-persistent
sudo apt update
sudo apt install iptables-persistent -y

# Save rules
sudo netfilter-persistent save

# Verifikasi file rules
ls -la /etc/iptables/rules.v4

# Cek status service
sudo systemctl status netfilter-persistent
sudo systemctl is-enabled netfilter-persistent
```

### Verifikasi Rule Iptables

```bash
sudo cat /etc/iptables/rules.v4

# Output seharusnya ada baris:
# -A PREROUTING -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 5353
# -A PREROUTING -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
```

## 10. Konfigurasi Klien

### Android

Pasang aplikasi Intra atau Rethink DNS dari Play Store. Keduanya mendukung DoH kustom. Masukkan URL:

```
https://technitium.yourdomain.com/dns-query
```

![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-50-08.webp>)

### Browser berbasis Chromium (Chrome, Brave, Edge)

Buka Settings → Privacy & Security → Security → Use secure DNS → Add custom DNS provider, lalu masukkan:

```
https://technitium.yourdomain.com/dns-query
```

![alt text](<../assets/img/posts/2026-10-20-deploy-technitium-dns-server-sebagai-doh-privat-di-debian-dengan-podman-caddy-dan-cloudflare-tunnel/Screenshot From 2026-10-20 23-40-08.webp>)

> DoH di browser hanya berlaku untuk resolusi di dalam browser tersebut, bukan seluruh sistem. Untuk cakupan sistem penuh di Android, gunakan Intra/Rethink DNS yang membuat VPN lokal (loopback) untuk mengintersepsi semua query DNS.
{: .prompt-info}

## Pertimbangan Keamanan dan Produksi

- Ganti password admin segera setelah instalasi. Panel di port `9053` tidak boleh diekspos ke internet.
- Batasi Reverse Proxy Network ACL ke subnet container Podman (`10.88.0.0/16`) dan loopback. Membuka ACL ke `0.0.0.0/0` membuat filter IP menjadi tidak efektif.
- Batasi Recursion ACL ke private networks atau subnet Podman. Rekursi terbuka adalah vektor serangan amplifikasi.
- Pastikan tidak ada port mapping `-p 53:53` pada container Technitium. Jika port 53 di host di-redirect ke 5353, pastikan 5353 tetap terikat ke `127.0.0.1`.
- Pertimbangkan menambahkan rate limit di Cloudflare (WAF) untuk endpoint `/dns-query` guna mencegah penyalahgunaan.
- Jika endpoint DoH terbuka untuk publik, bagikan URL hanya kepada pihak yang dipercaya. DoH tidak memiliki autentikasi, sehingga siapa pun yang mengetahui URL dapat menggunakannya.