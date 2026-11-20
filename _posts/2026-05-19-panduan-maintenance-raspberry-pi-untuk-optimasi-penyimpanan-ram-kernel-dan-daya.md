---
title: Panduan Maintenance Raspberry Pi untuk Optimasi Penyimpanan, RAM, Kernel, dan Daya
description: Pelajari cara maintenance Raspberry Pi secara menyeluruh. Bersihkan storage, hemat RAM, hapus kernel usang, dan cek konsumsi daya Pi 5 agar kinerja optimal dan sistem bebas lag.
categories: [Cloud & On-Premise, Raspberry Pi]
tags: [raspberry pi, linux]
author: rical
last_modified_at: 2026-06-01
---

Raspberry Pi sering diandalkan sebagai server kecil, perangkat IoT, atau desktop minimalis. Seiring waktu, ruang penyimpanan dan memori (RAM) bisa terasa penuh karena tumpukan cache paket, log sistem, kernel usang, dan proses yang tidak diperlukan. Dokumentasi ini akan memandu Anda membersihkan storage, mengosongkan RAM, dan menghapus kernel lama secara aman tanpa mengganggu sistem yang sedang berjalan. Semua langkah diuji pada Raspberry Pi OS (berbasis Debian) dan dapat diterapkan di turunan Debian lainnya.

---

## 1. Membersihkan Storage (Disk)

### A. Hapus Cache Paket APT
Setiap kali Anda menginstal atau memperbarui perangkat lunak, manajer paket APT menyimpan salinan paket `.deb` di `/var/cache/apt/archives`. Cache ini berguna jika Anda perlu menginstal ulang tanpa mengunduh lagi, tetapi dapat menyita ruang hingga ratusan megabita.
```bash
sudo apt clean        # Hapus semua file .deb dari cache
sudo apt autoremove   # Hapus dependensi yang tidak lagi dibutuhkan
```
Perintah pertama menghapus seluruh cache paket, sementara `autoremove` menyingkirkan pustaka yang dipasang otomatis sebagai dependensi namun sudah tidak diperlukan lagi. Aman dijalankan kapan saja.

### B. Hapus Paket Tidak Terpakai
Kadang paket dihapus tetapi menyisakan file konfigurasi. Untuk membersihkannya secara tuntas:
```bash
# Hapus paket beserta file konfigurasinya
sudo apt autoremove --purge

# Cari dan bersihkan paket dengan status 'rc' (residual config)
dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge
```
Baris kedua akan mendeteksi sisa konfigurasi dari paket yang sudah tidak terinstal, lalu menghapusnya sepenuhnya. Ini mengembalikan ruang yang mungkin tercecer di `/etc`.

### C. Bersihkan Log Lama
Log sistem terus bertambah. Anda bisa memangkasnya dengan aman.
```bash
# Periksa penggunaan ruang log
du -sh /var/log

# Hapus log yang sudah di-rotate (file .gz, .1, .old)
sudo rm -v /var/log/*.gz /var/log/*.1 /var/log/*.old

# Atau, jika menggunakan systemd-journald (standar di Raspberry Pi OS)
sudo journalctl --vacuum-time=2d   # Simpan log maksimal 2 hari
sudo journalctl --vacuum-size=50M  # Batasi ukuran total log 50 MB
```
Menghapus log lama hasil rotasi aman karena data yang sudah dikompres biasanya tidak diperlukan untuk debugging harian. Pendekatan `journalctl --vacuum-time` lebih rapi dan direkomendasikan untuk sistem yang memakai journald.

### D. Hapus Thumbnail & Sampah
File thumbnail dan tempat sampah pengguna bisa tumbuh tanpa disadari.
```bash
rm -rf ~/.cache/thumbnails/*
rm -rf ~/.local/share/Trash/*
```
Jika sistem memiliki banyak pengguna, Anda bisa menjalankan perintah serupa untuk setiap direktori home.

### E. Cari File Besar Tidak Terpakai
Untuk menemukan direktori atau file yang paling banyak memakan ruang:
```bash
# Tampilkan 20 direktori terbesar di root (tanpa mount lain)
sudo du -ahx / 2>/dev/null | sort -rh | head -20
```
Dari daftar tersebut Anda bisa memutuskan apa yang bisa dihapus. Alternatif yang lebih interaktif: `ncdu` (NCurses Disk Usage) dengan perintah `sudo ncdu -x /`.

### G. Hapus Docker/Podman (jika ada dan tidak terpakai)
Jika sebelumnya bereksperimen dengan kontainer, ruang bisa dibersihkan secara agresif.
```bash
docker system prune -a --volumes
```
Perintah ini menghapus **semua** kontainer yang berhenti, jaringan tidak terpakai, image menggantung, dan volume yatim. Pastikan tidak ada kontainer atau volume penting yang masih dibutuhkan.

---

## 2. Membersihkan RAM

### A. Lihat Penggunaan RAM Saat Ini
Sebelum membersihkan, catat kondisi awal.
```bash
free -h
```
Ini membantu Anda membandingkan sebelum dan sesudah pembersihan.

### B. Bersihkan Cache Memori (Aman)
Linux menggunakan memori yang tidak terpakai untuk menyimpan cache disk (page cache, dentries, inode) agar akses file lebih cepat. Cache ini akan dilepas otomatis saat aplikasi meminta memori, tetapi dapat dikosongkan secara manual tanpa risiko kehilangan data.
```bash
# Hapus pagecache saja
sync && echo 1 | sudo tee /proc/sys/vm/drop_caches

# Hapus dentries dan inodes
sync && echo 2 | sudo tee /proc/sys/vm/drop_caches

# Hapus pagecache, dentries, dan inodes (paling bersih)
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```
Perintah `sync` memastikan semua data tertulis ke disk sebelum cache dihapus. Data yang masih diperlukan akan dimuat ulang dari disk saat diakses kembali. Opsi `3` memberikan hasil paling bersih, tetapi pilih salah satu sesuai kebutuhan.

### C. Matikan Service Tidak Terpakai
Beberapa service bawaan mungkin tidak Anda perlukan.
```bash
# Daftar service yang sedang berjalan
systemctl list-units --type=service --state=running

# Hentikan dan nonaktifkan service (contoh: bluetooth)
sudo systemctl stop bluetooth
sudo systemctl disable bluetooth
```
Service yang sering tidak diperlukan pada Raspberry Pi headless:
- `bluetooth` – jika tidak menggunakan perangkat Bluetooth.
- `avahi-daemon` – mDNS/Zeroconf (biasanya untuk printer atau sharing musik).
- `cups` – layanan pencetakan.
- `triggerhappy` – menangani tombol input tambahan.

Nonaktifkan hanya service yang Anda yakin tidak akan dipakai.

### D. Identifikasi Proses Pemakan RAM
Gunakan `htop` untuk melihat proses dengan konsumsi memori tinggi secara real-time.
```bash
htop
```
Dari dalam `htop` Anda bisa mengurutkan berdasarkan kolom `%MEM`, lalu mengakhiri proses dengan `F9` (kill) atau langsung dari terminal dengan `kill [PID]` atau `pkill [nama-proses]`.

### E. Turunkan Alokasi GPU Memory
Jika Raspberry Pi dioperasikan tanpa monitor (headless), Anda bisa memangkas memori yang dialokasikan ke GPU.
```bash
sudo raspi-config
# Pilih Performance Options → GPU Memory → set ke 16 MB
```
Alternatif langsung: tambahkan/ubah baris `gpu_mem=16` di `/boot/config.txt`, lalu reboot. Perubahan ini membebaskan RAM untuk aplikasi.

### F. Gunakan zram (Opsional, lebih efisien)
`zram` membuat perangkat blok terkompresi di RAM, bertindak sebagai swap yang sangat cepat. Ini efektif menambah kapasitas memori virtual tanpa mengandalkan swap berbasis disk.
```bash
sudo apt install zram-tools
# Edit /etc/default/zramswap, atur PERCENT=50 (alokasi 50% RAM untuk zram)
sudo systemctl restart zramswap
```
Setelah diaktifkan, Anda akan melihat perangkat swap tambahan (misal `/dev/zram0`). Kernel akan otomatis menyimpan data terkompresi di sini saat RAM utama menipis.

---

## 3. Menghapus Kernel Lama

Pembaruan sistem sering kali memasang kernel baru tanpa menghapus yang lama. Kernel usang ini mengambil ruang di partisi boot dan direktori modul, sementara bootloader hanya memuat yang terbaru. Menghapusnya aman selama Anda **tidak menghapus kernel yang sedang aktif**.

### 1. Cek Kernel yang Sedang Berjalan
Identifikasi kernel aktif dan daftar kernel terinstal.
```bash
# Semua paket kernel yang terpasang
dpkg --list | grep linux-image

# Kernel yang sedang berjalan
uname -r
```
Output `uname -r` mungkin seperti `6.18.29-rpi-v8`. 

```
ii  linux-image-6.18.29+rpt-rpi-2712      1:6.18.29-1+rpt1                     arm64        Linux 6.18.29 for Raspberry Pi 2712, Raspberry Pi
ii  linux-image-6.18.29+rpt-rpi-v8        1:6.18.29-1+rpt1                     arm64        Linux 6.18.29 for Raspberry Pi v8, Raspberry Pi
ii  linux-image-rpi-2712                  1:6.18.29-1+rpt1                     arm64        Linux for Raspberry Pi 2712 (meta-package)
ii  linux-image-rpi-v8                    1:6.18.29-1+rpt1                     arm64        Linux for Raspberry Pi v8 (meta-package)
6.18.29+rpt-rpi-2712
```

> Jangan pernah menghapus kernel yang cocok dengan nama ini.
{: .prompt-danger}

### 2. Hapus Kernel Lama (Contoh 6.12.75)
Pada contoh ini kernel 6.12.75 ingin dihapus. Paket yang relevan biasanya berpasangan untuk arsitektur berbeda.
```bash
sudo apt purge linux-image-6.12.75+rpt-rpi-2712 linux-image-6.12.75+rpt-rpi-v8
```
> Gunakan `sudo apt autoremove --purge`. Perintah ini akan mendeteksi kernel yang tidak lagi dibutuhkan dan menghapusnya secara otomatis, termasuk header dan modul terkait.
{: .prompt-tip}

### 3. Bersihkan Dependensi & Konfigurasi Sisa
Setelah menghapus kernel, bersihkan dependensi yang mungkin tertinggal.
```bash
sudo apt autoremove --purge
sudo update-initramfs -u
```
`update-initramfs -u` akan memperbarui initramfs untuk kernel yang masih terinstal.

### 4. Bersihkan File Boot Kernel Lama
Kadang ada sisa file di `/boot` yang tidak terhapus oleh manajer paket.
```bash
ls /boot/*6.12.75*   # Lihat file kernel lama di /boot
sudo rm -v /boot/*6.12.75*   # Hapus jika ada
```

### 5. Update Bootloader (Opsional)
Untuk memastikan bootloader menggunakan firmware terbaru, khususnya pada Raspberry Pi 4/5.
```bash
sudo rpi-eeprom-update
```
Jika tersedia pembaruan, Anda dapat mengaplikasikannya dengan `sudo rpi-eeprom-update -a` lalu reboot.

**Reboot untuk memastikan semua berjalan normal:**
```bash
sudo reboot
```

---

## 4. Memantau Konsumsi Daya Raspberry Pi 5

Meskipun tidak secara langsung membersihkan sistem, memantau konsumsi daya penting untuk memastikan Raspberry Pi 5 berjalan stabil, terutama saat menggunakan perangkat eksternal seperti SSD atau HDD. Bagian ini menyajikan dua metode: perkiraan konsumsi internal lewat perangkat lunak, dan pengukuran total paling akurat menggunakan alat eksternal.

### A. Perkiraan Perangkat Lunak
PMIC (Power Management IC) pada Raspberry Pi 5 dapat memberikan estimasi konsumsi komponen internal. **Metode ini tidak menghitung daya yang disalurkan ke perangkat USB**, sehingga tidak mencerminkan beban SSD/HDD eksternal. Hasilnya adalah perkiraan, bukan pengukuran presisi.

```bash
vcgencmd pmic_read_adc
```
Contoh output:
```
 3V7_WL_SW_A current(0)=0.05465208A
   3V3_SYS_A current(1)=0.05270022A
   1V8_SYS_A current(2)=0.13467840A
  VDD_CORE_A current(7)=1.22341000A
  ...
```

**Menghitung perkiraan daya internal:**
- Daya setiap cabang = Tegangan (Volt) × Arus (Ampere) (tegangan tertera pada nama cabang, misal `3V7` berarti 3.7V, `1V8` = 1.8V, `VDD_CORE` = 0.9V).
- Jumlahkan daya dari semua 12 cabang yang ditampilkan.
- Sebagai koreksi kasar terhadap kehilangan daya di regulator, rumus empiris dari pengguna dapat digunakan:  
  `Perkiraan Daya Nyata ≈ (Hasil Penjumlahan Software) × 1.1451 + 0.5879`

Nilai ini hanya mewakili konsumsi board itu sendiri. Untuk total sistem termasuk periferal USB, gunakan metode selanjutnya.

### B. Pengukuran Hardware (Akurat & Direkomendasikan)
Untuk mengetahui **total daya sebenarnya** yang digunakan seluruh sistem (Pi 5 + SSD SATA + HDD eksternal, dll.), gunakan USB-C Power Meter. Alat ini memberikan pembacaan tegangan, arus, dan daya secara real-time.

**Peralatan:**
- USB-C Power Meter yang mendukung 5V (banyak tersedia di pasaran).
- Power supply resmi Raspberry Pi 5 (27W) agar kemampuan suplai mencukupi.

**Langkah-langkah:**
1. Colokkan power supply ke port **IN** pada USB meter.
2. Hubungkan kabel USB-C dari port **OUT** meter ke port daya Raspberry Pi 5.
3. Nyalakan Pi. Meter akan langsung menampilkan Watt (daya), Volt, dan Ampere.

**Interpretasi untuk beban eksternal:**
1. Catat daya saat idle (tanpa beban signifikan).
2. Pasang SSD/HDD eksternal, lalu jalankan operasi berat seperti penyalinan data besar atau akses bersamaan.
3. Selisih daya yang terukur adalah kontribusi tambahan dari perangkat USB Anda.

Kombinasikan pembacaan meter dengan perintah `vcgencmd pmic_read_adc` untuk membandingkan perkiraan internal vs. total nyata. Ini memberi wawasan berapa besar daya yang disalurkan ke bus USB.

### C. Mengecek Under-Voltage
Kekurangan tegangan (under-voltage) bisa menjadi biang ketidakstabilan, terutama saat HDD eksternal berputar. Raspberry Pi 5 mencatat kejadian ini.

```bash
vcgencmd get_throttled
```
- `throttled=0x0` → **tidak pernah terjadi under-voltage** (kondisi ideal).
- Jika hasilnya bukan `0x0`, sistem pernah atau sedang mengalami masalah daya. Detail kode dapat dicek di [dokumentasi resmi](https://www.raspberrypi.com/documentation/computers/os.html#get_throttled).

Mengawasi daya dan tegangan secara rutin membantu mencegah korupsi data dan memastikan masa pakai perangkat yang panjang, khususnya ketika Anda menambahkan penyimpanan eksternal pada Raspberry Pi 5.