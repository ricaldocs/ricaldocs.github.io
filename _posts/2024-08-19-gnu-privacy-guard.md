---
title: GNU Privacy Guard
description: Dengan GnuPG, kita dapat mengamankan pesan dan file dari pengintaian, memastikan integritas dan keaslian informasi dalam dunia digital yang penuh ancaman.
categories: [Cybersecurity, Linux, Privacy]
tags: [cybersecurity, linux, privacy, open source]
author: rical
---

GnuPG, atau GNU Privacy Guard, adalah alat kriptografi *open-source* yang memberikan kekuatan untuk melindungi data dengan <a href= "https://en.wikipedia.org/wiki/Encryption#Encryption_in_cryptography" target="_blank">enkripsi</a> dan tanda tangan digital.
Dibangun di atas standar OpenPGP, GnuPG memungkinkan untuk menjaga privasi komunikasi dan integritas informasi dengan cara yang sangat aman.

> Saya sering memanfaatkan metode ini untuk mengamankan kata sandi dan berkomunikasi dengan aman. Walaupun berbagai aplikasi *password manager* tersedia, saya pribadi lebih percaya pada penyimpanan lokal yang dienkripsi sebagai opsi yang lebih solid dan terpercaya.
{: .prompt-tip }

Fungsi utama yang bisa dilakukan oleh GnuPG:
- [x] Enkripsi Data
- [x] Komunikasi yang Aman
- [x] Kontrol Akses
- [x] Tanda Tangan Digital
- [x] Verifikasi Tanda Tangan

## Encryption & Decryption

### Asymmetric & Symmetric
- **Asymmetric:** Memanfaatkan dua kunci yang berbeda, yaitu **Public Key** dan **Private Key**. Ini sering digunakan untuk komunikasi.
- **Symmetric:** Menggunakan kunci yang sama untuk proses enkripsi dan dekripsi, yaitu *passphrase* atau kata sandi. Ini sering digunakan untuk mengenkripsi sebuah file.

## Asymmetric
### Generate Key
Gunakan perintah ini untuk membuat sebuah kunci:

```bash
gpg  --full-generate-key
```

Konfigurasi kunci dengan mengikuti perintah yang muncul di terminal.

### Encrypt
Buat `file.txt` dan ketikkan perintah berikut untuk mengenkripsi file:

```bash
gpg -e -r <email> file.txt
```
> 
- `-e` atau `--encrypt`. Opsi ini menunjukkan untuk mengenkripsi data. 
- `-r` atau `--recipient`. Opsi ini diikuti oleh identifikasi *public key* penerima. 
{: .prompt-info }

Setelah melakukan enkripsi, file akan berganti nama menjadi `file.txt.gpg`

### Decrypt
Gunakan perintah berikut untuk melakukan dekripsi:

```bash
gpg -d file.txt.gpg
```

> `-d` atau `--decrypt`. Opsi ini digunakan untuk mendekripsi data.
{: .prompt-info }

Untuk mendekripsi data ke dalam sebuah file, gunakan perintah berikut:

```bash
gpg -d file.txt.gpg > file.txt
```

Jika menggunakan *passphrase* pada saat pembuatan kunci, gunakan *passphrase* tersebut untuk mendekripsi file dan nantinya format file akan berubah seperti semula menjadi `file.txt`


### Export Key
> Jangan sekali-kali membocorkan kunci pribadi; kunci tersebut adalah aset eksklusif yang seharusnya hanya berada di tangan kamu.
{: .prompt-danger }

#### Public Key
- Melihat daftar kunci publik:
```bash
gpg --list-keys
```

- Menampilkan kunci publik dalam format ASCII:
```bash
gpg --armor --export <key_id>
```

- Menyimpan kunci publik ke sebuah file:
```bash
gpg --armor --export <key_id> > my_public_key.asc
```

#### Private Key
- Melihat daftar kunci publik:
```bash
gpg --list-secret-keys
```

- Menampilkan kunci pribadi dalam format ASCII
```bash
gpg --armor --export-secret-keys <key_id>
```

- Menyimpan kunci pribadi ke sebuah file
```bash
gpg --armor --export-secret-keys <key_id> > my_private_key.asc
```

### Import Key
```bash
gpg --import public-key.asc
```

Verifikasi kunci dengan menggunakan perintah berikut:
```bash
gpg --list-keys
```

### Send Message
Kita bisa mengenkripsi pesan yang disimpan dalam file atau yang ditulis langsung di *command line*.
- Jika memiliki pesan dalam file teks (misalnya `.txt`), gunakan perintah berikut:
```bash
gpg --encrypt --recipient <key_id> pesan.txt
```

- Jika ingin mengetikkan pesan langsung, gunakan perintah berikut:
```bash
echo "Halo, ini adalah pesan rahasia" | gpg --encrypt --armor --recipient <key_id> > pesan.asc
```

### Delete Key
#### Private Key
Kunci pribadi biasanya akan memiliki ID yang sama dengan kunci publik. Sebelum menghapus kunci publik, hapus terlebih dahulu kunci pribadi dengan menggunakan perintah berikut:
```bash
gpg --delete-secret-key <key_id>
```

#### Public Key
Kemudian, hapus kunci publik jika perlu:
```bash
gpg --delete-key <key_id>
```

## Symmetric
### Encrypt
Di sini, kita memiliki sebuah folder bernama `data.tar` yang akan dienkripsi menggunakan kunci Symmetric. Gunakan perintah berikut untuk mengenkripsi:
```bash 
gpg --c data.tar
```

atau bisa juga menggunakan perintah:
```bash
gpg --symmetric data.tar
```

Setelah itu, akan diminta untuk memasukkan *passphrase*. Masukkan *passphrase* atau kata sandi yang kuat, yang akan digunakan untuk proses dekripsi nanti.

> Ini juga dapat digunakan untuk format `.zip` atau arsip lainnya.
{: .prompt-info }

### Decrypt
Gunakan perintah ini untuk mendekripsi:
```bash
gpg -d data.tar.gpg > data.tar
```

## Referensi
- <a href="https://risnandapascal.github.io/ricalwiki.html" target="_blank">ricalWiki</a>
- <a href="https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key" target="_blank">Generating a new GPG key</a>


