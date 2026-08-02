---
title: Mentransformasikan Kali Linux menjadi macOS
description: Dokumentasi ini akan lebih menarik karena akan memberikan tampilan yang menyerupai macOS pada Kali Linux.
categories: [no categories]
tags: [linux, customization]
author: rical
last_modified_at: 2026-06-01
---

Dalam dokumentasi ini, digunakan instalasi utama Kali Linux versi 2025.1 dengan manajer tampilan LightDM. Proses konfigurasi yang akan dilakukan cukup beragam, sehingga dokumentasi ini dilengkapi dengan banyak tangkapan layar dan mungkin akan cukup panjang. Namun, setiap langkah yang dijelaskan akan memberikan manfaat, sehingga kesabaran sangat diperlukan. Setelah menyelesaikan seluruh proses, tampilan Kali Linux akan terlihat seperti pada tangkapan layar berikut.

![Kali Linux](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/kali-linux-macos.png)
    _Ya, ini adalah Kali Linux, bukan macOS_

Langkah pertama adalah memperbarui dan meningkatkan sistem Kali Linux dengan menggunakan perintah berikut:

```bash
sudo apt update && sudo apt upgrade -y
```

Melakukan pembaruan pada mesin secara rutin merupakan praktik yang baik untuk menjaga sistem tetap aman dan terkini.

## Konfigurasi Font
Pengaturan font yang akan digunakan perlu dilakukan. Dalam hal ini, font "Noto Sans" akan diterapkan pada sistem. Untuk mengunduh font ini, kunjungi [Google Fonts](https://fonts.google.com/). Proses pengunduhan dapat dilakukan dengan mengklik opsi "Get font" seperti yang ditunjukkan pada tangkapan layar berikut.

![Google Fonts](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/google-fonts.png)

Setelah pengunduhan, file akan disimpan dalam format zip. Jalankan perintah berikut untuk mengekstrak file:

```bash
cd ~/Downloads && unzip Noto_Sans.zip
```

Selanjutnya, arahkan ke direktori `/usr/share/fonts/X11`{: .filepath} dan pindahkan file tersebut ke lokasi tersebut.

```bash
sudo mv static/* /usr/share/fonts/X11
```

Setelah itu, pemilihan font yang telah disalin perlu dilakukan melalui pengaturan sistem. Buka Settings Manager.

![Settings Manager](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/settings-manager.png)

Setelah settings manager terbuka, jendela pengaturan akan muncul. Klik pada opsi "Appearance" dan kemudian beralih ke tab "Fonts", seperti yang ditunjukkan pada tangkapan layar berikut.

![Fonts](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/fonts.png)

## Konfigurasi Tema
Bagian selanjutnya adalah mengonfigurasi tema untuk menyerupai macOS. Tema yang akan digunakan adalah GTK WhiteSur, yang dapat diunduh dari [Pling](https://www.pling.com/p/1403328). Setelah mengunjungi situs tersebut, periksa bagian file dan unduh tema WhiteSur-Dark dan tema WhiteSur-Light.

![Pling](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/pling.png)

Setelah itu, navigasikan ke folder `Downloads`{:.filepath} dan temukan file tema yang terkompresi dalam format tar.xz. Selanjutnya, ekstrak file tersebut dengan perintah berikut:

```bash
cd ~/Downloads && tar -xvf WhiteSur-Dark.tar.xz
```

Setelah diekstrak, salin folder tema tersebut ke direktori `/usr/share/themes`{:.filepath} dengan perintah:

```bash
sudo mv WhiteSur-Dark /usr/share/themes
```

Setelah menyalin tema, perubahan tema dapat dilakukan melalui opsi "Appearance" di dalam Pengelola Pengaturan (Settings Manager).

![Theme](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/appearance-style.png)

Gaya tema dapat diubah dari default Kali-Dark ke tema WhiteSur, dengan memilih tema yang gelap.

> Nuansa tampilan juga dapat diubah, tetapi terdapat beberapa langkah tambahan yang perlu dilakukan.
{: .prompt-info} 

Di dalam Settings Manager, navigasikan ke opsi 'Window Manager'.

![Window Manager](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/window-manager.png)

Setelah berada di dalam 'Window Manager', ubah tema menjadi WhiteSur-Dark. Selain itu, pengaturan tombol aktif juga perlu diubah. Seperti diketahui, macOS memiliki tombol minimalkan, maksimalkan, dan tutup di sisi kiri jendela.

> Mengubah posisi tombol tersebut dapat dilakukan dengan metode drag and drop.
{: .prompt-tip}

![Window Manager](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/window-manager-1.png)

Dengan langkah-langkah tersebut, penyesuaian tema telah selesai dilakukan, dan tampilan semakin mendekati menyerupai macOS.

## Menginstal Ikon
Proses selanjutnya adalah menginstal tema ikon di sistem Kali Linux. Tema ikon ini akan mengubah ikon-ikon di sistem agar menyerupai macOS. Unduh tema ikon dari [Pling](https://www.pling.com/p/1405756).

![Unduh ikon](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/icons.png)

Setelah mengunduh tema ikon, gunakan metode yang sama untuk mengekstraknya. Setelah diekstrak, akan ditemukan dua folder di dalamnya: satu untuk tema ikon terang (light) dan satu lagi untuk tema ikon gelap (dark).

Selanjutnya, tempelkan folder tema ikon ke dalam direktori `/usr/share/icons`{:.filepath} dengan perintah berikut:

```bash 
cd ~/Downloads && tar -xvf 01-WhiteSur.tar.xz 
```

```bash
sudo mv WhiteSur-dark WhiteSur-light WhiteSur /usr/share/icons
```

Setelah menyalin folder tema ikon, perubahan ikon dapat dilakukan melalui tab "Icons" di menu "Appearance".

![Pengaturan ikon](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/icons-setting.png)

Selain ikon, macOS juga memiliki jenis kursor yang khas. Untuk mengubah kursor di sistem, unduh tema kursor dan konfigurasikan.

Tema kursor McMojave dapat diunduh dari [tautan berikut](https://www.pling.com/p/1355701). Setelah mengunduh dan mengekstraknya, salin folder kursor tersebut ke dalam direktori ikon, yaitu `/usr/share/icons`{:.filepath}.

```bash
cd ~/Downloads && tar -xvf McMojave-cursors.tar.xz
```

```bash
sudo mv McMojave-cursors /usr/share/icons
```

Setelah menyalin tema kursor, pengaturan kursor mouse dapat dilakukan. Buka kembali settings manager dan pilih opsi "Mouse and Touchpad".

![Mouse and Touchpad](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/mouse-and-touchpad.png)

Selanjutnya, navigasikan ke tab "Theme" dan pilih "McMojave Cursors", seperti yang ditunjukkan pada tangkapan layar berikut.

![Mouse and Touchpad: Themes](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/mouse-and-touchpad-themes.png)

Setelah melakukan pengaturan ini, kursor dan efeknya akan terlihat seperti yang ada di macOS.

## Mengonfigurasi Panel Atas
Proses selanjutnya adalah mengonfigurasi panel atas (top panel). Untuk melakukannya, klik kanan pada panel atas dan pilih opsi "Panel" diikuti dengan "Panel Preferences".

Setelah itu, jendela "Panel Preferences" akan muncul. Di sini, atur agar panel otomatis tersembunyi dengan cerdas (Intelligently), seperti yang ditunjukkan pada tangkapan layar berikut.

![Panel Preferences](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/panel-preferences.png)

Selanjutnya, beralih ke tab 'Items' di jendela 'Panel Preferences'. Di sini, ubah logo Whisker Menu menjadi logo Apple. Untuk melakukannya, klik pada opsi "Edit the currently selected item" seperti yang terlihat pada tangkapan layar berikut.

![Panel Items](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/panel-items.png)

Jendela pengaturan akan muncul seperti yang ditunjukkan pada tangkapan layar berikut:

![Whisker Menu](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/whisker-menu.png)

Untuk mengubah tombol, beralih ke tab 'Appearance'.

![Whisker Menu: Appearance](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/whisker-menu-appearance.png)

Di sini, ikon tombol dapat diubah. Klik pada ikon yang ada, dan setelah beberapa detik, semua ikon aplikasi akan muncul. Untuk mengatur ikon Apple, navigasikan ke opsi 'All Icons'.

Pada bilah pencarian, cari "start" dan temukan logo Apple. Klik pada logo tersebut, kemudian klik 'OK' untuk mengaturnya.

![Start Menu](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/start-menu.png)

Setelah itu, kustomisasi lainnya pada item lain dapat dilakukan sesuai kebutuhan. Sebagai contoh, "Workspace Switcher" dapat dihapus jika tidak diperlukan, sesuai dengan preferensi yang diinginkan.

## Plank
Plank adalah dock untuk Linux yang memberikan tampilan lebih menyerupai macOS. Untuk menginstalnya dan mengatur agar dock ini otomatis berjalan saat sistem dinyalakan, jalankan perintah berikut:

```bash
sudo apt install plank -y
```

Setelah proses instalasi selesai, jalankan Plank dengan perintah berikut:

```bash
plank
```

Dock ini akan menciptakan tampilan yang menarik di sistem, seperti yang dapat dilihat pada tangkapan layar berikut.

![Plank](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/plank.png)

Meskipun dock telah terpasang, tampilannya belum menyerupai macOS. Konfigurasi dock perlu dilakukan dengan menambahkan tema pada Plank. Tema yang diperlukan sudah diunduh di dalam folder tema WhiteSur-Light dan WhiteSur-Dark.

Pertama, buka pengelola file Thunar dengan izin root menggunakan perintah `sudo thunar`. Kemudian, navigasikan ke direktori `Downloads`{:.filepath} dan cari folder bernama "plank" di dalam folder WhiteSur. Salin folder tersebut ke dalam folder tema Plank.

Sebelum melakukannya, ganti nama folder tersebut karena tema terang (light) dan gelap (dark) untuk Plank keduanya dinamai "plank", sehingga tidak dapat disalin ke dalam direktori yang sama. Ubah nama folder Plank menjadi "WhiteSur-light-Plank" dan "WhiteSur-dark-Plank".

![Plank: Folder](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/plank-folder.png)

Setelah mengganti nama folder, salin dan tempel folder tersebut ke dalam direktori `/usr/share/plank/themes`{:.filepath}, seperti yang ditunjukkan pada tangkapan layar berikut.

![Plank: Themes](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/plank-themes.png)

Sekarang, tema Plank dapat diubah. Buka pengaturan Plank dengan menahan tombol Ctrl dan mengklik kanan pada item di Plank. Pilih opsi "Preferences". Di sini, tema dapat diubah sesuai keinginan.

Di jendela "Appearance" yang muncul, atur tema menjadi WhiteSur Dark atau WhiteSur Light, serta aktifkan opsi "Icon Zoom" dengan nilai 150, seperti yang ditunjukkan pada tangkapan layar berikut.

![Plank: Appearance](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/plank-appearance.png)

Untuk menambahkan item baru ke dock Plank, gunakan metode drag and drop dari jendela aplikasi utama. Untuk menghapus item dari dock Plank, seret item tersebut ke sisi kanan desktop dan lepaskan.

Jika terdapat bayangan dari dock Plank di layar, pergi ke Settings Manager > "Window Manager Tweaks". Navigasikan ke tab 'Compositor' dan hapus centang pada opsi "Show shadows under dock windows".

![Compositor](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/compositor.png)

Selanjutnya, atur Plank agar otomatis berjalan saat sistem dinyalakan. Dengan cara ini, dock akan muncul secara otomatis saat boot sistem tanpa perlu menjalankan perintah `plank` secara manual.

Buka kembali 'Settings Manager'. Lanjutkan ke 'Session and Startup' dan navigasikan ke tab 'Application Autostart'. Klik pada tombol '➕Add'.

Berikan nama 'Plank' pada kolom Name, dan untuk kolom Command, masukkan `plank`. Setelah mengisi informasi tersebut, klik 'OK' untuk menyimpan pengaturan.

![Plank: Autostart](assets/img/posts/2025-05-12-mentransformasikan-kali-linux-menjadi-macos/plank-autostart.png)

Dengan langkah-langkah tersebut, Plank telah ditambahkan ke dalam aplikasi yang berjalan otomatis saat startup.

Saat ini, Kali Linux telah menggunakan ZSH sebagai shell default, sehingga terminal juga berfungsi dengan ZSH, mirip dengan yang ada di macOS. Penggunaan ZSH memberikan pengalaman terminal yang lebih kaya dengan fitur-fitur seperti autocompletion yang lebih baik dan kemampuan penyesuaian yang lebih luas, sehingga meningkatkan produktivitas pengguna. 

Dengan semua penyesuaian ini, Kali Linux tidak hanya terlihat lebih menarik, tetapi juga lebih fungsional dan nyaman digunakan. Proses ini tidak hanya menyenangkan, tetapi juga menghasilkan tampilan yang sangat mengesankan.