---
title: Membangun VoIP Server
description: Dapatkan kontrol penuh atas sistem komunikasi dengan panduan mendetail tentang instalasi dan konfigurasi server VoIP menggunakan Asterisk.
categories: [Cybersecurity, Linux, Privacy]
tags: [linux, privacy, open source]
author: rical
---

> Kita akan membangun server VoIP dengan memanfaatkan [Asterisk](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://www.asterisk.org/) pada sistem operasi [Linux Mint](https://www.linuxmint.com/download.php) (Panduan untuk Pemula) dan [Debian](https://www.debian.org/download) (Panduan untuk Pengguna Tingkat Lanjut). Terima kasih kepada [@inibim](https://discord.com/invite/nAVZkEwjYJ) atas pemecahan masalahnya.
{: .prompt-info}

## Beginner's Guide
### Instalasi server

Buka terminal di Linux Mint dan jalankan perintah berikut untuk memperbarui sistem:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

Kita memerlukan beberapa paket yang diperlukan untuk membangun Asterisk. Masukkan perintah berikut:

```bash
sudo apt install build-essential wget subversion && sudo apt install libncurses5-dev libssl-dev libxml2-dev
```

Instal Asterisk dari repositori Linux Mint:

```bash
sudo apt install -y asterisk
```

Periksa versi asterisk yang sudah terinstall dengan menggunakan perintah:

```bash
asterisk -V
```
#### Konfigurasi

> Sebelum melakukan konfigurasi, cadangkan terlebih dahulu file `sip.conf`, `extensions.conf`, dan  `voicemail.conf`. 
```bash
sudo mv /etc/asterisk/sip.conf /etc/asterisk/extensions.conf /etc/asterisk/voicemail.conf ~/Documents
```
Selanjutnya, buka dan hapus isi konfigurasi yang ada di `/etc/asterisk/sip.conf`, `/etc/asterisk/extensions.conf`, dan  `/etc/asterisk/voicemail.conf`. 
{: .prompt-tip }

File konfigurasi utama terletak di `/etc/asterisk`. Ubah konfigurasi pada file berikut: 
- `/etc/asterisk/asterisk.conf`. Ini adalah konfigurasi utama. Untuk saat ini, biarkan saja secara *default*.
- Masukkan konfigurasi ini ke `/etc/asterisk/sip.conf`:

> SIP (*Session Initiation Protocol*) adalah protokol komunikasi yang digunakan untuk mengelola dan mengatur sesi komunikasi, seperti panggilan suara dan video, di jaringan IP. Dalam konteks Asterisk, sebuah sistem telekomunikasi *open-source* yang sering digunakan sebagai PBX (*Private Branch Exchange*) dan sistem VoIP (*Voice over IP*), SIP memainkan peran penting. Beberapa fitur utama SIP yang ada di Asterisk meliputi:
 - [x] Pendaftaran dan Autentikasi
 - [x] Manajemen Panggilan
 - [x] Negosiasi Media
 - [x] Kompatibilitas
 - [x] Pengaturan Fitur
{: .prompt-info }

```
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

- Selanjutnya, masukkan konfigurasi ini ke `/etc/asterisk/extensions.conf`:

```
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

- Terakhir, masukkan konfigurasi berikut ke `/etc/asterisk/voicemail.conf`:

```
[main]
7001 => 7001

7002 => 7002
```

#### Mulai dan hentikan Asterisk
- Stop layanan:
```bash
sudo systemctl stop asterisk
```

- Mulai layanan:
```bash
sudo systemctl start asterisk
```

- Lihat status layanan:
```bash
sudo systemctl status asterisk
```

#### CLI Asterisk
Masuk ke antarmuka baris perintah Asterisk (CLI) dengan menggunakan perintah berikut:

```bash
sudo asterisk -rvv
```

Setelah masuk ke CLI Asterisk, gunakan perintah berikut untuk menampilkan daftar peer SIP yang dikonfigurasi dalam sistem Asterisk:

```bash
sip show peers
```

Pengaturan server telah selesai. Untuk menguji komunikasi antar klien, kita dapat menggunakan [Linphone](https://www.linphone.org/).

> Direkomendasikan untuk mengubah kata sandi, membatasi akses dengan menggunakan *firewall*, serta melakukan pemantauan log dan sistem secara teratur untuk mendeteksi aktivitas yang mencurigakan demi keamanan yang lebih kuat.
{: .prompt-tip}

## Advanced Users
Buka terminal dan jalankan perintah berikut untuk memperbarui sistem:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
```

Kita memerlukan beberapa paket yang diperlukan untuk membangun Asterisk. Masukkan perintah berikut:

```bash
sudo apt install build-essential wget subversion && sudo apt install libncurses5-dev libssl-dev libxml2-dev
```

Unduh versi terbaru Asterisk dari situs web resmi:

```bash
cd /usr/src
```

```bash
sudo wget https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz
```

```bash
sudo tar xvf asterisk-20-current.tar.gz
```

### Compile dan install Asterisk
> Ini membutuhkan waktu yang cukup lama, jadi siapkan kopi untuk santai terlebih dahulu.
{: .prompt-info }

```bash
cd asterisk asterisk-20*
```

```bash
sudo ./configure
```

```bash
sudo make menuselect
```

```bash
sudo make
```

```bash
sudo make isntall
```

```bash
sudo make samples
```

```bash
sudo make config
```

### Konfigurasi
Untuk melakukan konfigurasi, lihat konfigurasi pada bagian **Beginner's Guide**.

> Menyiapkan server VoIP menggunakan Asterisk pada Debian 12, diperlukan konfigurasi yang cermat. Namun, hasilnya adalah sistem komunikasi yang kuat dan fleksibel. 
{: .prompt-warning}

> Jika berencana untuk memperluas skala operasi atau memerlukan bantuan profesional, pertimbangkan untuk menyewa teknisi [DevOps](https://en.wikipedia.org/wiki/DevOps) jarak jauh yang memiliki pengalaman dalam infrastruktur VoIP.
{: .prompt-tip}

## Referensi
- [ricalWiki](s://risnandapascal.github.io/ricalwiki.html)
