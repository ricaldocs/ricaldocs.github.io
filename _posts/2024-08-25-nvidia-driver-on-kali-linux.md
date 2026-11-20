---
title: NVIDIA GPU Drivers on Kali Linux
description: Panduan lengkap instalasi driver NVIDIA pada Kali Linux GNOME. Cara konfigurasi NVIDIA Optimus, atasi konflik driver Nouveau, & verifikasi dengan nvidia-smi. Untuk keamanan & performa maksimal.
categories: [no categories]
tags: [linux, nvidia]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Driver NVIDIA merupakan komponen perangkat lunak penting yang memfasilitasi komunikasi antara sistem operasi dan perangkat keras grafis NVIDIA. Pada distribusi Linux seperti Kali Linux (sistem operasi khusus untuk pengujian penetrasi dan audit keamanan), instalasi driver NVIDIA memerlukan pendekatan khusus karena konflik potensial dengan driver oepn source Nouveau yang biasanya sudah terintegrasi dalam kernel Linux.

Panduan ini menjelaskan berbagai metode instalasi driver NVIDIA pada Kali Linux, termasuk melalui paket resmi dari NVIDIA dan melalui repositori Kali Linux, dengan pertimbangan khusus untuk sistem menggunakan teknologi NVIDIA Optimus yang banyak ditemukan pada laptop modern.

## Prasyarat Sistem

Sebelum memulai proses instalasi, pastikan sistem memenuhi persyaratan berikut:

- Kali Linux terinstal dengan lingkungan desktop GNOME dan GDM (GNOME Display Manager)
- Akses root atau hak administratif tersedia
- Koneksi internet stabil terpasang
- Minimal 2 GB ruang disk tersedia
- Pembaruan sistem terbaru telah diinstal
- GPU NVIDIA yang kompatibel (lihat daftar dukungan di [situs NVIDIA](https://www.nvidia.com/en-us/drivers/))

### Verifikasi Perangkat Keras

Untuk memastikan GPU NVIDIA terdeteksi dengan benar:

```bash
lspci -nn | grep -i nvidia
```

Contoh output:
```
01:00.0 3D controller [0302]: NVIDIA Corporation GM108M [GeForce 930MX] [10de:134e] (rev a2)
```

## Persiapan Sistem

### Pembaruan Sistem Lengkap

Memperbarui sistem merupakan langkah penting untuk memastikan kompatibilitas dan keamanan:

```bash
sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
```

### Instalasi Header Kernel

Header kernel diperlukan untuk kompilasi modul kernel NVIDIA:

```bash
sudo apt install -y linux-headers-$(uname -r)
```

### Instalasi Dependensi Build

Instal paket-paket yang diperlukan untuk kompilasi driver:

```bash
sudo apt install -y build-essential dkms libglvnd-dev pkg-config
```

## Menangani Masalah Booting

### Modifikasi Parameter Boot GRUB

Jika sistem mengalami masalah booting karena konflik dengan driver Nouveau:

1. Pada menu GRUB, pilih entri Kali Linux dan tekan `E`
2. Temukan parameter `quiet splash` dan ganti dengan `nouveau.modeset=0`
3. Tekan `Ctrl+X` atau `F10` untuk boot dengan parameter tersebut

## Menonaktifkan Driver Nouveau

### Blacklist Driver Nouveau

```bash
echo -e "blacklist nouveau\noptions nouveau modeset=0\nalias nouveau off" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
```

### Perbarui Initramfs

```bash
sudo update-initramfs -u && reboot
```

### Verifikasi Nouveau Dinonaktifkan

```bash
lsmod | grep -i nouveau
```

Jika perintah ini tidak menampilkan apa-apa, itu berarti driver nouveau telah berhasil dinonaktifkan.

## Metode Instalasi Driver

### 1. Instalasi dari Sumber NVIDIA Resmi (Beginner-friendly)

#### Identifikasi Model GPU

```bash
lspci
```

Output yang diharapkan:

```
01:00.0 3D controller: NVIDIA Corporation GM108M [GeForce 930MX] (rev a2) # Terdeteksi GeForce 930MX
```

#### Unduh Driver dari Situs NVIDIA

Kunjungi [situs web driver NVIDIA](https://www.nvidia.com/en-us/drivers/) dan pilih model GPU yang sesuai.

#### Persiapan Mode Terminal

Nonaktifkan antarmuka grafis sementara:

```bash
sudo systemctl set-default multi-user.target
```

```bash
sudo reboot
```

#### Jalankan Installer NVIDIA
Masuk ke akses root dengan menggunakan perintah `sudo -i`. Selanjutnya, cari file driver yang telah diunduh dan berikan izin eksekusi dengan menggunakan perintah:

```bash
chmod +x nama_file.run
```

Setelah diberikan izin untuk mengeksekusi, jalankan dengan perintah berikut:
```bash
./nama_file.run
```

#### Aktifkan Kembali Antarmuka Grafis

```bash
sudo systemctl set-default graphical.target
```

```bash
reboot
```

### 2. Instalasi dari Repositori Kali (Advanced User)

#### Instalasi Paket NVIDIA

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

Output menunjukkan: `PCI:1:0:0 `(setiap perangkat mungkin berbeda).

#### Konfigurasi NVIDIA Optimus

##### Prinsip Kerja Optimus

NVIDIA Optimus adalah teknologi yang memungkinkan sistem beralih secara dinamis antara GPU terintegrasi dan GPU diskrit untuk mengoptimalkan konsumsi daya dan kinerja.

##### Konfigurasi Manual Xorg

[Unduh](https://cloud.ricalnet.my.id/s/943Q4NCHL3KWyt8) atau buat file konfigurasi Xorg di `/etc/X11/xorg.conf`{: .filepath}:

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
[Unduh](https://cloud.ricalnet.my.id/s/ENYP99pxYRfcefq) atau buat file desktop autostart di `/etc/xdg/autostart/optimus.desktop`{: .filepath} dan `/usr/share/gdm/greeter/autostart/optimus.desktop`{: .filepath}:

```bash
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
```

## Verifikasi Instalasi
Periksa apakah semuanya berfungsi dengan baik dengan menggunakan perintah berikut:
```bash
sudo apt install -y mesa-utils
```

```bash
glxinfo | grep -i "direct rendering"
```

Hasilnya harus `direct rendering: Yes`

Jika driver NVIDIA terinstal dengan sukses, maka nama kartu grafis akan ditampilkan di bagian *about section* Kali Linux.

### Verifikasi Driver NVIDIA

```bash
nvidia-smi
```

Contoh output yang diharapkan:
```
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.82.07              Driver Version: 580.82.07      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce 930MX           Off |   00000000:01:00.0 Off |                  N/A |
| N/A   48C    P8            N/A  /  200W |       5MiB /   2048MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            1544      G   /usr/lib/xorg/Xorg                        2MiB |
+-----------------------------------------------------------------------------------------+
```

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