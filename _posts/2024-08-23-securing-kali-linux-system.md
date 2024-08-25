---
title: Securing Kali Linux System
description: Mengamankan Kali Linux merupakan aspek krusial, terutama bagi para profesional yang rutin melakukan penetration testing. Keamanan sistem harus menjadi prioritas utama untuk memastikan efektivitas dan integritas aktivitas yang dilakukan.
categories: [Cybersecurity, Linux, Privacy]
tags: [cybersecurity, linux, privacy]
author: rical
---

Kenapa ini penting? Karena pengaturan bawaan Kali Linux seringkali rentan dan Kali Linux tidak dirancang khusus untuk privasi (berbeda dengan distribusi seperti [Tails OS](https://tails.net/)).

> Kali Linux memang dirancang dengan fokus pada serangan, bukan pertahanan. Keamanan itu luas dan kompleks. Meskipun banyak yang menggunakan Kali untuk menguji sistem, melindungi Kali itu sendiri juga sangat krusial.
{: .prompt-info }

Meski Kali berbasis [Debian](https://www.debian.org/) yang menawarkan dasar keamanan yang solid, ada kalanya kita memerlukan tingkat keamanan yang lebih ketat.

## Mengubah Kata Sandi Bawaan
```bash
passwd
```
Pada perintah di atas, kita tidak menggunakan `sudo` dikarenakan kita sudah menjadi *super user* (root). Perintah sederhana ini akan menanyakan kata sandi pengguna saat ini kepada kita (*default* jika diubah). Kemudian ia akan meminta kata sandi baru dan memverifikasinya lagi. 

Kata sandi yang baik harus berisi huruf besar dan kecil dengan simbol dan angka acak. Perlu diingat bahwa *password* yang diketik, tidak akan ditampilkan demi alasan keamanan.

## Sering Melakukan Pembaruan Kali Linux
Kita juga harus melakukan *update* dan *upgrade* Kali Linux setelah beberapa hari dengan menggunakan perintah berikut:
```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
```

## Mengubah Identitas
Selama berselancar di internet dengan mesin Kali Linux, kita dapat menggunakan alat [Prabu Incognito](https://ricaldocs.github.io/posts/prabu-incognito/) untuk menjelajah dengan aman dan anonim.

## Monitoring Logs
Menganalisis program *logcheck* bisa menjadi penyelamat nyata. Itu dapat mengirim pesan yang dicatat langsung ke email admin. File log disimpan secara lokal di dalam `/var/log` secara *default*.

Menggunakan alat `htop` :
```bash
sudo apt install htop -y 
```
Ini akan menunjukkan aktivitas pemantauan secara *real-time*. Bahkan perintah `xfce4-taskmanager`atau `gnome-system-monitor` dapat melakukan tindakan serupa.

Kita juga perlu sering memindai sistem untuk mencari *malware* dan *rootkit*. Kita dapat menjalankan pemindaian dengan menggunakan alat `chkrootkit` atau `rkhunter`. Alat-alat ini seperti *anti-malware* untuk sistem Linux.

## Mengganti Default SSH Keys
Masuk ke direktori `/etc/ssh` dengan perintah:
```bash
cd /etc/ssh
```

Buat direktori baru bernama `old_keys` menggunakan perintah:
```bash
sudo mkdir old _keys
```

Pindahkan semua kunci SSH lama ke dalam direktori `old_keys` dengan perintah:
```bash
sudo mv ssh_host_* old_keys
```

Rekonfigurasi OpenSSH server untuk menghasilkan kunci host baru dengan perintah:
```bash
sudo dpkg-reconfigure openssh-server
```

## Percakapan Tambahan
Meskipun Kali Linux dirancang untuk tujuan penyerangan, lingkungan itu sendiri cukup aman. Namun, pengguna yang lebih mahir seringkali melakukan lebih dari sekadar tugas sehari-hari dan penting untuk mengikuti prosedur yang benar. 

Pengguna baru yang beralih dari sistem operasi lain seperti Windows mungkin berpikir bahwa hanya menjalankan Kali Linux di dalam [VMWare](https://www.vmware.com/) atau [VirtualBox](https://www.virtualbox.org/) adalah proses yang paling aman. Ini cukup benar, tetapi beberapa langkah harus diambil.

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)