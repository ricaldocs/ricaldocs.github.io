---
title: MySQL / MariaDB
description: Dokumentasi ini mencakup prosedur untuk membuat, menghapus, mengedit, dan mengelola database serta pengguna dalam MySQL dan MariaDB.
categories: [no categories]
tags: [mysql / mariadb]
author: rical
last_modified_at: 2026-06-01
---

## Mengelola Pengguna
### Membuat Pengguna Baru
Untuk membuat pengguna baru, gunakan perintah berikut:
```sql
CREATE USER 'nama_pengguna'@'localhost' IDENTIFIED BY 'password';
```

### Memberikan Izin kepada Pengguna
Untuk memberikan semua hak akses kepada pengguna pada *database* tertentu, gunakan perintah berikut:
```sql
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost' IDENTIFIED BY 'password';
```
Setelah memberikan izin, jalankan perintah berikut untuk menyegarkan hak akses:
```sql
FLUSH PRIVILEGES;
```

### Menghapus Pengguna
Untuk menghapus pengguna, gunakan perintah berikut:
```sql
DROP USER 'nama_pengguna'@'localhost';
```

### Mengubah Kata Sandi Pengguna
Untuk mengubah kata sandi pengguna, gunakan perintah berikut:
```sql
SET PASSWORD FOR 'nama_pengguna'@'localhost' = PASSWORD('password_baru');
```

### Menampilkan Pengguna yang Ada
Untuk menampilkan daftar pengguna yang ada, gunakan perintah berikut:
```sql
SELECT user, host FROM mysql.user;
```

## Mengelola Database
### Membuat Database
Untuk membuat *database* baru, gunakan perintah berikut:
```sql
CREATE DATABASE nama_database;
```

### Menggunakan Database
Untuk menggunakan *database* yang telah dibuat, gunakan perintah berikut:
```sql
USE nama_database;
```

### Menghapus Database
Untuk menghapus *database*, gunakan perintah berikut:
```sql
DROP DATABASE nama_database;
```

### Backup Database
Untuk melakukan *database backup*, gunakan perintah berikut:
```bash
mysqldump -u username -p nama_database > nama_database_backup.sql
```

### Restore Database
Untuk melakukan *database restore*, gunakan perintah berikut:
```bash
mysql -u username -p nama_database < nama_database_backup.sql
```

## Mengelola Tabel
### Membuat Tabel
Untuk membuat tabel baru, gunakan perintah berikut:
```sql
CREATE TABLE mahasiswa (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(255),
    umur INT,
    alamat VARCHAR(255)
);
```

### Menampilkan Semua Tabel
Untuk menampilkan semua tabel dalam *database*, gunakan perintah berikut:
```sql
SHOW TABLES;
```

### Menampilkan Struktur Tabel
Untuk menampilkan struktur tabel tertentu, gunakan perintah berikut:
```sql
DESCRIBE nama_tabel;
```

### Menambahkan Data ke Tabel
Untuk menambahkan data ke tabel, gunakan perintah berikut:
```sql
INSERT INTO mahasiswa (nama, umur, alamat) VALUES ('Budiono', 21, 'Jakarta');
```

### Mengambil Data dari Tabel
Untuk mengambil data dari tabel berdasarkan kriteria tertentu, gunakan perintah berikut:
```sql
SELECT * FROM mahasiswa WHERE umur > 20;
```

### Memperbarui Data Tabel
Untuk memperbarui data dalam tabel, gunakan perintah berikut:
```sql
UPDATE mahasiswa SET alamat='Bandung' WHERE id=1;
```

### Menghapus Data dari Tabel
Untuk menghapus data dari tabel, gunakan perintah berikut:
```sql
DELETE FROM mahasiswa WHERE id=1;
```

### Menghapus Tabel
Untuk menghapus tabel, gunakan perintah berikut:
```sql
DROP TABLE nama_tabel;
```