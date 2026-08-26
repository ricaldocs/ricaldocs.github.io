---
title: Panduan Lengkap Membangun VoIP Server dengan Asterisk di Linux
description: Tutorial cara instalasi dan konfigurasi server VoIP sendiri menggunakan Asterisk. Pelajari langkah detail untuk Linux Mint (pemula) dan kompilasi dari source di Debian 12 (lanjutan), termasuk konfigurasi SIP, ekstensi, keamanan, dan troubleshooting. Raih kedaulatan teknologi komunikasi Anda!
categories: [Digital Independence, Telecommunications]
tags: [self-hosted, asterisk, linux]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Panduan ini bertujuan untuk membangun server VoIP dengan memanfaatkan [Asterisk](https://www.asterisk.org/) pada sistem operasi [Linux Mint](https://www.linuxmint.com/download.php) untuk pemula dan [Debian](https://www.debian.org/download) untuk pengguna tingkat lanjut. Ucapan terima kasih kepada [Gineng B. Pamungkas](https://astarajingga.github.io) atas kontribusinya dalam pemecahan masalah.

## Panduan untuk Pemula
### Instalasi Server
1. Buka terminal di Linux Mint dan jalankan perintah berikut untuk memperbarui sistem:
   ```bash
   sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
   ```

2. Instal paket yang diperlukan untuk membangun Asterisk:
   ```bash
   sudo apt install build-essential wget subversion && sudo apt install libncurses5-dev libssl-dev libxml2-dev
   ```

3. Instal Asterisk dari repositori Linux Mint:
   ```bash
   sudo apt install -y asterisk
   ```

4. Periksa versi Asterisk yang telah terinstal:
   ```bash
   asterisk -V
   ```

### Konfigurasi
> Sebelum melakukan konfigurasi, cadangkan file `sip.conf`, `extensions.conf`, dan `voicemail.conf`:
```bash
sudo mv /etc/asterisk/sip.conf /etc/asterisk/extensions.conf /etc/asterisk/voicemail.conf ~/Documents
```
Selanjutnya, buka dan hapus isi konfigurasi yang ada di:
- `/etc/asterisk/sip.conf`{: .filepath}
- `/etc/asterisk/extensions.conf`{: .filepath}
- `/etc/asterisk/voicemail.conf`{: .filepath}
{: .prompt-tip}

File konfigurasi utama terletak di `/etc/asterisk`{: .filepath}. Ubah konfigurasi pada file berikut:
- **`/etc/asterisk/asterisk.conf`{: .filepath}**: Ini adalah konfigurasi utama. Biarkan dalam pengaturan *default* untuk saat ini.
- Masukkan konfigurasi berikut ke dalam **`/etc/asterisk/sip.conf`{: .filepath}**:

> SIP (*Session Initiation Protocol*) adalah protokol komunikasi yang digunakan untuk mengelola dan mengatur sesi komunikasi, seperti panggilan suara dan video, di jaringan IP. Dalam konteks Asterisk, sebuah sistem telekomunikasi *open-source* yang sering digunakan sebagai PBX (*Private Branch Exchange*) dan sistem VoIP (*Voice over IP*), SIP memainkan peran penting. Beberapa fitur utama SIP yang ada di Asterisk meliputi:
 - [x] Pendaftaran dan Autentikasi
 - [x] Manajemen Panggilan
 - [x] Negosiasi Media
 - [x] Kompatibilitas
 - [x] Pengaturan Fitur
{: .prompt-info }

```ini
[general]
context=internal
allowguest=no
allowoverlap=no
bindport=5060
bindaddr=0.0.0.0
srvlookup=no
disallow=all
allow=ulaw
alwaysauthreject=yes
canreinvite=no
nat=yes
session-timers=refuse
localnet=192.168.100.220/255.255.255.0 #sesuaikan ip address

[7001]
type=friend
host=dynamic
secret=7001
context=internal

[7002]
type=friend
host=dynamic
secret=7002
context=internal
```

- Selanjutnya, masukkan konfigurasi ini ke dalam **`/etc/asterisk/extensions.conf`{: .filepath}**:

```ini
[internal]
exten => 7001,1,Answer()
exten => 7001,2,Dial(SIP/7001,60)
exten => 7001,3,Playback(vm-nobodyavail)
exten => 7001,4,VoiceMail(7001@main)
exten => 7001,5,Hangup()

exten => 7002,1,Answer()
exten => 7002,2,Dial(SIP/7002,60)
exten => 7002,3,Playback(vm-nobodyavail)
exten => 7002,4,VoiceMail(7001@main)
exten => 7002,5,Hangup()

exten => 8001,1,VoicemailMain(7001@main)
exten => 8001,2,Hangup()

exten => 8002,1,VoicemailMain(7002@main)
exten => 8002,2,Hangup()
```

- Terakhir, masukkan konfigurasi berikut ke dalam **`/etc/asterisk/voicemail.conf`{: .filepath}**:

```ini
[main]
7001 => 7001
7002 => 7002
```

### Mengelola Layanan Asterisk
- Untuk menghentikan layanan:
  ```bash
  sudo systemctl stop asterisk
  ```

- Untuk memulai layanan:
  ```bash
  sudo systemctl start asterisk
  ```

- Untuk melihat status layanan:
  ```bash
  sudo systemctl status asterisk
  ```

### Antarmuka Baris Perintah Asterisk (CLI)
Masuk ke antarmuka baris perintah Asterisk (CLI) dengan menggunakan perintah berikut:
```bash
sudo asterisk -rvvvv
```

Setelah masuk ke CLI Asterisk, gunakan perintah berikut untuk menampilkan daftar peer SIP yang telah dikonfigurasi dalam sistem Asterisk:
```bash
sip show peers
```

Pengaturan server telah selesai. Untuk menguji komunikasi antar klien, disarankan untuk menggunakan [Linphone](https://www.linphone.org/).

> Direkomendasikan untuk mengubah kata sandi, membatasi akses menggunakan *firewall*, serta melakukan pemantauan log dan sistem secara teratur untuk mendeteksi aktivitas yang mencurigakan demi keamanan yang lebih kuat.
{: .prompt-tip}

## Panduan untuk Pengguna Tingkat Lanjut
### Langkah-langkah Instalasi
#### 1. Memperbarui Sistem
Buka terminal dan jalankan perintah berikut untuk memperbarui sistem:
```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

#### 2. Menginstal Paket yang Diperlukan
Instal paket-paket yang diperlukan untuk membangun Asterisk dengan perintah berikut:
```bash
sudo apt install -y build-essential wget subversion libncurses5-dev libssl-dev libxml2-dev libsqlite3-dev uuid-dev libjansson-dev libedit-dev
```

> Uraian dependensi:
- **build-essential**: Paket ini mencakup alat dasar yang diperlukan untuk mengkompilasi perangkat lunak dari sumber, termasuk kompiler dan pustaka dasar.
- **wget**: Utilitas untuk mengunduh file dari internet, berguna untuk memperoleh kode sumber Asterisk atau dependensi lainnya.
- **subversion**: Sistem kontrol versi yang digunakan untuk mengelola perubahan pada kode sumber, sering digunakan untuk mengunduh versi tertentu dari Asterisk.
- **libncurses5-dev**: Pustaka yang mendukung pembuatan antarmuka pengguna berbasis teks, digunakan oleh Asterisk untuk antarmuka pengguna berbasis terminal.
- **libssl-dev**: Pustaka yang menyediakan dukungan untuk *secure sockets sayer* (SSL) dan *transport layer security* (TLS), penting untuk keamanan komunikasi dalam Asterisk.
- **libxml2-dev**: Pustaka yang digunakan untuk memproses XML, format yang digunakan oleh Asterisk untuk konfigurasi dan pengaturan.
- **libsqlite3-dev**: Pustaka yang menyediakan dukungan untuk SQLite, sebuah *database* ringan yang dapat digunakan oleh Asterisk untuk penyimpanan data.
- **uuid-dev**: Pustaka yang digunakan untuk menghasilkan *universally unique identifiers* (UUID), sering digunakan dalam aplikasi untuk mengidentifikasi objek secara unik.
- **libjansson-dev**: Pustaka yang mendukung manipulasi data dalam format JSON.
- **libedit-dev**: Pustaka yang menyediakan antarmuka pengeditan baris perintah, berguna untuk interaksi pengguna di terminal.
{: .prompt-info}

>
Untuk menghindari potensi konflik, disarankan untuk menghapus AppArmor, yang dapat mengganggu operasi Asterisk:
```bash
sudo systemctl stop apparmor && sudo apt remove -y apparmor
```
{: .prompt-tip}

#### 3. Mengunduh Asterisk
Unduh versi terbaru Asterisk dari situs web resmi dengan perintah berikut:
```bash
cd /usr/src && sudo wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-22-current.tar.gz
```

#### 4. Mengekstrak File
Ekstrak file yang telah diunduh dengan perintah berikut:
```bash
sudo tar -xvf asterisk-22-current.tar.gz
```

#### 5. Masuk ke Direktori Asterisk
Masuk ke direktori Asterisk yang telah diekstrak:
```bash
cd asterisk-22*
```

### Kompilasi Asterisk
> Kompilasi Asterisk memungkinkan pengguna untuk menyesuaikan instalasi sesuai dengan kebutuhan spesifik. Proses ini mungkin memakan waktu cukup lama, sehingga disarankan untuk menyiapkan kopi terlebih dahulu sambil menunggu.
{: .prompt-info}

#### 1. Menjalankan Konfigurasi
Jalankan perintah berikut untuk memulai proses konfigurasi:
```bash
sudo ./configure
```
Perintah ini akan memeriksa sistem untuk memastikan bahwa pustaka yang diperlukan tersedia dan menyiapkan lingkungan build.

#### 2. Memilih Opsi yang Diinginkan
Setelah konfigurasi selesai, pilih opsi yang diinginkan dengan menampilkan menu:
```bash
sudo make menuselect
```

> Alat `menuselect` membuka antarmuka interaktif di mana pengguna dapat memilih modul dan fitur yang ingin disertakan dalam instalasi Asterisk. Luangkan waktu untuk menjelajahi opsi yang ada, serta mengaktifkan atau menonaktifkan fitur berdasarkan kebutuhan.
{: .prompt-info}

> Area kunci yang perlu dipertimbangkan:
- **Channel Drivers**: Aktifkan SIP, PJSIP, atau keduanya sesuai dengan kebutuhan.
- **Codec Translators**: Pilih codec audio yang akan digunakan.
- **Resource Modules**: Pilih fungsionalitas tambahan seperti penjadwalan atau integrasi LDAP.
- **Add-ons**: Tentukan fitur tambahan seperti perekaman panggilan atau musik saat menunggu.
{: .prompt-tip}

Setelah membuat pilihan, simpan dan keluar dari `menuselect`.

#### 3. Mengompilasi Asterisk
Setelah memilih opsi, kompilasi Asterisk dengan perintah berikut:
```bash
sudo make
```
Proses ini mungkin memakan waktu beberapa menit, tergantung pada kinerja sistem dan modul yang telah dipilih.

### Instalasi Asterisk
Setelah proses kompilasi selesai, lanjutkan dengan langkah-langkah berikut untuk menginstal Asterisk:

1. Instal Asterisk dengan perintah:
   ```bash
   sudo make install
   ```

2. Instal contoh konfigurasi:
   ```bash
   sudo make samples
   ```

3. Buat konfigurasi sistem:
   ```bash
   sudo make config
   ```

> - **make install**: Perintah ini digunakan untuk menginstal biner dan pustaka Asterisk yang telah dikompilasi.
- **make samples**: Perintah ini akan membuat file konfigurasi contoh yang disimpan di direktori `/etc/asterisk`{: .filepath}.
- **make config**: Perintah ini mengatur skrip inisialisasi untuk memfasilitasi *startup* otomatis Asterisk.
{: .prompt-info}

File konfigurasi contoh, terutama `sip.conf`{: .filepath} dan `extensions.conf`{: .filepath}, memberikan titik awal untuk pengaturan Asterisk. Meskipun file-file ini tidak cocok untuk digunakan dalam lingkungan produksi tanpa modifikasi, mereka menawarkan contoh dan template yang berharga untuk konfigurasi.

### Konfigurasi Asterisk
Keamanan dan integrasi sistem yang tepat sangat penting untuk setiap instalasi Asterisk. Konfigurasi yang benar memastikan bahwa Asterisk dapat beroperasi dengan efisien dan aman. Berikut adalah langkah-langkah untuk mengatur pengguna dan grup khusus untuk menjalankan Asterisk.

#### 1. Membuat Grup Asterisk
Untuk memulai, buat grup baru bernama "asterisk" dengan perintah berikut:
```bash
sudo groupadd asterisk
```

#### 2. Membuat Pengguna Asterisk
Selanjutnya, buat pengguna baru bernama "asterisk" yang akan menjalankan proses Asterisk:
```bash
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
```

#### 3. Mengubah Kepemilikan Direktori Asterisk
Ubah kepemilikan direktori yang terkait dengan Asterisk agar dimiliki oleh pengguna dan grup "asterisk":
```bash
sudo chown -R asterisk:asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib/asterisk
```

Setelah mengubah kepemilikan, konfigurasikan Asterisk untuk berjalan sebagai pengguna baru dengan mengedit file `/etc/default/asterisk`{: .filepath}:
```bash
sudo nano /etc/default/asterisk
```

Tambahkan atau modifikasi baris berikut dalam file tersebut:
```
AST_USER="asterisk"
AST_GROUP="asterisk"
```

### Konfigurasi SIP
Selanjutnya, atur konfigurasi SIP dengan mengedit file berikut:
- `/etc/asterisk/sip.conf`{: .filepath}
- `/etc/asterisk/extensions.conf`{: .filepath}
- `/etc/asterisk/voicemail.conf`{: .filepath}

Untuk melanjutkan konfigurasi, silakan merujuk pada [panduan ini](https://docs.ricalnet.my.id/posts/membangun-voip-server/#konfigurasi). 

### Pengujian Instalasi Asterisk
Setelah konfigurasi Asterisk selesai, langkah selanjutnya adalah memulai Asterisk dan memverifikasi operasinya. Proses ini penting untuk memastikan bahwa sistem berfungsi dengan baik dan siap digunakan.

#### 1. Memulai Asterisk
Untuk memulai Asterisk, jalankan perintah berikut:
```bash
sudo systemctl enable asterisk.service && sudo systemctl start asterisk.service
```

#### 2. Memeriksa Status Layanan
Setelah Asterisk dimulai, periksa status layanan untuk memastikan bahwa Asterisk berjalan dengan baik:
```bash
sudo systemctl status asterisk.service
```
Output yang ditampilkan seharusnya menunjukkan bahwa Asterisk aktif dan berjalan.

#### 3. Mengakses Antarmuka Baris Perintah Asterisk (CLI)
Untuk berinteraksi langsung dengan Asterisk, akses Antarmuka Baris Perintah Asterisk (CLI) dengan perintah berikut:
```bash
sudo asterisk -rvvvv
```

> Flag `-rvvvv` memungkinkan koneksi jarak jauh dengan tingkat verbosity maksimum. Dalam CLI, pengguna dapat memantau operasi Asterisk secara real-time dan mengeluarkan perintah.
{: .prompt-info}

#### 4. Pengujian Fungsi Dasar
Sebagai langkah pengujian fungsi dasar, pengguna dapat menggunakan klien SIP atau [softphone](https://en.wikipedia.org/wiki/Softphone) untuk mendaftar dengan ekstensi yang telah dibuat (misalnya, 1000) dan melakukan panggilan percobaan.

### Masalah Umum dan Pemecahan Masalah
> Meskipun instalasi Asterisk telah dilakukan dengan hati-hati, pengguna mungkin akan menemui beberapa masalah.
{: .prompt-warning}

#### Masalah Umum dan Solusinya
Berikut adalah beberapa masalah umum yang sering terjadi beserta solusinya.

- **Dependensi yang Hilang**: 
  Jika mengalami kesalahan terkait pustaka yang hilang, gunakan perintah berikut untuk mencari dan menginstal paket yang diperlukan:
  ```bash
  apt search <nama_paket>
  ```

- **Masalah Izin**: 
  Pastikan pengguna Asterisk memiliki izin yang tepat pada semua direktori dan file yang relevan. Anda dapat memeriksa dan mengubah izin dengan perintah `chown` dan `chmod`.

- **Kegagalan Registrasi SIP**: 
  Periksa pengaturan firewall dan pastikan bahwa port UDP 5060 terbuka untuk lalu lintas SIP. Gunakan perintah seperti `ufw allow 5060/udp` untuk mengizinkan akses.

- **Masalah Audio**: 
  Verifikasi bahwa modul codec yang diperlukan telah dimuat dan bahwa jaringan mengizinkan lalu lintas RTP, yang biasanya terjadi pada port UDP 10000-20000.

#### Proses Debugging
Untuk proses debugging, log Asterisk sangat berharga. Pantau log tersebut secara real-time dengan menggunakan perintah berikut:
```bash
sudo tail -f /var/log/asterisk/messages
```
Perintah ini akan menampilkan entri log saat terjadi, membantu mengidentifikasi masalah yang muncul.

> Menyiapkan server VoIP menggunakan Asterisk pada Debian 12 memerlukan konfigurasi yang cermat. Namun, hasilnya adalah sistem komunikasi yang kuat dan fleksibel.
{: .prompt-info}

> Jika berencana untuk memperluas skala operasi atau memerlukan bantuan profesional, pertimbangkan untuk menyewa teknisi [DevOps](https://en.wikipedia.org/wiki/DevOps) jarak jauh yang memiliki pengalaman dalam infrastruktur VoIP.
{: .prompt-tip}

## Pranala Luar
- [Asterisk](https://www.asterisk.org/)
