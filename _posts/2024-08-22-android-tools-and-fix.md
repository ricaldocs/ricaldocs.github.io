---
title: Android Tools & Fix
description: Debloat Apps, Disable Apps, dan memperbaiki komponen GMS untuk menghindari masalah pemanasan, dan lain-lain.
categories: [Android, Tools & Fix]
tags: [android]
author: rical
---

> Harap diperhatikan bahwa seluruh langkah-langkah berikut hanya dapat dilakukan pada perangkat Android yang telah di-root. Pastikan perangkat telah melalui proses *rooting* sebelum melanjutkan. Gunakan [Termux](https://f-droid.org/en/packages/com.termux/) untuk melakukan perbaikan.
{: .prompt-warning }

> Setiap penggunaan dilakukan dengan risiko yang ditanggung oleh pengguna sendiri (*Do What You Own Risk* - DWYOR).
{: .prompt-danger}

## Fixes
### DEX (Dalvix Executable)
Jalankan perintah-perintah ini di Termux atau ADB setelah melakukan *dirtyflash* dan tunggu hingga muncul tulisan *"Success"*. Ini dapat memperbaiki (mikro)lag dan kecepatan pembukaan aplikasi yang lambat.

#### Perintah untuk pengguna root

```
su -c cmd package compile -m speed -f -a
```

```
su -c "cmd package bg-dexopt-job" 
```

#### Perintah untuk pengguna non-root
```
adb shell cmd package compile -m speed -f -a
```

```
adb shell cmd package bg-dexopt-job
```

### Disable GMS Chimera Component

```
su -c pm disable com.google.android.gms/.chimera.GmsIntentOperationService
```

### Fix Notification Delay

```
su
```

```
cd /data/data
```

```
find . -type f -name '*gms*' -delete
```

```
reboot
```

### Restart SystemUI

```
su
```

```
pkill -f com.android.systemui
```

### Disable Find My Device

```
su -c pm disable com.google.android.gms/com.google.android.gms.mdm.receivers.MdmDeviceAdminReceiver
```

## Debloat
### Debloat

```
su -c pm uninstall --user 0 NameOfPackage

```

### Reinstall Exist Package

```
su -c pm install-existing --user 0 NameOfPackage
```

## Disable
### Disable Package

```
su
```

```
pm disable-user --user 0 NemOfPackage
```

### Cek List Package (Disabled)

```
su
```

```
pm list packages -d
```

> Hapus `-d` untuk melihat seluruh nama paket.
{: .prompt-tip}


### Enable Package

```
su
```

```
pm enable NameOfPackage
```

## Referensi
- [ricalWiki](s://risnandapascal.github.io/ricalwiki.html)