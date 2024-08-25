---
title: Mastering Self-Signed Certificates
description: Menghasilkan kunci privat dan sertifikat yang aman dengan OpenSSL, ideal untuk penggunaan internal dan pengujian.
categories: [Cybersecurity, Linux, Privacy]
tags: [cybersecurity, linux, privacy]
author: rical
---

## Pendahuluan
Sertifikat *self-signed* dapat menawarkan enkripsi yang setara dengan sertifikat dari *Certificate Authority* (CA) yang terverifikasi. Namun, karena sertifikat ini tidak dikeluarkan oleh CA yang terpercaya, identitas situs tidak bisa diverifikasi oleh pihak lain.

> Browser akan memperingatkan bahwa sertifikat *self-signed* tidak dapat dipercaya, dan kita akan melihat peringatan keamanan saat mengakses situs. Ini merupakan langkah pencegahan yang wajar karena sertifikat *self-signed* tidak diverifikasi oleh pihak ketiga.
{: .prompt-info }

> Meskipun sertifikat *self-signed* tidak terdaftar oleh CA yang terpercaya, enkripsi yang disediakannya tetap valid dan efektif. Sertifikat ini memastikan komunikasi antara server dan klien tetap terenkripsi dan tidak mudah disadap.
{: .prompt-info }

Sertifikat *self-signed* umumnya digunakan untuk keperluan *internal*, pengujian, atau dalam lingkungan di mana kepercayaan dan kontrol penuh terhadap sertifikat serta kunci bisa diterapkan. 

> Untuk aplikasi publik atau situs web yang diakses oleh banyak pengguna, menggunakan sertifikat yang diterbitkan oleh CA lebih disarankan karena menawarkan tingkat kepercayaan yang lebih luas dan pengelolaan yang lebih baik.
{: .prompt-tip }

## Membuat Sertifikat Self-Signed
Aktifkan modul ssl dengan menggunakan perintah:
```bash
sudo a2enmod ssl
```

Buat direktori untuk sertifikat. Sebagai contoh, kita akan menerapkannya di Nextcloud:
```bash
sudo mkdir /etc/ssl/nextcloud
```

### Generate Sertifikat dan Private Key
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/nextcloud/nextcloud.key -out /etc/ssl/nextcloud/nextcloud.crt
```
Perintah di atas akan membuat file `nextcloud.key` dan `nextcloud.crt` ke dalam direktori `/etc/ssl/nextcloud`.
>
- `-x509` mengindikasikan bahwa kita ingin membuat sertifikat self-signed, bukan *Certificate Signing Request* (CSR).
- `-nodes` menunjukkan bahwa *private key* tidak akan diproteksi dengan *password*.
- `days 365` menentukan masa berlaku sertifikat selama 365 hari.
- `-newkey rsa:4096` membuat pasangan kunci baru dengan algoritma RSA dan panjang kunci 4096-bit.
{: .prompt-info }

Kemudian, buat file konfigurasi baru di `/etc/apache2/sites-available/nextcloud-ssl.conf`:
```bash
sudo nano /etc/apache2/sites-available/nextcloud-ssl.conf
```

Isi dengan konfigurasi seperti ini:
```
<IfModule mod_ssl.c>
<VirtualHost *:443>
ServerAdmin admin@domain.com
DocumentRoot /var/www/html/nextcloud
ServerName *isi dengan ip address atau domain*

SSLEngine on
SSLCertificateFile /etc/ssl/nextcloud/nextcloud.crt
SSLCertificateKeyFile /etc/ssl/nextcloud/nextcloud.key

<Directory /var/www/html/nextcloud/>
    Options +FollowSymLinks
    AllowOverride All
    <IfModule mod_dav.c>
        Dav off
    </IfModule>
    <IfModule mod_authz_core.c>
        Require all granted
    </IfModule>
    <IfModule !mod_authz_core.c>
        Order allow,deny
        Allow from all
    </IfModule>
</Directory>

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
</IfModule>
```

Selanjutnya, aktifkan konfigurasi ssl dan mulai ulang apache:
```bash
sudo a2ensite nextcloud-ssl && sudo systemctl restart apache2
```

## Menghapus Sertifikat Self-Signed
```bash
sudo rm -r /etc/ssl/nextcloud/nextcloud.key && sudo rm -r /etc/ssl/nextcloud/nextcloud.crt
```

```bash
sudo rmdir /etc/ssl/nextcloud
```

```bash
sudo rm -r /etc/apache2/sites-available/nextcloud-ssl.conf
```

```bash
sudo a2dissite nextcloud-ssl
```

```bash
sudo systemctl restart apache2
```

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)