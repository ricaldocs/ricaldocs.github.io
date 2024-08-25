---
title: Creating a bootable USB drive
description: Langkah-langkah untuk membuat USB drive yang dapat digunakan untuk instalasi atau booting.
categories: [Linux]
tags: [linux, open source]
author: rical
---
## Linux Users
Jalankan perintah `lsblk` untuk menampilkan daftar perangkat penyimpanan:
```bash
lsblk
```
Temukan nama disk USB drive dari *output* perintah tersebut. Contohnya seperti `sda`, `sdb`,  atau `sdc`.
> Harap diperhatikan nama USB drive dengan teliti agar tidak menghapus sistem utama.
{: .prompt-warning }

Eksekusi:
```
sudo dd if=path/to/linux.iso of=/dev/sdx bs=512k
```

> 
- Ganti `sdx` dengan nama disk USB drive dari hasil perintah `lsblk` tadi.
- Ganti `path/to/linux.iso` dengan tempat penyimpanan file iso yang akan dieksekusi. Contohnya seperti `~/Downloads/linux.iso`.
{: .prompt-tip }

> Jika menggunakan lingkungan desktop GNOME dan ingin menginstall [TailsOS](https://tails.net/index.en.html), cukup buka aplikasi `Disks`, kemudian `Restore Disk Image`. Mereka juga menyediakan dokumentasi yang sangat bagus.
{: .prompt-info}

##  Booting
Setelah media *bootable* dibuat, matikan PC dan masuk ke BIOS. Atur prioritas boot sehingga USB drive menjadi opsi yang paling utama.



## Windows Users
Saya tidak peduli dengan pengguna Windows. Namun, ada alat yang bernama [Rufus](https://rufus.ie/en/) dan [Ventoy](https://www.ventoy.net/en/index.html) peduli dengannya. 

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)