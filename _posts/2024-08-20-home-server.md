---
title: Home Server
description: Bangun home server untuk mengoptimalkan keamanan dan privasi data pribadi. Dengan cara ini, kita dapat mengendalikan sepenuhnya penyimpanan dan akses informasi tanpa harus bergantung pada layanan cloud pihak ketiga yang dapat menjadi titik lemah.
categories: [Digital Independence, Cloud]
tags: [self-hosted, nextcloud]
author: rical
last_modified_at: 2026-06-01
---

> Dokumentasi ini telah kedaluwarsa dan tidak lagi mencerminkan praktik terbaik yang direkomendasikan. Untuk implementasi terkini, kami merujuk Anda pada artikel "[Panduan Lengkap Instalasi Nextcloud dengan Docker untuk Digital Independence](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-nextcloud-dengan-docker-untuk-digital-independence/)" sebagai acuan utama dalam proses deployment. Panduan tersebut memuat prosedur terbaru yang mencakup penerapan keamanan berlapis (layered security) serta penguatan prinsip kemandirian digital (digital sovereignty) dalam pengelolaan infrastruktur Anda.
{: .prompt-warning}

## Persiapan
Membangun infrastruktur data pribadi yang aman dan terkontrol merupakan tindakan proaktif yang krusial. Ini adalah langkah berani untuk melindungi informasi pribadi dari pengawasan luar dan memastikan bahwa hak digital tetap terjaga dengan baik.

### Memperbarui Sistem
Perbarui sistem dengan menjalankan perintah berikut:
```bash
sudo apt update && sudo apt upgrade -y
```

### Instalasi LAMPP
Instal dan konfigurasi LAMPP (Linux, Apache, MySQL, PHP), karena Nextcloud memerlukan server web dan basis data. Jalankan perintah berikut:
```bash
sudo apt install -y apache2 mariadb-server php libapache2-mod-php php-cgi php-mysqli php-pear php-phpseclib php-mysql php-mbstring php-zip php-gd php-curl php-common php-imagick php-gmp php-intl php-apcu
```

Unduh Nextcloud menggunakan `wget`:
```bash
wget https://download.nextcloud.com/server/releases/latest.zip
```

Ekstrak file yang telah diunduh dan pindahkan ke direktori `/var/www/html`{: .filepath}:
```bash
sudo unzip latest.zip -d /var/www/html
```

Akses direktori Nextcloud:
```bash
cd /var/www/html
```

Ubah kepemilikan direktori Nextcloud:
```bash
sudo chown -R www-data:www-data nextcloud
```

## Konfigurasi MySQL
Atur kata sandi root untuk basis data dengan menjalankan:
```bash
sudo mysql_secure_installation
```

Login ke MySQL menggunakan perintah berikut:
```bash
mysql -u root -p
```

### Membuat Basis Data dan Pengguna
Gantilah `username` dan `password` sesuai kebutuhan:
```sql
CREATE DATABASE home_server;
```
```sql
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
```

Izinkan pengguna untuk mengakses basis data `home_server`:
```sql
GRANT ALL PRIVILEGES ON home_server.* TO 'username'@'localhost';
```
```sql
FLUSH PRIVILEGES;
```
```sql
exit
```

## Konfigurasi Virtual Host
Buat konfigurasi virtual host dengan perintah berikut:
```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Isi berkas dengan konfigurasi berikut:
```apache
<VirtualHost *:80>
    ServerName localhost

    ServerAdmin admin@example.com
    DocumentRoot /var/www/html/nextcloud

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/nextcloud/>
        Options +FollowSymlinks
        AllowOverride All

        <IfModule mod_dav.c>
            Dav off
        </IfModule>

        SetEnv HOME /var/www/html/nextcloud
        SetEnv HTTP_HOME /var/www/html/nextcloud
    </Directory>
</VirtualHost>
```

Simpan berkas dan aktifkan konfigurasi:
```bash
sudo a2ensite nextcloud.conf && sudo systemctl restart apache2
```

## Konfigurasi Nextcloud
Buka browser dan akses [http://localhost/nextcloud](http://localhost/nextcloud).

> Petunjuk instalasi Nextcloud akan muncul. Selama proses instalasi, atur basis data MariaDB, akun admin, dan direktori penyimpanan data. Ikuti instruksi yang diberikan.
{: .prompt-tip}

Selesai. Sekarang, unduh aplikasi Nextcloud ke perangkat dan mulai mengunggah serta mengelola file secara mandiri.

> Selain untuk home server, [Nextcloud](https://nextcloud.com) juga menjadi fondasi utama untuk pengembangan [Unclouded](https://cloud.ricalnet.my.id) berkat sifatnya yang open source, memberikan kontrol penuh atas data, serta fitur keamanan tingkat tinggi.
{: .prompt-info}

Selanjutnya, jalankan perintah berikut untuk membuat crontab baru yang akan digunakan untuk menjalankan skrip crontab Nextcloud:
```bash
sudo crontab -u www-data -e
```

Parameter `-u www-data` digunakan karena server web Apache2 berjalan di atas pengguna tersebut.

Tambahkan konfigurasi berikut ke file crontab:
```
*/5  *  *  *  * php -f /var/www/html/nextcloud/cron.php
```
Simpan dan keluar dari file setelah selesai.

## Mengganti Alamat IP
Ubah `trusted domain` di berkas `config.php`{: .filepath}:
```bash
sudo nano /var/www/html/nextcloud/config/config.php
```
Isi dari berkas tersebut akan menampilkan seperti ini:
```php
$CONFIG = array (
    'instanceid' => 'ocfwe8edkz4v',
    'passwordsalt' => 'kf0eOXdbetRdsrobORxjkHefQoa/SJ',
    'secret' => 'nl6PNO/1Yhd1ZSefWBiPBLRhucTZLXuq7fqTn1FhCixufSqm',
    'trusted_domains' =>
    array (
        0 => 'masukkan alamat ip atau domain di sini',
    ),
);
```

Ubah `Virtual Host` dengan memasukkan perintah:
```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Pada bagian:
```apache
ServerName *masukkan ip address atau domain di sini*
```

> Untuk mengaktifkan protokol HTTPS, tambahkan baris berikut ke dalam konfigurasi server:
```apache
Redirect permanent / https://ip_address
```
{: .prompt-tip}

Simpan berkas dan aktifkan konfigurasi:
```bash
sudo a2ensite nextcloud.conf && sudo systemctl restart apache2
```

## Mengatasi Security & setup warnings

Sistem Nextcloud secara berkala melakukan pemeriksaan keamanan dan konfigurasi untuk memastikan lingkungan operasi yang optimal. Jika terdapat peringatan keamanan atau setup, sistem akan menampilkan notifikasi di halaman admin. 

> Untuk menyelesaikan permasalahan yang muncul, gunakan AI atau salin pesan kesalahan spesifik dan tempelkan ke mesin pencari browser untuk menemukan solusi terkini dari komunitas Nextcloud.
{: .prompt-tip}

![Panel Peringatan Keamanan Nextcloud](/assets/img/posts/2024-08-20-home-server/security-and-setup-warnings.png)

### Pemecahan Masalah Konfigurasi Dasar
Beberapa peringatan umum dapat diselesaikan dengan modifikasi file konfigurasi `config.php`{: .filepath}. Tambahkan atau perbarui parameter berikut sesuai kebutuhan:

```php
'maintenance' => false,
'background_jobs_mode' => 'cron', // Ubah dari 'ajax' ke 'cron' melalui pengaturan dasar admin
'maintenance_start' => '',
'maintenance_window_start' => 1,
'memcache.local' => '\OC\Memcache\APCu',
'memcache.locking' => '\OC\Memcache\APCu',
```

### Konfigurasi Header HSTS pada File .htaccess
Peringatan HSTS (HTTP Strict Transport Security) dapat diatasi dengan modifikasi file `.htaccess`{: .filepath} di direktori root Nextcloud. Lokasi file umumnya berada di:
- `/var/www/html/nextcloud/.htaccess`{: .filepath} (Apache pada Ubuntu/Debian)
- `/usr/share/nginx/nextcloud/.htaccess`{: .filepath} (Nginx)

#### Langkah Implementasi
1. Akses file `.htaccess`{: .filepath} menggunakan editor teks dengan hak akses `sudo`:
   ```bash
   sudo nano /var/www/nextcloud/.htaccess
   ```

2. Tambahkan konfigurasi HSTS dalam blok `<IfModule mod_headers.c>` setelah direktif `X-XSS-Protection`:
   ```apache
   Header onsuccess unset Strict-Transport-Security
   Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
   ```

3. Simpan perubahan dan restart layanan web:
   - Apache:
     ```bash
     sudo systemctl restart apache2
     ```
   - Nginx:
     ```bash
     sudo systemctl restart nginx
     ```

#### Contoh Struktur File `.htaccess`{: .filepath} yang Diperbarui
```apache
<IfModule mod_headers.c>
  <IfModule mod_env.c>
    ...
    Header onsuccess unset X-XSS-Protection
    Header always set X-XSS-Protection "1; mode=block"
    
    # HSTS Header Configuration
    Header onsuccess unset Strict-Transport-Scurity
    Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"
    ...
  </IfModule>
</IfModule>
```

#### Pertimbangan Keamanan
1. Pastikan sertifikat SSL/TLS telah terkofigurasi dengan benar sebelum mengaktifkan HSTS
2. Parameter `preload` bersifat permanen dan memerlukan komitmen jangka panjang
3. Untuk lingkungan dengan reverse proxy, konfigurasi HSTS mungkin perlu diterapkan di level proxy
4. Selalu buat backup file konfigurasi sebelum melakukan modifikasi

Dengan menerapkan konfigurasi ini, peringatan keamanan terkait HSTS pada Nextcloud seharusnya teratasi. 

> Untuk peringatan keamanan lainnya, selalu merujuk kepada [dokumentasi resmi Nextcloud](https://docs.nextcloud.com/) untuk panduan penyelesaian yang terperinci.
{: .prompt-tip}
