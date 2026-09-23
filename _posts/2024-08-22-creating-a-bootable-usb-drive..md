---
title: Creating and managing a bootable USB drive
description: Step-by-step pembuatan bootable USB via terminal dengan mitigasi risiko penghapusan disk. Termasuk prosedur konversi kembali ke media backup dan skrip otomasi rsync untuk manajemen data.
categories: [Cybersecurity]
tags: [usb drive, linux]
author: rical
last_modified_at: 2026-06-01
---

## Create
### Prasyarat
Sebelum memulai, pastikan:
1. Hak akses **root** atau izin `sudo`
2. File ISO distribusi Linux yang valid
3. USB flash drive dengan kapasitas memadai (minimal 4GB untuk kebanyakan distribusi)
4. Backup data penting pada USB target (proses akan menghapus seluruh konten)

### 1. Identifikasi Perangkat Storage
Eksekusi perintah berikut untuk enumerasi perangkat:
```bash
sudo fdisk -l
```
atau
```bash
lsblk
```
**Output kritis**:
```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 223.6G  0 disk                # Disk internal (HINDARI!)
├─sda1   8:1    0   476M  0 part /boot/efi
├─sda2   8:2    0   1.9G  0 part [SWAP]
└─sda3   8:3    0 221.2G  0 part /
sdb      8:16   0 931.5G  0 disk                # Disk internal (HINDARI!)
└─sdb1   8:17   0 931.5G  0 part /home
sdc      8:32   1 116.6G  0 disk                # Perangkat USB target
```
**Catatan Keamanan**:  
- Konfirmasi ukuran USB (`116.6G` pada contoh)  
- Catat identifier perangkat (`/dev/sdx` tanpa suffix numerik)

> Gantilah `sdx` dengan nama partisi USB.
{: .prompt-tip}

### 2. Unmount Partisi Aktif
Lepaskan semua mount point terkait USB:
```bash
sudo umount /dev/sdx*
```

### 3. Penulisan ISO dengan `dd`
Gunakan perintah berikut (ganti `file.iso` dan `/dev/sdx` sesuai konteks):
```bash
sudo dd if=~/path/to/file.iso of=/dev/sdx bs=4M status=progress oflag=sync conv=fsync
```

**Parameter Kunci**:

| Parameter         | Fungsi                                                        |
| ----------------- | ------------------------------------------------------------- |
| `bs=4M`           | Optimasi ukuran blok untuk throughput maksimal                |
| `status=progress` | Monitor real-time kecepatan transfer                          |
| `oflag=sync`      | Memastikan operasi tulis diselesaikan sebelum perintah keluar |
| `conv=fsync`      | Sinkronisasi metadata fisik setelah penulisan                 |

> Waktu proses bervariasi tergantung ukuran ISO dan kecepatan USB (biasanya 3-10 menit).
{: .prompt-info}

### 4. Eject Aman
Setelah selesai (terminal menampilkan statistik input/output):
```bash
sudo eject /dev/sdx
```
Cabut fisik USB setelah notifikasi sistem.

## Verifikasi Integritas (Opsional)
### Uji Konsistensi SHA256
1. Hitung checksum ISO asli:
   ```bash
   sha256sum ~/path/to/file.iso
   ```
   Contoh output: `a1b2c3d4...7890`

2. Verifikasi konten USB:
   ```bash
   sudo dd if=/dev/sdx bs=4M count=$(($(wc -c < ~/path/to/file.iso)/4194304 + 1)) 2>/dev/null | sha256sum
   ```
   
   > Bandingkan nilai hash kedua output. Nilai identik mengkonfirmasi bootable USB valid.
   {: .prompt-tip}

   > Pastikan untuk melakukan backup data penting sebelum melakukan langkah-langkah ini, karena semua data di USB akan terhapus.
   {: .prompt-info}

Setelah selesai, kita dapat menggunakan USB tersebut untuk booting ke sistem operasi yang akan digunakan.

## Mengembalikan USB ke Fungsi Penyimpanan Normal
Setelah selesai sebagai bootable device, ikuti langkah untuk menghapus partisi dan memformat USB sebagai media penyimpanan reguler.

### Langkah 1: Hapus Partisi Existing
1. Identifikasi kembali perangkat USB:
   ```bash
   sudo fdisk -l
   ```

2. Masuk mode interaktif `fdisk`:
   ```bash
   sudo fdisk /dev/sdx
   ```

3. Urutan perintah di `fdisk`:
   ```
   d    # Hapus partisi existing (ulangi jika ada multiple partition)
   w    # Tulis perubahan ke disk
   ```

### Langkah 2: Buat Partisi Baru
1. Buka kembali `fdisk`:
   ```bash
   sudo fdisk /dev/sdx
   ```

2. Urutan perintah:
   ```
   n    # Partisi baru
   p    # Tipe primary
   [Enter]  # Gunakan default sector
   [Enter]  # Gunakan default akhir partisi
   t    # Ubah tipe partisi
   b    # Pilih FAT32 (atau 7 untuk NTFS)
   w    # Tulis perubahan
   ```

### Langkah 3: Format sebagai Media Penyimpanan
- **FAT32** (kompatibel multi-sistem):
  ```bash
  sudo mkfs.vfat /dev/sdx1 -n BACKUP
  ```
- **exFAT** (dukungan file >4GB):
  ```bash
  sudo mkfs.exfat /dev/sdx1 -n BACKUP
  ```

## Penggunaan USB untuk Backup File
### Metode 1: Backup via Terminal
1. Mount USB ke direktori target:
   ```bash
   sudo mkdir /mnt/backup && sudo mount /dev/sdx1 /mnt/backup
   ```

2. Salin data (contoh backup direktori home):
   ```bash
   sudo rsync -avh --progress ~/Documents /mnt/backup/
   ```

3. Unmount aman:
   ```bash
   sudo umount /dev/sdx1 && sudo eject /dev/sdx
   ```

### Metode 2: Backup Otomatis dengan Script
Buat skrip `usb_backup.sh`:
```bash
#!/bin/bash
BACKUP_DEV="/dev/sdx1"
MOUNT_DIR="/mnt/backup"
TARGET_DIR="$MOUNT_DIR/$(date +%Y%m%d)_backup"

sudo mount $BACKUP_DEV $MOUNT_DIR || exit 1
mkdir -p "$TARGET_DIR" 
rsync -avh --delete ~/Documents "$TARGET_DIR" 
sudo umount $BACKUP_DEV && sudo eject $BACKUP_DEV
```
Setel eksekusi:
```bash
chmod +x usb_backup.sh
```
