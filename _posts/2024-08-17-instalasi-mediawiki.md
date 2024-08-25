---
title: MediaWiki
description: Menggunakan MediaWiki untuk tujuan kolaborasi dan dokumentasi proyek.
categories: [Linux]
tags: [linux, wiki, open source]
author: rical
---

> Untuk menginstal <a href="https://www.mediawiki.org/wiki/MediaWiki" target="_blank">MediaWiki</a>, saya menyarankan penggunaan sistem operasi Ubuntu atau Debian untuk meminimalisir potensi masalah.
{: .prompt-tip }

## Instalasi

### Perbarui sistem:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean -y
```
### Instal LAMPP

```bash
sudo apt-get install apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-mbstring
```
Alternatif:

```bash
sudo apt-get install apache2 mariadb-server php php-mysql libapache2-mod-php php-xml php-mbstring
```
> Paket-paket ini tidak diperlukan tetapi mungkin berguna, tergantung pada penginstalannya: 
```bash
sudo apt-get install php-apcu php-intl imagemagick inkscape php-gd php-cli php-curl php-bcmath git
```
{: .prompt-info }


## Download MediaWiki
Pindah ke direktori `/var/www/html`

```bash
cd /var/www/html
```

Download dengan menggunakan `wget` atau kunjungi langsung situs [MediaWiki](https://www.mediawiki.org/wiki/Download).

```bash
wget https://releases.wikimedia.org/mediawiki/1.41/mediawiki-1.41.1.tar.gz
```

Ekstrak dengan menggunakan perintah:

```bash
tar -xvzf /tmp/mediawiki-*.tar.gz cd /tmp
```

Buat folder dengan nama wiki di `/var/www/html`

```bash
mdkir /var/www/html/wiki
```

Pindahkan folder yang sudah diekstrak

```bash
mv mediawiki-*/* /var/www/html/wiki
```

## Konfigurasi MySQL
### Buat username baru

```bash
sudo mysql -u root -p
```

```bash
CREATE USER 'mysql_username'@'localhost' IDENTIFIED BY 'masukkanpassword';
```

```bash
quit;
```

### Buat database baru

```bash
sudo mysql -u root -p
```

```bash
CREATE DATABASE my_wiki;
```

```bash
use my_wiki;
```

### Izinkan username untuk mengakses database

```bash
GRANT ALL PRIVILEGES ON my_wiki.* TO 'mysql_username'@'localhost';
```

```bash
FLUSH PRIVILEGES;
```

```bash
exit;
```

## Konfigurasi MediaWiki
Arahkan browser ke <a href="http://localhost/wiki" target="_blank">http://localhost/wiki</a> dan ikuti prosedur yang diberikan.

Mungkin akan ada keluhan bahwa ekstensi PHP seperti mbstring dan xml hilang meskipun telah menginstalnya. Silakan aktifkan secara manual dengan menggunakan: 

```bash
sudo phpenmod mbstring && sudo phpenmod xml && sudo systemctl restart apache2.service
```

> Gambaran umum untuk konfigurasinya mungkin seperti ini:
- Di halaman web, klik Please set up the wiki first.
- Pilih bahasa
- Pilih continue
- Sesuaikan konfigurasi seperti ini untuk terhubung ke database:
```bash
Database host: localhost
Database name: my_wiki
Databse table prefix: wiki_
Database username: mysql_username
Database password: masukkanpasssword
```
{: .prompt-tip }

Setelah konfigurasi selesai dan mengunduh file `LocalSettings.php`, masukkan perintah berikut: 

```bash
cd ~/Downloads
```

```bash
mv LocalSettings.php /var/www/html/wiki/
```
Selesai sudah seluruh konfigurasi MediaWiki, kemudian bisa diakses di <a href="http://localhost/wiki" target="_blank">http://localhost/wiki</a>

## Referensi
- <a href="https://risnandapascal.github.io/ricalwiki.html" target="_blank">ricalWiki: Instalasi MediaWiki</a>
- <a href="https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Debian_or_Ubuntu" target="_blank">Manual:Running MediaWiki on Debian or Ubuntu</a>





