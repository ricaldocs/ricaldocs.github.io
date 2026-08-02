---
title: Panduan Redirect Domain Cloudflare ke URL Eksternal Tanpa Hosting (Wildcard Redirect)
description: Pelajari cara mengalihkan seluruh domain dan subdomain di Cloudflare ke URL tujuan tanpa server hosting. Gunakan IP dummy dan aturan Single Redirect dengan wildcard pattern untuk redirect permanen.
categories: [Cloudflare]
tags: [cloudflare, dns]
author: rical
last_modified_at: 2026-06-01
---

Dokumentasi ini menjelaskan prosedur teknis untuk mengonfigurasi pengalihan (redirect) seluruh lalu lintas dari sebuah domain yang dikelola Cloudflare menuju URL tujuan eksternal, tanpa memerlukan server hosting asal (origin server). Metode yang diimplementasikan memanfaatkan fitur Single Redirect Cloudflare dengan pola wildcard serta DNS record berstatus *proxied* yang diarahkan ke alamat IP dummy.

## Prasyarat

Sebelum memulai proses konfigurasi, pastikan seluruh kondisi berikut telah terpenuhi:

- Domain telah ditambahkan ke dalam akun Cloudflare Anda.
- DNS dikelola sepenuhnya oleh Cloudflare — nameserver domain telah diarahkan ke Cloudflare dan berstatus aktif.
- Domain tidak memiliki website atau hosting aktif; domain ini secara eksklusif difungsikan sebagai pengalih (redirect).

Agar Cloudflare dapat memproses redirect, setiap DNS record yang terlibat harus dikonfigurasi dengan status Proxied (diidentifikasi dengan ikon awan oranye). Dengan konfigurasi ini, seluruh lalu lintas akan ditangani oleh edge network Cloudflare dan tidak diteruskan ke server asal.

## Langkah 1: Membuat DNS Record Proxy dengan IP Dummy

Tambahkan DNS record untuk nama domain utama (`@`) serta subdomain `www` dengan konfigurasi sebagai berikut:

| Tipe | Nama     | Alamat IPv4 | Status Proxy |
| ---- | -------- | ----------- | ------------ |
| A    | @ (root) | 192.0.2.1   | Proxied      |
| A    | www      | 192.0.2.1   | Proxied      |

### Alasan Penggunaan IP 192.0.2.1

Alamat `192.0.2.1` termasuk dalam blok TEST-NET-1 sebagaimana ditetapkan dalam RFC 5737. Blok alamat ini dialokasikan secara khusus untuk keperluan dokumentasi dan contoh, sehingga tidak akan dirutekan di internet publik. Dengan mengarahkan DNS record ke alamat IP tersebut dan mengaktifkan proxy Cloudflare, seluruh permintaan menuju domain akan dihentikan di edge Cloudflare dan tidak akan mencapai server asal mana pun. Praktik ini direkomendasikan sebagai pendekatan yang aman untuk skenario pure-redirect.

### Prosedur Penambahan di Dasbor Cloudflare

1. Akses [dasbor Cloudflare](https://dash.cloudflare.com), kemudian pilih domain yang akan dikonfigurasi (contoh: `sokanak.id`).
2. Navigasikan ke menu **Domains** → **Overview** → **DNS** → **Records**.
3. Klik tombol **Add record**.
4. Pilih tipe A, isi kolom **Name** dengan `@` untuk root domain, dan kolom **IPv4 address** dengan `192.0.2.1`.
   ![Tangkapan layar penambahan DNS record](<../assets/img/posts/2026-05-19-panduan-redirect-domain-cloudflare-ke-url-eksternal-tanpa-hosting/Screenshot From 2026-05-19 20-10-41.png>)

5. Verifikasi bahwa status proxy menampilkan ikon awan oranye (Proxied). Klik Save.
6. Ulangi langkah yang sama untuk nama `www`.

> Apabila domain memiliki subdomain lain yang juga memerlukan pengalihan, tambahkan record A dengan IP dummy yang sama. Proses redirect pada langkah selanjutnya akan mencakup seluruh subdomain melalui penerapan pola wildcard.
{: .prompt-info}

## Langkah 2: Membuat Aturan Redirect (Single Redirect)

Setelah DNS record berhasil dikonfigurasi, langkah selanjutnya adalah membuat aturan redirect untuk meneruskan seluruh permintaan menuju URL tujuan.

### Konfigurasi Menggunakan Wildcard Pattern

1. Pada dasbor Cloudflare, tetap berada di domain yang sama, navigasikan ke menu **Rules** → **Overview** → **Create Rule** → pilih **Redirect Rule** dengan tipe **Single Redirect**.
   ![Tangkapan layar pembuatan Single Redirect rule](<../assets/img/posts/2026-05-19-panduan-redirect-domain-cloudflare-ke-url-eksternal-tanpa-hosting/Screenshot From 2026-05-19 20-28-13.png>)

2. Tetapkan nama aturan, contoh: `Redirect ke ricalnet`.
   ![Tangkapan layar penamaan aturan redirect](<../assets/img/posts/2026-05-19-panduan-redirect-domain-cloudflare-ke-url-eksternal-tanpa-hosting/Screenshot From 2026-05-19 20-13-07.png>)

3. Pada seksi **When incoming requests match**, lakukan konfigurasi sebagai berikut:
   - Pilih **Wildcard pattern**.
   - Isi kolom **Request URL** dengan pola:  
     `http*://*sokanak.id/*`
   - **Dekonstruksi pola**:
     - `http*` — mencocokkan seluruh protokol (HTTP dan HTTPS).
     - `*sokanak.id` — mencakup domain utama beserta seluruh subdomain (contoh: `www.sokanak.id`, `blog.sokanak.id`).
     - `/*` — menangkap seluruh path yang terdapat setelah domain.

4. Pada seksi **Then…**, tentukan aksi pengalihan dengan parameter berikut:
   - **Target URL**: `https://sokanak.ricalnet.my.id/`
   - **Status code**: `301` (Permanent Redirect). Kode status ini mengindikasikan kepada mesin pencari bahwa pengalihan bersifat permanen, sehingga otoritas halaman akan ditransfer ke URL tujuan.
   - **Preserve query string**: Aktifkan. Fitur ini memastikan parameter query (contoh: `?utm_source=twitter`) tetap diteruskan ke URL target.
   ![Tangkapan layar konfigurasi aksi redirect](<../assets/img/posts/2026-05-19-panduan-redirect-domain-cloudflare-ke-url-eksternal-tanpa-hosting/Screenshot From 2026-05-19 20-13-39.png>)

5. Klik **Deploy** untuk menyimpan dan mengaktivasi aturan.

## Langkah 3: Pengujian Redirect

Aturan redirect umumnya mulai berlaku dalam rentang waktu 1–2 menit, meskipun propagasi penuh dapat memerlukan waktu hingga 5–10 menit. Untuk memverifikasi keberhasilan konfigurasi, lakukan prosedur pengujian berikut:

1. Buka peramban (browser), disarankan menggunakan mode Incognito/Private untuk menghindari interferensi cache.
2. Akses `http://sokanak.id` — sistem seharusnya secara otomatis mengalihkan ke `https://sokanak.ricalnet.my.id/`.
3. Lakukan pengujian dengan subdomain dan path spesifik, contoh:  
   `https://www.sokanak.id/halaman` → harus diarahkan ke `https://sokanak.ricalnet.my.id/halaman`.
4. Lakukan pengujian dengan parameter query:  
   `http://sokanak.id/produk?ref=cloudflare` → harus diarahkan ke `https://sokanak.ricalnet.my.id/produk?ref=cloudflare`.

Apabila pengalihan belum berfungsi, tunggu beberapa menit tambahan atau periksa kembali status proxy serta sintaks pola wildcard. Penggunaan alat bantu seperti `curl -I` juga direkomendasikan untuk memeriksa header `Location` dari respons redirect.

## Penutup

Dengan konfigurasi yang telah diimplementasikan di atas, seluruh lalu lintas domain Cloudflare telah berhasil dialihkan ke URL eksternal tanpa memerlukan infrastruktur hosting tambahan. Metode ini memberikan efisiensi tinggi untuk kebutuhan domain alias, kampanye pemasaran, atau migrasi situs sederhana. Pastikan untuk selalu menggunakan kode status 301 serta mengaktifkan opsi Preserve query string apabila parameter URL diperlukan di halaman tujuan.