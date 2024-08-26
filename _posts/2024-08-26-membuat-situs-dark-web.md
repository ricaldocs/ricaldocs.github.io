---
title: Membuat Situs Dark Web 
description: Seperti yang kita ketahui, situs Dark Web menggunakan ekstensi domain .onion. Pertanyaannya adalah, dapatkah kita membuat situs web kita sendiri di Dark Web menggunakan sistem Kali Linux kita? Jawabannya adalah ya, dengan mudah. Tanpa perlu port forwarding atau mengeluarkan biaya untuk membeli nama domain.
categories: [Cybersecurity, Privacy, Linux]
tags: [cybersecurity, privacy, linux, open source]
author: rical
---

## Instal dan Konfigurasi TOR
``` bash
sudo apt update && sudo apt install -y tor
```

```bash
sudo gedit /etc/tor/torrc
```

Temukan dua baris ini dan hapus tanda `#` dari kedua baris tersebut, lalu simpan file. Setelah itu, tampilannya akan seperti berikut:
```
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80 127.0.0.1:80
```

Mulai ulang layanan TOR dengan menggunakan perintah:
```bash
sudo systemctl restart tor
```

## Membuat dan Host Situs Dark Web
```bash
cd ~/Desktop && touch index.html
```

> `index.html` di sini merujuk pada konten file website yang akan dihosting.
{: .prompt-info }

File ini terletak di Desktop, jadi kita memulai server lokal berbasis PHP di Desktop menggunakan perintah berikut:
```bash
php -S 127.0.0.1:8080
```

Sekarang server pengembangan PHP akan mulai berjalan. Selanjutnya, periksa situs web localhost yang dihosting dengan menavigasi ke `127.0.0.1:8080` dari browser.
> Kita telah memulai server localhost menggunakan PHP pada port 8080. Kita juga dapat menggunakan port 80 (jika belum digunakan), namun ini memerlukan izin root (`sudo php -S 127.0.0.1:80`). Kita juga dapat menggunakan server Python, Apache, atau server web lokal lainnya untuk menghosting situs web localhost.
{: .prompt-info }

### Terhubung Ke Layanan TOR
Biarkan jendela terminal ini tetap terbuka (karena server localhost sedang berjalan). Buka terminal lain dan ketik perintah berikut di terminal baru:

```bash
sudo -u debian-tor tor
```

Tunggu beberapa saat hingga konfigurasi selesai 100%. Ini akan membangun sirkuit TOR, yang mungkin memerlukan beberapa menit tergantung pada kinerja sistem dan kecepatan internet kita. 

Semua sudah siap, *dark web* kita sudah dihosting. Tapi tunggu, di mana link .`onion`-nya?

Link `.onion` dihasilkan secara acak. Untuk melihat alamat `.onion` dari situs *dark web* yang dihosting, buka jendela terminal lain (terminal ketiga, karena kita tidak dapat menutup atau menggunakan terminal yang ada, jika tidak koneksi akan hilang) dan ketik perintah berikut untuk melihat alamatnya:
```bash
sudo cat /var/lib/tor/hidden_service/hostname
```

Sekarang kita dapat mengakses situs `.onion` ini menggunakan browser TOR dari mana saja dan perangkat apa saja. 

> Ini adalah situs demo untuk tujuan pendidikan, namun kita dapat menghosting berbagai jenis situs web di `.onion` selama tidak melanggar hukum. Jangan menyalahgunakan ini untuk menghosting situs web ilegal yang melanggar hukum. Hal tersebut akan dianggap sebagai kejahatan dan penulis tidak bertanggung jawab atasnya.
{: .prompt-danger }

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)