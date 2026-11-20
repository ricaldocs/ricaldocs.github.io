---
title: Panduan Lengkap Instalasi VirtualBox di Debian/Ubuntu Menggunakan Repository Oracle
description: Dokumentasi teknis langkah demi langkah untuk menginstal VirtualBox pada sistem Debian dan Ubuntu. Mencakup penambahan repository resmi Oracle, penonaktifan modul KVM yang bentrok, hingga pemasangan Extension Pack agar mesin virtual berjalan optimal.
categories: [Cloud & On-Premise]
tags: [virtualbox, cloud computing, linux]
author: rical
last_modified_at: 2026-06-01
---

VirtualBox merupakan perangkat lunak virtualisasi lintas platform yang banyak digunakan. Untuk mendapatkan fitur terkini dan dukungan penuh, pengguna Linux disarankan memasang langsung dari repository resmi Oracle. Artikel ini memandu Anda melalui proses instalasi VirtualBox 7.2 pada Debian 11/12/13 atau Ubuntu 22.04/24.04/24.10, termasuk penanganan konflik dengan KVM dan pemasangan Extension Pack.

## Prasyarat
- Sistem Debian/Ubuntu dengan arsitektur `amd64`.
- Hak akses `sudo`.
- Koneksi internet untuk mengunduh paket dan kunci GPG.

## 1. Memasang Dependensi Wajib
Sebelum menginstal VirtualBox, pastikan kernel *headers* dan alat kompilasi tersedia agar modul kernel dapat dibangun dengan benar.
```bash
sudo apt -y install gcc make linux-headers-$(uname -r) dkms
```
- `linux-headers-$(uname -r)`: Menyediakan header kernel yang sesuai dengan versi kernel aktif.
- `dkms`: Memastikan modul VirtualBox otomatis dibangun ulang setiap kali kernel diperbarui.

## 2. Menonaktifkan Modul KVM (Opsional tapi Direkomendasikan)
KVM (Kernel-based Virtual Machine) menggunakan ekstensi virtualisasi perangkat keras yang sama dengan VirtualBox. Jika KVM aktif, VirtualBox mungkin gagal mengakses fitur akselerasi. Matikan modul KVM dengan:
```bash
sudo modprobe -r kvm_intel        # Untuk prosesor Intel
# atau
sudo modprobe -r kvm_amd          # Untuk prosesor AMD
```
Agar permanen, tambahkan modul ke blacklist:
```bash
echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist.conf
```
> Langkah ini hanya diperlukan jika Anda tidak berencana menggunakan KVM bersamaan dengan VirtualBox. Jika Anda memerlukan KVM untuk mesin virtual lain, lewati tahap ini dan pastikan tidak ada mesin KVM berjalan saat menggunakan VirtualBox.
{: .prompt-info}

## 3. Menambahkan Repository Oracle
Oracle menyediakan repository resmi untuk distribusi berbasis Debian. Identifikasi nama kode rilis Anda dan tambahkan baris ke `/etc/apt/sources.list`{: .filepath} atau buat file `.list` baru di `/etc/apt/sources.list.d/`{: .filepath}.

- Tentukan `<mydist>` sesuai sistem Anda.**
  - Debian 13: `trixie`
  - Debian 12: `bookworm`
  - Debian 11: `bullseye`
  - Ubuntu 24.10: `oracular`
  - Ubuntu 24.04: `noble`
  - Ubuntu 22.04: `jammy`

- Tambahkan repository.
    ```bash
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian <mydist> contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    ```
    Ganti `<mydist>` dengan nama kode yang sesuai, misalnya untuk trixie:
    ```bash
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian trixie contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
    ```

## 4. Mengimpor Kunci GPG Oracle
Agar paket dapat diverifikasi, unduh dan pasang kunci publik Oracle.
```bash
wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/oracle-virtualbox-2016.gpg
```
Perintah ini mengunduh kunci ASCII, mengonversinya ke format biner, dan menyimpannya di direktori keyring yang telah ditentukan di repository.

## 5. Memperbarui Indeks Paket
```bash
sudo apt update
```
Sekarang APT mengenali paket dari repository VirtualBox.

## 6. Mencari Versi VirtualBox yang Tersedia
```bash
sudo apt search ^virtualbox-
```
Perintah ini menampilkan semua paket dengan awalan `virtualbox-`. Anda akan melihat versi terbaru seperti `virtualbox-7.2`.

## 7. Menginstal VirtualBox
```bash
sudo apt install -y virtualbox-7.2
```
Paket ini akan memasang VirtualBox beserta dependensinya, lalu membangun modul kernel melalui DKMS.

## 8. Memverifikasi Versi Terpasang
```bash
VBoxManage -v
```
Output yang muncul (contoh: `7.2.8r173730`) menunjukkan VirtualBox telah terinstal dengan benar.

## 9. Memasang Extension Pack
Extension Pack menyediakan dukungan untuk perangkat USB 2.0/3.0, enkripsi disk, dan fitur lainnya.

- [Unduh Extension Pack](https://www.virtualbox.org/wiki/Downloads).
    Pastikan versi yang diunduh cocok dengan versi VirtualBox terpasang (lihat output `VBoxManage -v`). Contoh untuk versi 7.2.8:
    ```bash
    wget https://download.virtualbox.org/virtualbox/7.2.8/Oracle_VirtualBox_Extension_Pack-7.2.8.vbox-extpack
    ```

- Pasang Extension Pack.
    ```bash
    sudo VBoxManage extpack install Oracle_VirtualBox_Extension_Pack-7.2.8.vbox-extpack
    ```
    Anda akan diminta menyetujui lisensi Oracle. Setelah itu, Extension Pack langsung aktif.

## Penutup
VirtualBox kini telah terpasang lengkap dengan Extension Pack. Anda dapat mulai membuat dan menjalankan mesin virtual, baik melalui antarmuka grafis (`virtualbox`) maupun baris perintah (`VBoxManage`). Untuk memastikan modul kernel berfungsi, luncurkan VirtualBox dan periksa apakah tidak ada pesan kesalahan.

> Jika Anda sebelumnya menonaktifkan KVM dan ingin mengaktifkannya kembali, hapus baris `blacklist kvm_intel`{: .filepath} dari `/etc/modprobe.d/blacklist.conf`{: .filepath} lalu muat modul dengan `sudo modprobe kvm_intel`.
{: .prompt-tip}