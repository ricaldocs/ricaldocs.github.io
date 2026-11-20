---
title: Android Tools & Fix
description: Dokumentasi ini mencakup langkah-langkah untuk melakukan debloat aplikasi, menonaktifkan aplikasi, dan memperbaiki komponen Google Mobile Services (GMS) untuk menghindari masalah pemanasan dan masalah lainnya pada perangkat Android.
categories: [Digital Independence, Android]
tags: [android, tools]
author: rical
last_modified_at: 2026-06-01
---

> Seluruh langkah-langkah berikut hanya dapat dilakukan pada perangkat Android yang telah di-*root*. Pastikan perangkat telah melalui proses *rooting* sebelum melanjutkan. Gunakan [Termux](https://f-droid.org/en/packages/com.termux/) untuk melakukan perbaikan.
{: .prompt-warning}

> Setiap penggunaan dilakukan dengan risiko yang ditanggung oleh pengguna sendiri (*do what you own risk* - DWYOR).
{: .prompt-danger}

## Perbaikan
### DEX (Dalvik Executable)
Jalankan perintah-perintah berikut di Termux atau ADB setelah melakukan *dirty flash* dan tunggu hingga muncul tulisan **Success**. Langkah ini dapat memperbaiki (mikro)lag dan meningkatkan kecepatan pembukaan aplikasi.

#### Perintah untuk Pengguna Root
```bash
su -c cmd package compile -m speed -f -a
```
```bash
su -c "cmd package bg-dexopt-job"
```

#### Perintah untuk Pengguna Non-Root
```bash
adb shell cmd package compile -m speed -f -a
```
```bash
adb shell cmd package bg-dexopt-job
```

### Menonaktifkan Komponen GMS Chimera
```bash
su -c pm disable com.google.android.gms/.chimera.GmsIntentOperationService
```

### Memperbaiki Keterlambatan Notifikasi
```bash
su
```
```bash
cd /data/data
```
```bash
find . -type f -name '*gms*' -delete
```
```bash
reboot
```

### Mengulang SystemUI
```bash
su
```
```bash
pkill -f com.android.systemui
```

### Menonaktifkan Find My Device
```bash
su -c pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```

## Debloat
### Menghapus Aplikasi
```bash
su -c pm uninstall --user 0 NameOfPackage
```

### Menginstal Ulang Paket yang Ada
```bash
su -c pm install-existing --user 0 NameOfPackage
```

## Menonaktifkan
### Menonaktifkan Paket
```bash
su
```
```bash
pm disable-user --user 0 NameOfPackage
```

### Memeriksa Daftar Paket (Dinonaktifkan)
```bash
su
```
```bash
pm list packages -d
```
> Hapus `-d` untuk melihat seluruh nama paket.
{: .prompt-tip}

### Mengaktifkan Paket
```bash
su
```
```bash
pm enable NameOfPackage
```