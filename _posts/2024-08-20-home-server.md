---
title: Home Server
description: Bangun home server untuk mengoptimalkan keamanan dan privasi data pribadi. Dengan cara ini, kita dapat mengendalikan sepenuhnya penyimpanan dan akses informasi tanpa harus bergantung pada layanan cloud pihak ketiga yang dapat menjadi titik lemah.
categories: [Cybersecurity, Linux, rical_net, Privacy]
tags: [linux, rical_net, privacy, open source]
author: rical
---

Membangun infrastruktur data pribadi yang aman dan terkontrol menjadi tindakan proaktif yang krusial. Ini adalah langkah berani untuk melindungi informasi pribadi dari pengawasan luar dan memastikan bahwa hak digital tetap terjaga dengan baik.

## Persiapan

Perbarui sistem:
```bash
sudo apt update && sudo apt upgrade -y
```

Instal dan konfigurasi LAMPP (Linux, Apache, MySQL, PHP), karena Nextcloud memerlukan server web dan *database*.
### Install LAMPP

```bash
sudo apt install apache2 mariadb-server php php-curl php-cli php-mysql php-gd php-common php-xml php-json php-intl php-pear php-imagick php-dev php-common php-mbstring php-zip php-soap php-bz2 php-bcmath php-gmp php-apcu libmagickcore-dev php-redis php-memcached
``` 
Download Nextcloud dengan menggunakan `wget`.
```bash
wget https://download.nextcloud.com/server/releases/latest.zip
```

Ekstrak file yang sudah di-download dan pindah kan ke `/var/www/html`

```bash
sudo unzip latest.zip -d /var/www/html
```

```bash
cd /var/www/html
```

```bash
sudo chown -R www-data:www-data nextcloud
```

## Konfigurasi MySQL
Setel kata sandi root untuk *database*,

```bash
sudo mysql_secure_installation
```

Login ke MySQL dengan menggunakan perintah berikut:
```bash
mysql -u root -p
```

### Membuat *database* dan *user*
> Ganti *username* dan *password* sesuai kebutuhan.
{: .prompt-info } 

```bash
CREATE DATABASE home_server;
```
```bash
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
```

Izinkan *user* untuk mengakses *database* `home_server` .
```bash
GRANT ALL PRIVILEGES ON home_server.* TO 'username'@'localhost';
```

```bash
FLUSH PRIVILEGES;
```

```bash
exit
```

## Konfigurasi virtual host
Buat konfigurasi virtual host dengan menggunakan perintah berikut:

```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Kemudian isi berkas dengan konfigurasi sesuatu seperti ini:

```
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

Simpan berkan dan aktifkan konfigurasi:
```bash
sudo a2ensite nextcloud.conf && sudo systemctl restart apache2
```

## Konfigurasi Nextcloud
Buka browser dan akses `http://localhost/nextcloud`.

> Petunjuk instalasi Nextcloud akan muncul. Selama proses instalasi, atur *database* MariaDB, akun admin, dan direktori penyimpanan data. ikuti instruksi yang diberikan.
{: .prompt-tip}

Selesai. Sekarang, unduh aplikasi Nextcloud ke perangkat dan mulai meng-upload serta mengelola file secara mandiri.

> Selain untuk home server, [Nextcloud](https://nextcloud.com) juga menjadi fondasi utama untuk pengembangan [OnionCal](https://risnandapascal.github.io/onioncal.html) berkat sifatnya yang *open source*, memberikan kontrol penuh atas data, serta fitur keamanan tingkat tinggi.
{: .prompt-info}

Selanjutnya, jalankan perintah berikut untuk membuat crontab baru yang akan digunakan untuk menjalankan skrip crontab Nextcloud. Parameter `-u www-data` digunakan karena server web Apache2 berjalan di atas pengguna tersebut.
```bash
sudo crontab -u www-data -e
```
Tambahkan konfigurasi berikut ini ke file crontab:
```bash
*/5  *  *  *  * php -f /var/www/html/nextcloud/cron.php
```
Simpan dan keluar dari file setelah selesai.

## Mengganti IP Address
Ubah `trusted domain` di `config.php`:
```bash
sudo nano /var/www/html/nextcloud/config/config.php
```
Isi dari berkas tersebut akan menampilkan seperti ini:
```
$CONFIG = array (
'instanceid' => 'ocfwe8edkz4v',
'passwordsalt' => 'kf0eOXdbetRdsrobORxjkHefQoa/SJ',
'secret' => 'nl6PNO/1Yhd1ZSefWBiPBLRhucTZLXuq7fqTn1FhCixufSqm',
'trusted_domains' =>
array (
0 => 'masukkan alamat ip atau domain di sini',
),
```

Ubah `Virtual Host` dengan memasukkan perintah:
```bash
sudo nano /etc/apache2/sites-available/nextcloud.conf
```

Pada bagian: 
```
ServerName *masukkan ip address atau domain di sini*
```

Simpan berkas dan aktifkan konfigurasi:
```bash
sudo a2ensite nextcloud.conf && sudo systemctl restart apache2
```

## Referensi
- [ricalWiki](s://risnandapascal.github.io/ricalwiki.html)
