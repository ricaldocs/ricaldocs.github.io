---
title: Membangun Sistem Auto-Resize Gambar dengan AWS Lambda dan S3
description: Pelajari cara membangun sistem resize gambar otomatis menggunakan AWS Lambda dan Amazon S3. Tutorial lengkap dengan konfigurasi IAM, environment variables, dan S3 triggers.
categories: [Cloud & On-Premise, AWS]
tags: [cloud computing, aws]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Dalam pengembangan aplikasi modern, kebutuhan untuk memproses gambar secara otomatis menjadi semakin penting. AWS Lambda menyediakan solusi serverless yang efisien untuk menangani tugas-tugas pemrosesan gambar seperti resize, konversi format, dan optimisasi. Artikel ini akan memandu Anda dalam membangun sistem auto-resize gambar menggunakan AWS Lambda dan Amazon S3.

## Arsitektur Sistem

Sistem yang akan dibangun terdiri dari tiga komponen utama:
1. **Amazon S3** sebagai penyimpanan gambar original dan thumbnail
2. **AWS Lambda** sebagai engine pemrosesan gambar
3. **IAM Roles** untuk mengatur hak akses dan keamanan

## Implementasi Langkah demi Langkah

### 1. Persiapan Amazon S3 Buckets

Pertama, buka konsol Amazon S3 dan buat dua bucket dengan konvensi penamaan yang jelas:

![Antarmuka Amazon S3](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-14-24.png>)

Buat dua bucket dengan nama berikut:
- `amazn-s3-demo-user-images-bucket` (untuk gambar original)
- `amazn-s3-demo-user-thumbnails-bucket` (untuk gambar hasil resize)
  ![Pembuatan Bucket S3](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-17-49.png>)
  
  > Penamaan bucket yang deskriptif memudahkan identifikasi tujuan masing-masing bucket dalam arsitektur sistem.
  {: .prompt-tip}

### 2. Upload Gambar Original

Upload file gambar ke bucket `amazn-s3-demo-user-images-bucket` untuk testing:

![Upload Gambar ke S3](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-20-47.png>)

Verifikasi dengan membuka objek tersebut:

![Gambar Original](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-22-00.png>)

### 3. Konfigurasi AWS Lambda Function

Buka layanan AWS Lambda dan buat fungsi baru:

![Buat Fungsi Lambda](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-23-57.png>)

Isi informasi dasar fungsi dengan konfigurasi berikut:
- **Runtime**: Node.js
- **Architecture**: x86_64

![Konfigurasi Dasar Lambda](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-25-18.png>)

### 4. Konfigurasi IAM Role

Klik **View the `nama_role` role on the IAM console** untuk mengatur hak akses:

![Navigasi ke IAM Console](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-27-23.png>)

Atur kebijakan akses untuk mengizinkan akses ke layanan yang diperlukan:
- **Amazon S3** (akses baca/tulis bucket)
- **AWS Lambda** (eksekusi fungsi)
- **CloudWatch Logs** (logging dan monitoring)

![Konfigurasi IAM Policies](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-29-16.png>)

> Prinsip least privilege harus diterapkan dengan hanya memberikan izin yang benar-benar diperlukan.
{: .prompt-tip}

### 5. Optimasi Konfigurasi Lambda

Setelah fungsi dibuat, pergi ke tab Configuration dan atur memory menjadi 512 MB:

![Konfigurasi Memory Lambda](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-37-56.png>)

> Pemrosesan gambar membutuhkan memory yang cukup besar. Konfigurasi 512 MB memberikan keseimbangan antara performa dan biaya.
{: .prompt-info}

### 6. Environment Variables

Pada bagian Environment Variables, atur variabel berikut:
- **Key**: `DEST_BUCKET`
- **Value**: `amazn-s3-demo-user-thumbnails-bucket`

![Environment Variables](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-41-03.png>)

> Environment variables memungkinkan konfigurasi dinamis tanpa mengubah kode, memudahkan deployment di berbagai environment.
{: .prompt-info}

### 7. Deployment Kode Fungsi

Pergi ke tab Code dan pilih `Upload from .zip file`:

![Upload Kode Lambda](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-43-15.png>)

Upload file `functions.zip` yang tersedia di [repository GitHub](https://github.com/ricalnet/image-resizer-lambda):

![Upload ZIP File](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-46-46.png>)

### 8. Testing Fungsi Lambda

Pergi ke tab Test dan atur event template menjadi `S3 Put`:

![Konfigurasi Test Event](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-49-03.png>)

Modifikasi test event dengan konfigurasi berikut:
```json
"name": "amazn-s3-demo-user-images-bucket"
"arn": "arn:aws:s3:::amazn-s3-demo-user-images-bucket"
"key": "HMDT.png"
```

![Modifikasi Test Event](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-53-17.png>)

Pastikan nilai `key` sesuai dengan nama gambar yang ada di bucket S3:

![Konfigurasi Key](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-55-48.png>)

Klik Test dan verifikasi output success:

```json
{
  "statusCode": 200,
  "body": "Successfully resized amazn-s3-demo-user-images-bucket/HMDT.png and uploaded to amazn-s3-demo-user-thumbnails-bucket/HMDT.png"
}
```

![Hasil Test Berhasil](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 21-58-26.png>)

### 9. Verifikasi Hasil Resize

Gambar yang telah di-resize akan muncul di bucket `amazn-s3-demo-user-thumbnails-bucket`:

![Gambar Hasil Resize di S3](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-01-10.png>)

Buka gambar untuk memverifikasi ukuran yang telah berubah:

![Verifikasi Gambar Resize](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-02-13.png>)

### 10. Konfigurasi Trigger Otomatis

Tambahkan trigger untuk mengotomasi proses resize:

![Tambah Trigger Lambda](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-05-05.png>)

Atur trigger configuration dengan memilih bucket sumber. Centang acknowledgment untuk recursive invocation: 

> Recursive invocation acknowledgment diperlukan untuk mencegah infinite loop ketika fungsi Lambda menulis kembali ke bucket yang sama.
{: .prompt-warning}

![Konfigurasi Trigger](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-06-43.png>)


![](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-07-57.png>)

### 11. Testing Sistem Lengkap

Sekarang, setiap upload gambar ke `amazn-s3-demo-user-images-bucket` akan secara otomatis memicu proses resize dan menyimpan hasilnya ke `amazn-s3-demo-user-thumbnails-bucket`:

![Sistem Auto-Resize Berjalan](<../assets/img/posts/cloud/amazon-lambda/Screenshot From 2025-11-30 22-10-36.png>)

## Kesimpulan

Sistem auto-resize gambar menggunakan AWS Lambda dan S3 yang telah dibangun memberikan solusi yang scalable dan cost-effective untuk pemrosesan gambar. Arsitektur serverless ini menghilangkan kebutuhan untuk mengelola server, secara otomatis menangani scaling, dan hanya membebankan biaya berdasarkan penggunaan aktual.

Keuntungan implementasi ini:
- **Otomasi penuh** proses resize gambar
- **Scalability** tanpa batas
- **Cost-effective** dengan model pembayaran per penggunaan
- **Integrasi native** antara layanan AWS

Sistem ini dapat dikembangkan lebih lanjut dengan menambahkan fitur seperti konversi format, optimisasi kualitas, atau integrasi dengan CDN untuk distribusi yang lebih efisien.