---
title: Docker Compose pada Lingkungan AWS
description: Panduan implementasi Docker Compose untuk deployment aplikasi multi-container di Amazon Web Services.
categories: [Cloud & On-Premise, AWS]
tags: [docker, cloud computing, aws]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Docker Compose merupakan alat orkestrasi kontainer yang memungkinkan pengguna untuk mendefinisikan dan menjalankan aplikasi multi-container menggunakan file konfigurasi YAML. Dalam konteks cloud computing, ini menyederhanakan deployment aplikasi dengan mengelola dependensi antar kontainer secara terpusat.

## Prasyarat Konfigurasi
- Spesifikasi instance EC2 dan konfigurasi jaringan dapat dilihat pada [dokumentasi setup instance](https://ricaldocs.github.io/posts/cara-deploy-nginx-di-aws-ec2-menggunakan-docker/#konfigurasi-ec2-instance-yang-optimal)
- Konfigurasi dasar Docker environment dijelaskan dalam [panduan konfigurasi Docker](https://ricaldocs.github.io/posts/cara-deploy-nginx-di-aws-ec2-menggunakan-docker/#instalasi-docker-engine-dengan-konfigurasi-optimal)

## Implementasi Docker Compose

### Inisialisasi Direktori Projek
Membuat direktori kerja baru dan masuk ke dalamnya:
```bash
mkdir docker-compose-project && cd docker-compose-project
```

### Konfigurasi Docker Compose
Buat file konfigurasi utama dengan editor nano:
```bash
nano docker-compose.yml
```

> Format penamaan file Docker Compose bersifat case-sensitive. 
{: .prompt-warning}

> Rekomendasi penulisan standar adalah `docker-compose.yml` dengan huruf kecil dan hyphen.
{: .prompt-tip}

Salin konfigurasi berikut ke dalam file:
```yml
version: '3.7'
services:
  web:
    image: nginx:${NGINX_VERSION}
    ports:
      - "${PORT_NGINX}:80"
    volumes:
      - ./html:/usr/share/nginx/html
      - ./site-conf/site.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php
    networks:
      - app-network

  php:
    image: php:${PHP_VERSION}
    volumes:
      - ./html:/var/www/html
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

> **Analisis Konfigurasi:**
- **Version Schema 3.7:** Mendukung fitur jaringan dan volume terkelola
- **Service Dependency:** Kontainer web bergantung pada kontainer php melalui `depends_on`
- **Environment Variables:** Menggunakan variable expansion untuk fleksibilitas versi
- **Network Isolation:** Konfigurasi bridge network untuk komunikasi antar kontainer
{: .prompt-info}

### Konfigurasi Environment Variables
Buat file environment untuk mengelola konfigurasi dinamis:
```bash
nano .env
```

Konten file environment:
```ini
NGINX_VERSION=1.21-alpine
PORT_NGINX=8080
PHP_VERSION=7.4-fpm
```

Verifikasi file tersembunyi dengan:
```bash
ls -la
```

### Konfigurasi Nginx
Ambil konfigurasi virtual host dari repository GitHub:
```bash
git clone https://github.com/sendiahmadhidayat8/site-conf.git
```

## Deployment Aplikasi

### Menjalankan Stack
Jalankan services dalam mode detached:
```bash
docker compose up -d
```

### Struktur Aplikasi Web
Masuk ke direktori html dan buat file utama:
```bash
cd html/
touch index.php about.php contact.php style.css
```

#### index.php
```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Situs Docker Compose</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Deployment Berhasil dengan Docker Compose</h1>
        <nav>
            <a href="index.php">Beranda</a>
            <a href="about.php">Tentang</a>
            <a href="contact.php">Kontak</a>
        </nav>
    </header>
    <main>
        <h2>Halaman Utama</h2>
        <p>Aplikasi ini dijalankan menggunakan stack Nginx + PHP-FPM pada lingkungan Docker Compose</p>
        <?php echo '<p>Status PHP: ' . phpversion() . '</p>'; ?>
    </main>
    <footer>
        <p>&copy; 2024 Cloud Computing Lab</p>
    </footer>
</body>
</html>
```

#### about.php
```php
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>About Us</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header>
    <h1>About Us</h1>
    <nav>
      <a href="index.php">Home</a>
      <a href="about.php">About</a>
      <a href="contact.php">Contact</a>
    </nav>
  </header>
  <main>
    <h2>About Us</h2>
    <p>This page contains information about our website and team.</p>
  </main>
  <footer>
    <p>&copy; 2024 My Website</p>
  </footer>
</body>
</html>
```

#### contact.php
```php
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contact Us</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header>
    <h1>Contact Us</h1>
    <nav>
      <a href="index.php">Home</a>
      <a href="about.php">About</a>
      <a href="contact.php">Contact</a>
    </nav>
  </header>
  <main>
    <h2>Contact Information</h2>
    <form action="#" method="POST">
      <label for="name">Name:</label>
      <input type="text" id="name" name="name" required>
      <br><br>
      <label for="email">Email:</label>
      <input type="email" id="email" name="email" required>
      <br><br>
      <label for="message">Message:</label>
      <textarea id="message" name="message" rows="5" required></textarea>
      <br><br>
      <button type="submit">Submit</button>
    </form>
  </main>
  <footer>
    <p>&copy; 2024 My Website</p>
  </footer>
</body>
</html>
```

#### style.css
```css
:root {
  --primary-color: #2c3e50;
  --secondary-color: #34495e;
}

body {
  font-family: 'Segoe UI', system-ui, sans-serif;
  margin: 0;
  padding: 0;
  line-height: 1.6;
}

header {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  padding: 2rem 0;
  text-align: center;
}

nav a {
  color: #ecf0f1;
  margin: 0 15px;
  text-decoration: none;
  transition: color 0.3s;
}
```

## Validasi Deployment
1. Akses public IP instance AWS melalui browser
2. Verifikasi semua halaman dapat diakses
3. Periksa log kontainer dengan `docker compose logs`

## Keuntungan Implementasi
- Setiap service berjalan dalam kontainer terpisah
- Konfigurasi dapat digunakan di berbagai environment
- Mudah untuk menambah replika service

## Troubleshooting
- Pastikan security group mengizinkan akses ke port yang digunakan
- Verifikasi konfigurasi path volume mounting
- Periksa resource utilization instance EC2