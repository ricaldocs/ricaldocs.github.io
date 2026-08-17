---
title: Basic Terminal Kali Linux
description: Panduan penggunaan terminal Kali Linux, mencakup perintah-perintah fundamental, teknik pengalihan output, manajemen file dan proses, serta best practices yang esensial bagi penetration tester dan profesional keamanan siber.
categories: [Cybersecurity]
tags: [linux]
author: rical
last_modified_at: 2026-06-01
---

Kali Linux, sebagai distribusi Linux yang umum digunakan dalam bidang keamanan siber, menyediakan antarmuka grafis (GUI) yang lengkap. Namun, terminal tetap menjadi komponen kritis yang menawarkan fleksibilitas dan kontrol tinggi. Banyak alat penetration testing yang dijalankan melalui terminal, sehingga pemahaman dasar terminal menjadi prasyarat penting bagi pengguna.

> Sebagai Penetration Tester, perintah terminal digunakan secara intensif dalam aktivitas harian. Artikel ini bertujuan untuk memperkenalkan dasar-dasar terminal serta perintah-perintah fundamental yang mendukung pekerjaan tersebut.
{: .prompt-info}

## Membuka Terminal di Kali Linux
Terminal dapat diakses melalui menu aplikasi atau menggunakan pintasan keyboard `Ctrl + Alt + T`.

## Fundamental Penggunaan Terminal
Terminal memungkinkan eksekusi perintah berbasis teks. Ketik perintah, lalu tekan `Enter` untuk mengeksekusinya. Untuk membersihkan antarmuka terminal, gunakan perintah `clear` atau `Ctrl + L`. Untuk membuka tab terminal baru dalam sesi yang sama, gunakan `Ctrl + Shift + T`.

### Auto-Completion untuk Perintah dan File
Fitur auto-completion diaktifkan dengan menekan tombol `Tab`. Jika terdapat beberapa file atau perintah dengan awalan serupa, terminal akan menampilkan daftar opsi yang tersedia.  
Contoh:  
```bash
┌──(kali㉿kali)-[~]
└─$ cat test.
test.sh  test.txt
```

### Menginterupsi dan Menutup Terminal
Gunakan `Ctrl + C` untuk menghentikan proses yang sedang berjalan. Untuk menutup terminal, gunakan `Ctrl + D` atau perintah `exit`.

### Mematikan dan Me-restart Sistem
Gunakan perintah `poweroff` untuk mematikan sistem dan `reboot` untuk me-restart (memerlukan hak akses root).

### Melihat Riwayat Perintah
Gunakan perintah `history` untuk menampilkan daftar perintah yang pernah dijalankan. Untuk pencarian riwayat perintah, gunakan `Ctrl + R` dan ketik bagian dari perintah yang diinginkan.

## Pengalihan Output di Terminal
Linux mendukung pengalihan output untuk keperluan pemrosesan data.

### Redirect Output ke File
Simpan output perintah ke dalam file menggunakan operator `>`:  
```bash
ls > ls-list.txt
```
Output:
```bash
┌──(kali㉿kali)-[~]
└─$ cat ls-list.txt
Desktop
Documents
Downloads
ls-list.txt
Music
Pictures
Public
rical_net
Templates
Videos
```

### Membaca File dengan Input Redirection
Gunakan operator `<` untuk membaca file sebagai input:  
```bash
cat < ls-list.txt
```

### Menggabungkan Perintah dengan Pipe
Operator `|` digunakan untuk menggabungkan beberapa perintah, di mana output perintah sebelumnya menjadi input perintah berikutnya.  
Contoh:  
```bash
cat ls-list.txt | sort | grep test
```
Output:
```bash
decrypted-test.pdf
pentestlab
speedtest-cli
testbackdoor.php
test.sh
testshell.php
test.txt
```

## Perintah Dasar Linux

### 1. `ls`  
**Deskripsi**: Menampilkan daftar file dan direktori.  
**Sintaks**:  
```bash
ls [options] [file...]
```  
**Opsi**:  
- `-l`: Tampilkan dalam format detail (long listing)  
- `-a`: Tampilkan semua file (termasuk hidden files)  
- `-h`: Tampilkan ukuran file dalam format human-readable  

**Contoh**:  
```bash
ls -la
```

### 2. `cd`  
**Deskripsi**: Berpindah direktori.  
**Sintaks**:  
```bash
cd [directory]
```  
**Contoh**:  
```bash
cd /home/user/Documents
```

### 3. `cp`  
**Deskripsi**: Menyalin file atau direktori.  
**Sintaks**:  
```bash
cp [options] source destination
```  
**Opsi**:  
- `-r`: Salin direktori secara rekursif  
- `-i`: Konfirmasi sebelum menimpa file  

**Contoh**:  
```bash
cp -r /source/directory /destination/directory
```

### 4. `mv`  
**Deskripsi**: Memindah atau mengubah nama file/direktori.  
**Sintaks**:  
```bash
mv [options] source destination
```  
**Contoh**:  
```bash
mv oldname.txt newname.txt
```

### 5. `rm`  
**Deskripsi**: Menghapus file atau direktori.  
**Sintaks**:  
```bash
rm [options] file...
```  
**Opsi**:  
- `-r`: Hapus direktori dan isinya secara rekursif  
- `-f`: Hapus tanpa konfirmasi  

**Contoh**:  
```bash
rm -rf /path/to/directory
```

### 6. `mkdir`  
**Deskripsi**: Membuat direktori baru.  
**Sintaks**:  
```bash
mkdir [options] directory...
```  
**Opsi**:  
- `-p`: Buat direktori induk jika belum ada  

**Contoh**:  
```bash
mkdir -p /path/to/new/directory
```

### 7. `chmod`  
**Deskripsi**: Mengubah izin akses file/direktori.  
**Sintaks**:  
```bash
chmod [options] mode file...
```  
**Contoh**:  
```bash
chmod 755 script.sh
```

> Untuk penjelasan lebih detail tentang `chmod`, kunjungi [dokumentasi lengkapnya](https://ricaldocs.github.io/posts/panduan-lengkap-perintah-chmod-di-linux/).

---

Dokumentasi ini mencakup fundamental terminal Linux yang esensial untuk operasi harian. Untuk informasi lebih lanjut mengenai perintah tertentu, gunakan `man [command]` untuk mengakses manual resmi sistem.