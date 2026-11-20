---
title: Mastering Self-Signed Certificates
description: Menghasilkan kunci privat dan sertifikat yang aman menggunakan OpenSSL, yang ideal untuk penggunaan internal dan pengujian.
categories: [Cybersecurity]
tags: [cryptography, nextcloud, self-signed certificates]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Sertifikat self-signed dapat menawarkan tingkat enkripsi yang setara dengan sertifikat yang dikeluarkan oleh Certificate Authority (CA) yang terverifikasi. Namun, karena sertifikat ini tidak dikeluarkan oleh CA yang terpercaya, identitas situs tidak dapat diverifikasi oleh pihak ketiga.

> Browser akan memberikan peringatan bahwa sertifikat self-signed tidak dapat dipercaya, dan pengguna akan melihat peringatan keamanan saat mengakses situs. Ini merupakan langkah pencegahan yang wajar karena sertifikat self-signed tidak diverifikasi oleh pihak ketiga.
{: .prompt-info}

> Meskipun sertifikat self-signed tidak terdaftar oleh CA yang terpercaya, enkripsi yang disediakannya tetap valid dan efektif. Sertifikat ini memastikan komunikasi antara server dan klien tetap terenkripsi dan tidak mudah disadap.
{: .prompt-info}

Sertifikat self-signed umumnya digunakan untuk keperluan internal, pengujian, atau dalam lingkungan di mana kepercayaan dan kontrol penuh terhadap sertifikat serta kunci dapat diterapkan.

> Untuk aplikasi publik atau situs web yang diakses oleh banyak pengguna, disarankan untuk menggunakan sertifikat yang diterbitkan oleh CA, karena menawarkan tingkat kepercayaan yang lebih luas dan pengelolaan yang lebih baik.
{: .prompt-tip}

## Membuat Sertifikat Self-Signed 
Aktifkan modul SSL dengan menggunakan perintah berikut:
```bash
sudo a2enmod ssl
```

Buat direktori untuk sertifikat. Sebagai contoh, kita akan menerapkannya di Nextcloud:
```bash
sudo mkdir /etc/ssl/nextcloud
```

### Menghasilkan Sertifikat dan Kunci Privat
Gunakan perintah berikut untuk menghasilkan sertifikat dan kunci privat:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/nextcloud/nextcloud.key -out /etc/ssl/nextcloud/nextcloud.crt
```
Perintah di atas akan membuat file `nextcloud.key`{: .filepath} dan `nextcloud.crt`{: .filepath} di dalam direktori `/etc/ssl/nextcloud`{: .filepath}.

Penjelasan parameter:
- `-x509` menunjukkan bahwa kita ingin membuat sertifikat self-signed, bukan Certificate Signing Request (CSR).
- `-nodes` menunjukkan bahwa private key tidak akan diproteksi dengan password.
- `-days 365` menentukan masa berlaku sertifikat selama 365 hari.
- `-newkey rsa:4096` membuat pasangan kunci baru dengan algoritma RSA dan panjang kunci 4096-bit.

Kemudian, buat file konfigurasi baru di `/etc/apache2/sites-available/nextcloud-ssl.conf`{: .filepath}:
```bash
sudo nano /etc/apache2/sites-available/nextcloud-ssl.conf
```

Isi file tersebut dengan konfigurasi berikut:
```apache
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

Selanjutnya, aktifkan konfigurasi SSL dan mulai ulang Apache dengan perintah berikut:
```bash
sudo a2ensite nextcloud-ssl && sudo systemctl restart apache2
```

## Menghapus Sertifikat Self-Signed
Untuk menghapus sertifikat self-signed, gunakan perintah berikut:
```bash
sudo rm -r /etc/ssl/nextcloud/nextcloud.key && sudo rm -r /etc/ssl/nextcloud/nextcloud.crt
```

Hapus direktori sertifikat:
```bash
sudo rmdir /etc/ssl/nextcloud
```

Hapus file konfigurasi:
```bash
sudo rm -r /etc/apache2/sites-available/nextcloud-ssl.conf
```

```bash
sudo a2dissite nextcloud-ssl
```

Mulai ulang Apache untuk menerapkan perubahan:
```bash
sudo systemctl restart apache2
```