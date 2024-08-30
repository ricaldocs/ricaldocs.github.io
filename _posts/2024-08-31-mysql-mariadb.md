---
title: MySQL / MariaDB
description: Membuat database, menghapus database, mengedit database, mengelola database, dll.
categories: [Cybersecurity, Linux]
tags: [linux]
author: rical
---

## Mengelola Pengguna
### Membuat pengguna baru
```bash
CREATE USER 'nama_pengguna'@'localhost' IDENTIFIED BY 'password';
```

### Memberikan izin kepada pengguna
```bash
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost' IDENTIFIED BY 'password';
```

```bash
FLUSH PRIVILEGES;
```

### Menghapus pengguna
```bash
DROP USER 'nama_pengguna'@'localhost';
```

### Mengubah kata sandi pengguna
```bash
SET PASSWORD FOR 'nama_pengguna'@'localhost' = PASSWORD('password_baru');
``` 

### Menampilkan pengguna yang ada
```bash
SELECT user, host FROM mysql.user;
```

## Mengelola Database
### Membuat database
```bash
CREATE DATABASE nama_database;
```

### Menggunakan database
```bash
USE nama_database;
```

### Menghapus database
```bash
DROP DATABASE nama_database;
```
## Mengelola Tabel
### Membuat tabel
```
CREATE TABLE mahasiswa (
id INT AUTO_INCREMENT PRIMARY KEY,
nama VARCHAR(255),
umur INT,
alamat VARCHAR(255)
);
```

### Menampilkan semua tabel
```bash
SHOW TABLES;
```

### Menampilkan struktur tabel
```bash
DESCRIBE nama_tabel;
```

### Menambahkan data ke tabel
```bash
INSERT INTO mahasiswa (nama, umur, alamat) VALUES ('Budiono', 21, 'Jakarta');
```

### Mengambil data dari tabel
```bash
SELECT * FROM mahasiswa WHERE umur > 20;
```

### Memperbarui data tabel
```bash
UPDATE mahasiswa SET alamat='Bandung' WHERE id=1;
```

### Menghapus data dari tabel
```bash
DELETE FROM mahasiswa WHERE id=1;
```

### Menghapus tabel
```bash
DROP TABLE nama_tabel;
```

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)


