---
title: Daftar Perintah Lengkap ADB dan Fastboot
description: Panduan lengkap perintah ADB dan Fastboot untuk developer Android. Pelajari cara flashing, debugging, backup, restore, dan troubleshooting perangkat Android dengan tutorial step-by-step termasuk restore kunci ADB dari Linux via TWRP.
categories: [Digital Independence, Android]
tags: [android]
author: rical
last_modified_at: 2026-06-01
---

## Perintah ADB

### Manajemen Perangkat dan Koneksi

| Perintah                           | Deskripsi                              | Opsi/Penggunaan                |
| ---------------------------------- | -------------------------------------- | ------------------------------ |
| `adb devices`                      | Menampilkan daftar perangkat terhubung | `-l`: Detail lengkap perangkat |
| `adb connect <host>[:<port>]`      | Menghubungkan ke perangkat via TCP/IP  | Port default: 5555             |
| `adb disconnect [<host>[:<port>]]` | Memutus koneksi jaringan               | Tanpa argumen: putus semua     |
| `adb kill-server`                  | Menghentikan server ADB                |                                |
| `adb start-server`                 | Memulai server ADB                     |                                |
| `adb usb`                          | Beralih ke mode koneksi USB            |                                |

### Manajemen Aplikasi

| Perintah                            | Deskripsi               | Opsi/Penggunaan                                                           |
| ----------------------------------- | ----------------------- | ------------------------------------------------------------------------- |
| `adb install [opsi] <path>`         | Menginstal aplikasi     | `-r`: Install ulang<br>`-d`: Izinkan downgrade<br>`-g`: Beri semua izin   |
| `adb uninstall [opsi] <paket>`      | Menghapus aplikasi      | `-k`: Simpan data                                                         |
| `adb shell pm list packages [opsi]` | Daftar paket terinstal  | `-f`: Tampilkan path<br>`-s`: Paket sistem<br>`-3`: Aplikasi pihak ketiga |
| `adb shell pm path <paket>`         | Menampilkan lokasi APK  |                                                                           |
| `adb shell pm clear <paket>`        | Menghapus data aplikasi |                                                                           |
| `adb shell pm disable-user <paket>` | Menonaktifkan aplikasi  |                                                                           |
| `adb shell pm enable <paket>`       | Mengaktifkan aplikasi   |                                                                           |

### Manajemen File

| Perintah                                | Deskripsi                     | Opsi/Penggunaan                                     |
| --------------------------------------- | ----------------------------- | --------------------------------------------------- |
| `adb push <lokal> <remote>`             | Mengirim file ke perangkat    |                                                     |
| `adb pull [opsi] <remote> [<lokal>]`    | Mengambil file dari perangkat | `-a`: Pertahankan metadata                          |
| `adb shell ls [opsi] <path>`            | Daftar file/direktori         | `-l`: Format panjang<br>`-a`: Tampilkan tersembunyi |
| `adb shell rm [opsi] <path>`            | Menghapus file                | `-r`: Rekursif                                      |
| `adb shell mkdir [opsi] <path>`         | Membuat direktori             | `-p`: Buat direktori induk                          |
| `adb shell mv <sumber> <tujuan>`        | Memindahkan/mengganti nama    |                                                     |
| `adb shell cp [opsi] <sumber> <tujuan>` | Menyalin file                 | `-r`: Rekursif                                      |

### Operasi Shell dan Sistem

| Perintah                               | Deskripsi                      | Opsi/Penggunaan                                          |
| -------------------------------------- | ------------------------------ | -------------------------------------------------------- |
| `adb shell`                            | Masuk ke shell interaktif      |                                                          |
| `adb shell <command>`                  | Eksekusi perintah langsung     |                                                          |
| `adb shell screencap <path>`           | Tangkap layar                  |                                                          |
| `adb shell screenrecord [opsi] <path>` | Rekam layar                    | `--time-limit <n>`: Durasi<br>`--bit-rate <n>`: Kualitas |
| `adb reboot [target]`                  | Reboot perangkat               | `recovery`<br>`bootloader`<br>`sideload`                 |
| `adb root`                             | Restart adbd dengan akses root |                                                          |
| `adb remount`                          | Remount partisi /system        |                                                          |

### Logging dan Diagnostik

| Perintah                      | Deskripsi                | Opsi/Penggunaan                                                               |
| ----------------------------- | ------------------------ | ----------------------------------------------------------------------------- |
| `adb logcat [opsi]`           | Tampilkan log sistem     | `-v <format>`: Format output<br>`-s <tag>`: Filter tag<br>`-c`: Bersihkan log |
| `adb bugreport [opsi]`        | Hasilkan laporan bug     | `-z`: Kompresi ZIP                                                            |
| `adb shell dumpsys <service>` | Dump info layanan sistem | `battery`<br>`meminfo`<br>`package`                                           |
| `adb shell dumpstate`         | Dump status sistem       |                                                                               |
| `adb shell dmesg`             | Tampilkan pesan kernel   |                                                                               |

### Operasi Lanjutan

| Perintah                       | Deskripsi                  | Opsi/Penggunaan                                                             |
| ------------------------------ | -------------------------- | --------------------------------------------------------------------------- |
| `adb backup [opsi] <paket>`    | Backup data aplikasi       | `-f <file>`: Nama file<br>`-apk`: Sertakan APK<br>`-shared`: Backup SD card |
| `adb restore <file>`           | Restore data backup        |                                                                             |
| `adb forward <lokal> <remote>` | Forward port ke perangkat  |                                                                             |
| `adb reverse <remote> <lokal>` | Forward port ke PC         |                                                                             |
| `adb jdwp`                     | Daftar proses JDWP         |                                                                             |
| `adb sideload <file>`          | Install paket via recovery |                                                                             |

## Perintah Fastboot

### Manajemen Perangkat dan Informasi

| Perintah                     | Deskripsi                     | Opsi/Penggunaan       |
| ---------------------------- | ----------------------------- | --------------------- |
| `fastboot devices`           | Daftar perangkat terhubung    |                       |
| `fastboot getvar <variabel>` | Tampilkan variabel bootloader | `all`: Semua variabel |
| `fastboot help`              | Tampilkan bantuan             |                       |
| `fastboot --version`         | Tampilkan versi               |                       |

### Operasi Boot dan Reboot

| Perintah                     | Deskripsi                 | Opsi/Penggunaan |
| ---------------------------- | ------------------------- | --------------- |
| `fastboot reboot`            | Reboot ke sistem          |                 |
| `fastboot reboot-bootloader` | Reboot ke bootloader      |                 |
| `fastboot reboot recovery`   | Reboot ke recovery        |                 |
| `fastboot reboot fastboot`   | Reboot ke fastbootd       |                 |
| `fastboot boot <kernel>`     | Boot sementara dari image |                 |

### Flashing Partisi

| Perintah                                              | Deskripsi                | Opsi/Penggunaan                  |
| ----------------------------------------------------- | ------------------------ | -------------------------------- |
| `fastboot flash <partisi> <file>`                     | Flash image ke partisi   | `boot`<br>`recovery`<br>`system` |
| `fastboot flash:raw <partisi> <kernel> [ <ramdisk> ]` | Flash kernel dan ramdisk |                                  |
| `fastboot flashall`                                   | Flash semua partisi      | `-w`: Hapus data                 |
| `fastboot erase <partisi>`                            | Hapus partisi            |                                  |
| `fastboot format[:<fs_type>] <partisi>`               | Format partisi           | `ext4`<br>`f2fs`                 |
| `fastboot update <file.zip>`                          | Flash update ZIP         |                                  |

### Manajemen Bootloader

| Perintah                   | Deskripsi                     | Opsi/Penggunaan |
| -------------------------- | ----------------------------- | --------------- |
| `fastboot oem unlock`      | Buka kunci bootloader         |                 |
| `fastboot flashing unlock` | Buka kunci (alternatif)       |                 |
| `fastboot oem lock`        | Kunci bootloader              |                 |
| `fastboot flashing lock`   | Kunci bootloader (alternatif) |                 |
| `fastboot oem device-info` | Info status bootloader        |                 |

### Manajemen Slot (Sistem A/B)

| Perintah                       | Deskripsi                    | Opsi/Penggunaan |
| ------------------------------ | ---------------------------- | --------------- |
| `fastboot set_active <slot>`   | Set slot aktif               | `a` atau `b`    |
| `fastboot getvar current-slot` | Tampilkan slot aktif         |                 |
| `fastboot --set-active=<slot>` | Set slot aktif (opsi global) |                 |

### Perintah Tingkat Lanjut

| Perintah                          | Deskripsi                      | Opsi/Penggunaan |
| --------------------------------- | ------------------------------ | --------------- |
| `fastboot continue`               | Lanjutkan booting              |                 |
| `fastboot oem <command>`          | Perintah OEM spesifik          |                 |
| `fastboot stage <file>`           | Unggah file ke memori staging  |                 |
| `fastboot get_staged <file>`      | Unduh file dari memori staging |                 |
| `fastboot fetch <partisi> <file>` | Ambil partisi sebagai image    |                 |
| `fastboot set_active <slot>`      | Ubah slot partisi aktif        |                 |

### Verifikasi dan Tanda Tangan

| Perintah                          | Deskripsi                     | Opsi/Penggunaan |
| --------------------------------- | ----------------------------- | --------------- |
| `fastboot flash vbmeta <file>`    | Flash image vbmeta            |                 |
| `fastboot --disable-verity`       | Nonaktifkan dm-verity         |                 |
| `fastboot --disable-verification` | Nonaktifkan verifikasi vbmeta |                 |

## Tabel Referensi Variabel Fastboot

| Variabel             | Deskripsi               | Contoh Nilai   |
| -------------------- | ----------------------- | -------------- |
| `product`            | Model perangkat         | `walleye`      |
| `version-bootloader` | Versi bootloader        | `mwm2.0.3.0`   |
| `secure`             | Status keamanan         | `yes`          |
| `unlocked`           | Status kunci bootloader | `yes`          |
| `is-userspace`       | Mode userspace          | `no`           |
| `current-slot`       | Slot partisi aktif      | `a`            |
| `slot-suffixes`      | Daftar slot             | `a,b`          |
| `serialno`           | Nomor seri perangkat    | `HT82F1A12345` |

## Catatan Penggunaan Penting

**info persyaratan**:
- ADB memerlukan pengaktifan USB Debugging di Opsi Developer
- Fastboot memerlukan akses [bootloader unlocking](https://en.wikipedia.org/wiki/Bootloader_unlocking)
- Driver USB spesifik perangkat harus terinstal

**Konvensi Penulisan:**
- `<parameter>`: Nilai wajib diisi
- `[parameter]`: Nilai opsional
- `-opsi`: Opsi baris perintah

**Keselamatan Operasi:**
- Selalu pastikan baterai cukup (>50%) sebelum operasi flash
- Operasi flash yang salah dapat menyebabkan [brick](https://en.wikipedia.org/wiki/Brick_(electronics)) permanen
- Backup data penting sebelum modifikasi sistem

## Restore Kunci ADB dari Kali Linux ke Android via TWRP Terminal

### Prasyarat Teknis

Sebelum memulai, pastikan lingkungan kerja Anda memenuhi kriteria berikut:
- Perangkat Android dalam mode TWRP Recovery
- Koneksi USB aktif antara device dan Kali Linux
- File kunci ADB asli dari Kali Linux (`adbkey` dan `adbkey.pub`)
- Akses root melalui TWRP

### Phase 1: Persiapan Kunci ADB dari Kali Linux

#### Langkah 1: Backup Kunci ADB Existing
Akses direktori ADB keys di Kali Linux
```bash
cd ~/.android
```

Backup kunci existing ke lokasi aman
```bash
cp adbkey /path/to/backup/
cp adbkey.pub /path/to/backup/
```

> Backup preventive ini crucial untuk menghindari kehilangan akses permanen.
{: .prompt-info}

### Phase 2: Inisialisasi Koneksi TWRP

#### Langkah 2: Boot ke Recovery Mode
Restart device menuju TWRP recovery
```bash
adb reboot recovery
```

**Tunggu 30-60 detik** hingga device sepenuhnya masuk TWRP interface.

#### Langkah 3: Verifikasi Koneksi ADB
Periksa status device dalam TWRP
```bash
adb devices
```
Output yang diharapkan: `[serial number]    recovery`

### Phase 3: Transfer Kunci ADB ke Device

#### Langkah 4: Push Files ke Temporary Storage
Transfer kedua file kunci ke temporary storage TWRP
```bash
adb push adbkey /tmp/
adb push adbkey.pub /tmp/
```

Verifikasi transfer sukses
```bash
adb shell ls -la /tmp/adbkey*
```

### Phase 4: Proses Restore via Terminal TWRP

#### Langkah 5: Akses TWRP Terminal
Masuk ke shell environment TWRP
```bash
adb shell
```

#### Langkah 6: Mount Partisi System
Mount partisi system untuk akses write
```bash
mount /system
```

Untuk device encrypted, decrypt terlebih dahulu
```bash
twrp decrypt [password]
```

#### Langkah 7: Backup Kunci Existing (Opsional tapi Recommended)
Backup kunci ADB lama sebagai safety measure
```bash
cp /data/misc/adb/adb_keys /data/misc/adb/adb_keys.backup
cp /data/misc/adb/adb_key /data/misc/adb/adb_key.backup
```

#### Langkah 8: Eksekusi Restore Kunci Baru
Overwrite kunci ADB existing dengan yang baru
```bash
cp /tmp/adbkey /data/misc/adb/adb_key
cp /tmp/adbkey.pub /data/misc/adb/adb_keys
```

Alternatif menggunakan redirection
```bash
cat /tmp/adbkey > /data/misc/adb/adb_key
cat /tmp/adbkey.pub > /data/misc/adb/adb_keys
```

### Phase 5: Konfigurasi Permission & Security

#### Langkah 9: Set Permission yang Tepat
Set file permissions untuk keamanan
```bash
chmod 600 /data/misc/adb/adb_key
chmod 644 /data/misc/adb/adb_keys
```

Set ownership system
```bash
chown system:system /data/misc/adb/adb_key
chown system:system /data/misc/adb/adb_keys
```

#### Langkah 10: Cleanup Temporary Files
Hapus file temporary untuk keamanan
```bash
rm /tmp/adbkey
rm /tmp/adbkey.pub
```

### Phase 6: Finalisasi & Testing

#### Langkah 11: Reboot System
Keluar dari TWRP shell
```bash
exit
```

Reboot device ke system normal
```bash
adb reboot
```

#### Langkah 12: Verifikasi Koneksi
Setelah device fully booted
```bash
adb devices
```

Expected Result: Device terdeteksi tanpa authorization prompt

### Troubleshooting & Best Practices

### Common Issues & Solutions:

1. **Device Tidak Terdeteksi di TWRP**
   - Pastikan driver ADB terinstall proper
   - Coba ganti kabel USB
   - Restart ADB server: `adb kill-server && adb start-server`

2. **Permission Denied di TWRP Shell**
   - Pastikan TWRP versi terbaru
   - Gunakan `adb root` sebelum masuk shell

3. **Kunci Tidak Berfungsi Setelah Reboot**
   - Verifikasi permission dan ownership
   - Pastikan tidak ada SELinux policy restrictions
