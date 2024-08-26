---
title: NVIDIA GPU Drivers on Kali Linux
description: Mengkonfigurasi driver NVIDIA dalam lingkungan desktop GNOME.
categories: [Cybersecurity, Linux]
tags: [linux]
author: rical
---

> Jika telah menginstal Kali Linux dengan **GNOME Display Manager (GDM)** dan berhasil melakukan booting serta login, lewati langkah kedua. Pastikan akses root telah diaktifkan di Kali Linux, lalu lanjutkan langsung ke langkah ketiga.
{: .prompt-tip }

## 1. Install Kali Linux
Untuk menginstal driver NVIDIA di Kali Linux, pastikan memilih GNOME sebagai lingkungan desktop saat tahap `Software Selection` selama proses instalasi.

Setelah instalasi Kali selesai, verifikasi manajer tampilan *default* dengan menjalankan perintah berikut di terminal:
```bash
cat /etc/X11/default-display-manager
```

### Perbarui Sistem
Perbarui sistem Kali dengan menggunakan perintah:
```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
```

## 2. Mengatasi Masalah Booting (jika diperlukan)
Langkah ini penting jika kita menghadapi masalah booting ke Kali Linux, seperti sistem yang berhenti atau membeku. Jika Kali Linux bisa booting dan login tanpa kendala, kita dapat melewati langkah ini.

Jika Kali Linux tidak bisa booting, kita perlu memodifikasi parameter boot melalui GRUB. Gantilah `quiet splash` dengan `nouveau.modeset=0` untuk mencegah pemuatan driver Nouveau.

Setelah menyalakan komputer, ketika layar GRUB Kali Linux muncul, pilih Kali Linux dari menu GRUB dan tekan `E`. Gantilah `quiet splash` dengan `nouveau.modeset=0` untuk menonaktifkan driver Nouveau, lalu tekan `F10` untuk melanjutkan booting.

Menerapkan langkah-langkah ini akan mengatasi masalah *loading* dan pembekuan saat booting di Kali Linux, memungkinkan Kali untuk booting secara normal.

## 3. Kernel Headers
Sebelum mulai, pastikan bahwa kita memiliki header kernel untuk kernel yang sedang aktif, untuk membangun modul kernel driver NVIDIA. Ketik perintah berikut:
```bash
sudo apt install -y linux-headers-$(uname -r)
```

Perintah ini akan secara otomatis menginstal paket header kernel yang diperlukan untuk kernel yang sedang digunakan.

## 4. Disable Nouveau
```bash
echo -e "blacklist nouveau\noptions nouveau modeset=0\nalias nouveau off" > /etc/modprobe.d/blacklist-nouveau.conf
```

```bash
sudo update-initramfs -u && reboot
```

Sekarang sistem akan *reboot* dan driver nouveau seharusnya sudah dinonaktifkan.

### Verifikasi Nouveau
```bash
lsmod | grep -i nouveau
```

Jika perintah ini tidak menampilkan apa-apa, itu berarti driver nouveau telah berhasil dinonaktifkan.

## 5. Instal NVIDIA GPU Drivers dari repositori Kali
```bash
sudo apt install -y nvidia-detect nvidia-driver nvidia-xconfig nvidia-cuda-toolkit
```
Setelah menginstal driver NVIDIA dari repsoitori Kali, mulai ulang perangkat dengan menggunakan perintah:

```bash
sudo reboot -f
```

Temukan `BusID` kartu NVIDIA:
```bash
nvidia-xconfig --query-gpu-info | grep 'BusID : ' | cut -d ' ' -f6
```

Output menunjukkan: `PCI:1:0:0` (setiap perangkat mungkin berbeda).

## 6. Konfigurasi Server Xorg
Sekarang kita akan membuat file `/etc/X11/xorg.conf` dengan BusID sesuai panduan NVIDIA. Unduh file `xorg.conf` dari [tautan ini](/assets/posts/xorg.zip) dan edit nilai BusID sesuai dengan Bus ID perangkat menggunakan editor teks apa pun. Setelah itu, simpan file `xorg.conf` di direktori `/etc/X11/`, atau kita dapat membuat file `xorg.conf` dengan teks berikut:
```
Section "ServerLayout"
Identifier "layout"
Screen 0 "nvidia"
Inactive "intel"
EndSection

Section "Device"
Identifier "nvidia"
Driver "nvidia"
BusID "PCI:1:0:0"
EndSection

Section "Screen"
Identifier "nvidia"
Device "nvidia"
Option "AllowEmptyInitialConfiguration"
EndSection

Section "Device"
Identifier "intel"
Driver "modesetting"
EndSection

Section "Screen"
Identifier "intel"
Device "intel"
EndSection
```

Sesuaikan nilai BusID dan simpan ke `/etc/X11/xorg.conf`.

## 7. Menyiapkan Konfigurasi Optimus
Sekarang, kita perlu membuat beberapa skrip sesuai dengan manajer tampilan yang digunakan. Karena di sini menggunakan **GDM** sebagai manajer tampilan di Kali Linux, buat dua file `optimus.desktop` di direktori berikut dengan konten sebagai berikut:
```
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
```

- Direktori 1: `/usr/share/gdm/greeter/autostart/optimus.desktop`
- Direktori 2: `/etc/xdg/autostart/optimus.desktop`

Kita juga dapat [mengunduh](/assets/posts/optimus.zip) file `optimus.desktop` untuk GDM dan menyalinnya ke kedua direktori berikut: `/usr/share/gdm/greeter/autostart/` dan `/etc/xdg/autostart/`.

## 8. Verifikasi
Periksa apakah semuanya berfungsi dengan baik dengan menggunakan perintah berikut:
```bash
sudo apt install -y mesa-utils
```

```bash
glxinfo | grep -i "direct rendering"
```

Hasilnya harus `direct rendering: Yes`

Jika driver NVIDIA terinstal dengan sukses, maka nama kartu grafis akan ditampilkan di bagian *about section* Kali Linux.

## Troubleshooting
Ikuti langkah-langkah ini jika mengalami kesalahan dan terjebak di layar boot, serta ingin menghapus driver NVIDIA dan membatalkan semua perubahan yang telah dilakukan sejauh ini.

Tekan `CTRL+ALT+F2` atau `CTRL+ALT+F3`, kemudian masuk dengan kata sandi.

Ketikkan perintah ini:
```bash
sudo apt remove --purge nvidia-*
```

```bash
sudo rm -rf /etc/X11/xorg.conf
```

```bash
sudo rm -rf /usr/share/gdm/greeter/autostart/optimus.desktop
```

```bash
sudo rm -rf /etc/xdg/autostart/optimus.desktop
```

## Referensi 
- [ricalWiki](https://risnandapascal.github.io/ricalwiki.html)
- [Kali Linux: Install NVIDIA GPU Drivers](https://www.kali.org/docs/general-use/install-nvidia-drivers-on-kali-linux/)


