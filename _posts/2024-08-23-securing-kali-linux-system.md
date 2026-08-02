---
title: Securing Kali Linux System
description: Mengamankan Kali Linux merupakan aspek krusial, terutama bagi para profesional yang rutin melakukan penetration testing. Keamanan sistem harus menjadi prioritas utama untuk memastikan efektivitas dan integritas aktivitas yang dilakukan.
categories: [Cybersecurity]
tags: [linux]
author: rical
last_modified_at: 2026-06-01
---

## Pentingnya Keamanan Kali Linux
Pengaturan bawaan Kali Linux seringkali rentan, dan Kali Linux tidak dirancang khusus untuk privasi, berbeda dengan distribusi seperti [Tails OS](https://tails.net/). 

> Kali Linux memang dirancang dengan fokus pada serangan, bukan pertahanan. Keamanan itu luas dan kompleks. Meskipun banyak yang menggunakan Kali untuk menguji sistem, melindungi Kali itu sendiri juga sangat krusial.
{: .prompt-info}

Meskipun Kali berbasis [Debian](https://www.debian.org/) yang menawarkan dasar keamanan yang solid, ada kalanya kita memerlukan tingkat keamanan yang lebih ketat.

## Mengubah Kata Sandi Bawaan
Untuk mengubah kata sandi bawaan, gunakan perintah berikut:
```bash
passwd
```
Perintah ini tidak memerlukan `sudo` karena pengguna sudah menjadi super user (root). Perintah ini akan meminta kata sandi pengguna saat ini dan kemudian meminta kata sandi baru untuk diverifikasi. Kata sandi yang baik harus mengandung huruf besar, huruf kecil, simbol, dan angka acak. Perlu diingat bahwa kata sandi yang diketik tidak akan ditampilkan demi alasan keamanan.

## Melakukan Pembaruan Kali Linux Secara Berkala
Lakukan pembaruan dan peningkatan Kali Linux secara berkala dengan menggunakan perintah berikut:
```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
```

## Mengubah Identitas Saat Berselancar
Selama berselancar di internet dengan mesin Kali Linux, pengguna dapat menggunakan alat [NipeX](https://github.com/ricalnet/nipex/) untuk menjelajah dengan aman dan anonim.

## Monitoring Log
Menganalisis program logcheck dapat menjadi penyelamat nyata, karena dapat mengirim pesan yang dicatat langsung ke email admin. File log disimpan secara lokal di dalam `/var/log`{: .filepath} secara default.

Untuk memantau aktivitas secara real-time, pengguna dapat menggunakan alat `htop`:
```bash
sudo apt install htop -y 
```
Perintah `xfce4-taskmanager` atau `gnome-system-monitor` juga dapat digunakan untuk tujuan serupa.

Pengguna juga perlu sering memindai sistem untuk mencari malware dan rootkit dengan menggunakan alat `chkrootkit` atau `rkhunter`, yang berfungsi sebagai anti-malware untuk sistem Linux.

### rkhunter
Untuk memperbarui properti rkhunter, gunakan perintah:
```bash
sudo rkhunter --propupd
```
Untuk melakukan pemeriksaan, gunakan perintah:
```bash
sudo rkhunter --check
```

### chkrootkit
Untuk memindai sistem, gunakan perintah:
```bash
sudo chkrootkit
```

## Mengganti Kunci SSH Bawaan
Masuk ke direktori `/etc/ssh`{: .filepath} dengan perintah:
```bash
cd /etc/ssh
```
Buat direktori baru bernama `old_keys` dengan perintah:
```bash
sudo mkdir old_keys
```
Pindahkan semua kunci SSH lama ke dalam direktori `old_keys`{: .filepath} dengan perintah:
```bash
sudo mv ssh_host_* old_keys
```
Rekonfigurasi OpenSSH server untuk menghasilkan kunci host baru dengan perintah:
```bash
sudo dpkg-reconfigure openssh-server
```

## Percakapan Tambahan
Meskipun Kali Linux dirancang untuk tujuan penyerangan, lingkungan itu sendiri cukup aman. Namun, pengguna yang lebih mahir seringkali melakukan lebih dari sekadar tugas sehari-hari, sehingga penting untuk mengikuti prosedur yang benar. 

Pengguna baru yang beralih dari sistem operasi lain seperti Windows mungkin berpikir bahwa hanya menjalankan Kali Linux di dalam [VMWare](https://www.vmware.com/) atau [VirtualBox](https://www.virtualbox.org/) adalah proses yang paling aman. Ini cukup benar, tetapi beberapa langkah harus diambil untuk memastikan keamanan yang lebih baik.
