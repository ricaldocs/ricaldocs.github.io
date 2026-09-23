---
title: Kriptografi dan Steganografi
description: Implementasi teknik kriptografi modern dan steganografi - Caesar Cipher, AES-256 dekripsi, verifikasi SHA-256, encoding Base64, dan Steghide. Studi kasus lengkap dengan command Linux dan analisis hasil untuk pemahaman keamanan data.
categories: [Cybersecurity, Cryptography] 
tags: [cryptography]
author: rical
last_modified_at: 2026-08-17
---

## Pendahuluan

Kriptografi adalah fondasi keamanan informasi modern. Dokumen ini membahas implementasi praktis tiga konsep kriptografi fundamental dengan pendekatan hands-on menggunakan command-line Linux.

Cakupan:
1. [Encoding](#1-encoding) - Transformasi data reversibel
2. [Hashing vs. Enkripsi](#2-hashing-vs-enkripsi) - Perbedaan mekanisme dan use case
3. [Steganografi](#3-steganografi) - Penyembunyian data dalam media digital
4. [Studi Kasus](#4-studi-kasus-kriptografi-lanjutan) - Implementasi dan analisis kriptografi modern

## 1. Encoding

Encoding adalah proses konversi data ke format representasi berbeda yang sepenuhnya reversibel tanpa memerlukan kunci. Tujuan utamanya adalah kompatibilitas sistem, bukan kerahasiaan.

### Caesar Cipher - Substitusi Klasik

Algoritma substitusi dengan pergeseran (shift) karakter dalam alfabet. Meskipun tergolong cipher, implementasi ini lebih tepat disebut encoding karena pergeseran statis tanpa kunci rahasia.

Mekanisme:
- Setiap huruf digeser sejauh `n` posisi dalam alfabet
- Karakter non-alfabet tetap tidak berubah
- Pergeseran >26 akan wrap-around (modulo 26)

![alt text](../assets/img/posts/2025-07-20-kriptografi-dan-steganografi/shift-3.png)

Implementasi dengan `tr`:

```bash
# Enkripsi shift +3
echo "cipher" | tr 'A-Za-z' 'D-ZA-Cd-za-c'
# Output: flskhu

# Dekripsi shift -3  
echo "flskhu" | tr 'D-ZA-Cd-za-c' 'A-Za-z'
# Output: cipher
```

Kelemahan Kriptanalisis:
- Keyspace hanya 26 kemungkinan → brute force trivial
- Mempertahankan frekuensi karakter → rentan frequency analysis
- Tidak ada diffusion → perubahan plaintext berdampak lokal

> Hanya untuk edukasi atau obfuscasi ringan. Jangan digunakan untuk data sensitif.
{: .prompt-danger}

### Base64 - Encoding Biner-ke-Teks

Mengonversi data biner menjadi representasi ASCII dengan 64 karakter (A-Z, a-z, 0-9, +, /). Digunakan untuk transmisi data melalui saluran yang hanya mendukung teks (email, JSON, URL).

Mekanisme Encoding:
1. Setiap 3 byte (24 bit) dipecah menjadi 4 group @ 6 bit
2. Setiap 6-bit value dipetakan ke tabel Base64
3. Padding `=` ditambahkan jika data tidak kelipatan 3 byte

Implementasi:

```bash
# Encoding
echo "encoding" | base64
# Output: ZW5jb2RpbmcK

# Decoding
echo "ZW5jb2RpbmcK" | base64 -d
# Output: encoding
```

Catatan Penting:
- Base64 bukan enkripsi - tidak ada kunci
- Overhead ukuran ±33% dari data asli
- Sering digunakan dalam conjunction dengan enkripsi sebenarnya

## 2. Hashing vs. Enkripsi

![Diagram Perbandingan Hashing vs. Enkripsi](/assets/img/posts/2025-07-20-kriptografi-dan-steganografi/hashing_vs_encryption.png)

### Hash Function - One-Way Transformation

Fungsi hash kriptografi memetakan input dengan panjang variabel ke output fixed-length. Sifat irreversibel secara matematis.

Properti Kriptografi Kritis:
- Pre-image resistance: Tidak feasible menemukan input dari hash
- Second pre-image resistance: Tidak feasible menemukan input berbeda dengan hash yang sama
- Collision resistance: Tidak feasible menemukan dua input dengan hash identik

Implementasi dengan MD5 (Demo Only):

```bash
echo "teks" | md5sum
# Output: c71448894eaaadb0217e6d4e92b44ef7
```

> MD5 dan SHA-1 sudah compromised. Gunakan SHA-256 atau SHA-3 untuk aplikasi produksi.
{: .prompt-warning}

### Enkripsi Simetris - Two-Way Transformation

Mengubah plaintext ke ciphertext menggunakan kunci yang sama untuk enkripsi dan dekripsi. AES-256-CBC adalah standar industri.

Aliran Proses AES-256-CBC:
1. Key derivation dengan PBKDF2 (salt + iterasi)
2. Pembagian data menjadi blok 16-byte
3. XOR setiap blok dengan previous ciphertext (CBC mode)
4. Enkripsi blok dengan AES-256

OpenSSL Implementation:

```bash
# Enkripsi
echo "teks" | openssl aes-256-cbc -a -pass pass:changeme -pbkdf2
# Output: U2FsdGVkX188ZcetEtbc5uRwnzPC0XyXccmRWxoWWYc=

# Dekripsi
echo "U2FsdGVkX188ZcetEtbc5uRwnzPC0XyXccmRWxoWWYc=" | \
     openssl aes-256-cbc -d -a -pass pass:changeme -pbkdf2
# Output: teks
```

Parameter Kritis:
- `-a`: Base64 encoding output (memudahkan handling)
- `-pbkdf2`: Menggunakan PBKDF2 dengan 10,000 iterasi default
- Salt: Generated random (terlihat di output Base64)
- IV: Auto-generated per operasi (terenkapsulasi dalam output)

> Gunakan `-pbkdf2` untuk mencegah brute force dengan GPU/ASIC. Iterasi minimal 100,000 untuk aplikasi production.
{: .prompt-info}

## 3. Steganografi

Steganografi (Yunani: steganos = tersembunyi, graphein = menulis) menyembunyikan eksistensi data, berbeda dengan kriptografi yang menyembunyikan konten.

### Steghide - Tool Steganografi Open Source

Berlisensi GPL, mendukung embedding di file:
- Gambar: JPEG, BMP
- Audio: WAV, AU

Mekanisme Kerja:
1. Mengubah data payload menjadi stream bit
2. Mengganti LSB (Least Significant Bits) carrier dengan payload
3. Opsional: kompresi + enkripsi dengan passphrase

Instalasi:

```bash
sudo apt update && sudo apt install -y steghide
```

Persiapan:

```bash
# Buat payload
echo "Ini pesan rahasia" > pesan-rahasia.txt

# Siapkan carrier image (format JPEG)
# gambarkan.jpg harus tersedia
```

Embedding Payload:

```bash
steghide embed -cf gambar.jpg -ef pesan-rahasia.txt
```

Parameter:
- `-cf`: Carrier file (cover file)
- `-ef`: Embed file (payload)
- Passphrase: Input interaktif (opsional)

Ekstraksi Payload:

```bash
steghide extract -sf gambar.jpg -xf pesan-ekstrak.txt
```

Parameter:
- `-sf`: Stego file (file yang mengandung payload)
- `-xf`: Extract file (output path)

Verifikasi Integritas:

```bash
# Bandingkan checksum
md5sum pesan-rahasia.txt pesan-ekstrak.txt

# Atau diff konten
diff pesan-rahasia.txt pesan-ekstrak.txt
```

Karakteristik Steghide:
- Menyembunyikan data dalam LSB tanpa merubah ukuran file
- Keberadaan payload tidak terdeteksi visual
- Passphrase untuk enkripsi tambahan (AES-256)
- Kompresi payload dengan zlib

> Steghide hanya mendukung carrier JPEG, BMP, WAV, AU. Tidak mendukung PNG karena kompresi lossless akan merusak payload.
{: .prompt-warning}

## 4. Studi Kasus Kriptografi Lanjutan

### 4.1 Caesar Cipher Shift 3 pada "ricalnet"

Eksperimen:
Menguji implementasi Caesar dengan plaintext "ricalnet" untuk memverifikasi round-trip integrity.

```bash
# Enkripsi
echo "ricalnet" | tr 'A-Za-z' 'D-ZA-Cd-za-c'
# Output: ulfdoqhw

# Dekripsi
echo "ulfdoqhw" | tr 'D-ZA-Cd-za-c' 'A-Za-z'  
# Output: ricalnet
```

Analisis:
- Plaintext → Ciphertext: r→u, i→l, c→f, a→d, l→o, n→q, e→h, t→w
- Verifikasi: Output round-trip = input (100% fidelity)
- Integritas: Tidak ada data loss atau korupsi

Implikasi:
- Cocok untuk obfuscation low-stake
- Tidak aman untuk data sensitif (keyspace 26)

### 4.2 Dekripsi AES dengan External Tool

Target Ciphertext (Base64):
```
setOEOcknlX8licRMDY5+A==
```

Metodologi:
Menggunakan [anycript.com/crypto](https://anycript.com/crypto) dengan asumsi:
- Key: Diketahui sebelumnya (tidak tersedia dalam skenario ini)
- Mode: AES (implementasi spesifik tidak disebutkan)
- IV: Dikelola oleh tool

Hasil Dekripsi:
- Plaintext: `Hello Friend`
- Status: Successful tanpa error/exception
- Validasi: Output berupa teks terbaca (semantically correct)

![alt text](../assets/img/posts/2025-07-20-kriptografi-dan-steganografi/aes_decryption.png)

Analisis:
- Ciphertext valid → key dan IV correct
- Format Base64 memudahkan transfer
- AES encryption strength terkonfirmasi

### 4.3 Analisis Integritas Data dengan SHA-256

Tujuan: Mendemonstrasikan avalanche effect - perubahan 1 bit input mengubah ~50% output hash.

Data Uji:

`fbi.txt`:
```
"Ini merupakan data rahasia dari FBI, jaga keutuhan data ini!!!"
```

`fbi_modified.txt`:
```
"Ini merupakan data rahasia dari FBI, jaga keutuhan data ini!!!!"
```
Perbedaan: Satu karakter `!` tambahan

Hash Computation:

```bash
# Original
sha256sum fbi.txt
# 2b912f3d7005165f0cf2812637ce67f636271c3f28961936e562217c0781bc2a

# Modified
sha256sum fbi_modified.txt
# 6ad620719d659d91b87a8226a27b38bbf82500dd5e72c0bb65b9dc00e1688898
```

Analisis Kriptografi:

| Properti   | Original      | Modified      |
| ---------- | ------------- | ------------- |
| Panjang    | 58 karakter   | 59 karakter   |
| Hash (hex) | `2b912f3d...` | `6ad62071...` |

Avalanche Effect:
- Perubahan input: 1 bit (dari '!' 0x21 menjadi 0x21? tidak tepat, sebenarnya penambahan karakter)
- Perubahan hash: ~100% (tidak ada segment yang sama)
- Ini membuktikan snowball effect pada fungsi hash kriptografi

Use Case:
- Verifikasi integritas file (tidak ada perubahan)
- Deteksi korupsi data (akibat transfer atau storage)
- Digital signature verification

### 4.4 Custom Caesar Decoder dengan Python One-Liner

Spesifikasi:
- Ciphertext: "Bjqhtrj Mtrj"
- Shift value: 5 (dekripsi)
- Direction: Left shift

Implementasi:

```bash
echo "Bjqhtrj Mtrj" | python3 -c "
cipher = input().strip()
result = ''
for char in cipher:
    if char.isalpha():
        if char.islower():
            result += chr((ord(char) - ord('a') - 5) % 26 + ord('a'))
        else:
            result += chr((ord(char) - ord('A') - 5) % 26 + ord('A'))
    else:
        result += char
print(f'Cipher: {cipher}')
print(f'Plain: {result}')
"
```

Output:
```
Cipher: Bjqhtrj Mtrj
Plain: Welcome Home
```

Penjelasan Algoritma:
1. `ord(char) - ord('A')` → konversi ke indeks 0-25
2. `- 5` → shift kiri untuk dekripsi
3. `% 26` → wrap-around jika negatif
4. `+ ord('A')` → konversi kembali ke ASCII

Fleksibilitas:
- Ubah `-5` menjadi `+5` untuk enkripsi
- Dapat di-extend untuk karakter non-alfabet
- Kompatibel dengan uppercase dan lowercase

## 5. Kesimpulan Teknis

| Teknik        | Kekuatan                       | Kelemahan                            | Use Case                   |
| ------------- | ------------------------------ | ------------------------------------ | -------------------------- |
| Caesar Cipher | Simplicity, 0 overhead         | Keyspace 26, frequency attack        | Edukasi, obfuscation       |
| AES-256-CBC   | Industry standard, 256-bit key | Overhead komputasi                   | Data storage, transmission |
| SHA-256       | Collision resistant, fast      | One-way (tidak bisa reverse)         | Integrity verification     |
| Steghide      | Covert communication           | File size unchanged, format terbatas | Data hiding, watermarking  |

Praktik Terbaik:
1. Jangan gunakan Caesar untuk data sensitif
2. Gunakan AES-256 dengan PBKDF2 untuk enkripsi data
3. Gunakan SHA-256 untuk checksum dan digital signature
4. Kombinasikan enkripsi + steganografi untuk defense-in-depth
5. Selalu verifikasi integritas dengan hashing setelah dekripsi

Trade-off:
- Keamanan vs Kinerja (AES vs Caesar)
- Visibility vs Kerahasiaan (Kriptografi vs Steganografi)
- Kompleksitas vs Maintainability (Custom vs Standard)

## Referensi dan Sumber Daya Tambahan
- [Quantum Hasher](https://ricalnet.my.id/tools/quantum-hasher) - Interactive hashing tool
- [Chantik: Encrypted Backup System with ChaCha20](https://ricalnet.my.id/tools/chantik)