---
title: Panduan Konfigurasi Lengkap Kitty Terminal untuk Linux
description: Pelajari cara menginstal dan mengoptimalkan Kitty Terminal di Linux. Panduan teknis ini mencakup konfigurasi font, tema, scrollback, notifikasi, dan kustomisasi produktivitas untuk pengembang.
categories: [no categories]
tags: [linux, customization, kitty]
author: rical
last_modified_at: 2026-06-01
---

## Pengantar

Kitty merupakan salah satu emulator terminal paling komprehensif yang tersedia untuk sistem operasi Linux. Emulator ini menawarkan dukungan gambar native, ligatur font, kursor animasi, serta beragam penyesuaian yang dirancang untuk meningkatkan produktivitas pengguna.

Artikel ini menyajikan panduan teknis terstruktur untuk menginstal dan mengonfigurasi Kitty Terminal, mencakup serangkaian fitur dan penyesuaian kunci yang dapat diimplementasikan melalui file konfigurasi.

## Instalasi Kitty Terminal

Mengingat popularitasnya, Kitty umumnya tersedia dalam repositori default berbagai distribusi Linux. Berikut adalah perintah instalasi untuk beberapa distro populer:

**Ubuntu/Debian:**
```bash
sudo apt install kitty
```

**Arch Linux:**
```bash
sudo pacman -S kitty
```

**Fedora:**
```bash
sudo dnf install kitty
```

Untuk distribusi lain atau jika menginginkan versi terbaru, gunakan biner pra-kompilasi resmi:
```bash
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
```

Alternatifnya, unduh biner langsung dari [halaman rilis GitHub Kitty](https://github.com/kovidgoyal/kitty/releases).

## Konfigurasi Dasar

Konfigurasi Kitty dilakukan sepenuhnya melalui file `kitty.conf` yang berada di direktori `~/.config/kitty`{: .filepath}. Disarankan untuk memulai dengan konfigurasi default dan memodifikasinya.

1.  Buka atau buat file konfigurasi:
    ```bash
    nano ~/.config/kitty/kitty.conf
    ```

## 1. Mengonfigurasi Font

Pemilihan font monospace yang tepat penting untuk keterbacaan dan estetika. Contoh ini menggunakan font [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono?query=jetbrains).

> Pastikan font yang diinginkan telah terinstal di sistem.
{: .prompt-info}

1.  Identifikasi nama font yang tepat menggunakan perintah Kitty:
    ```bash
    kitty +list-fonts
    ```
2.  Dalam file `kitty.conf`, temukan dan modifikasi baris `font_family`:
    ```
    # BEGIN_KITTY_FONTS
    font_family      family="JetBrains Mono"
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    # END_KITTY_FONTS
    ```
3.  Atur ukuran font dengan mengubah nilai `font_size`:
    ```
    font_size 12.0
    ```

## 2. Mengatur Scrollback

Scrollback yang memadai penting untuk meninjau output perintah yang panjang. Pertimbangkan penggunaan memori saat menetapkan nilai ini.

5.  Dalam konfigurasi, cari `scrollback_lines` dan atur nilainya (contoh: 5000 baris):
    ```
    scrollback_lines 5000
    ```
6.  Aktifkan fitur pager untuk navigasi scrollback yang lebih mudah dengan menentukan ukuran riwayat dalam MB:
    ```
    scrollback_pager_history_size 10
    ```

> Gunakan `most` sebagai pager alternatif untuk menambahkan sintaks highlighting.
{: .prompt-tip}

## 3. Menyembunyikan Kursor Mouse Saat Mengetik

Untuk pengguna yang mengutamakan keyboard, kursor mouse dapat disembunyikan selama aktivitas ketik.

7.  Atur variabel `mouse_hide_wait` ke nilai negatif untuk menyembunyikan kursor segera setelah mengetik:
    ```
    mouse_hide_wait  -3.0
    ```
    Atau, atur ke nilai positif (dalam detik) untuk menyembunyikan kursor setelah periode inaktivitas:
    ```
    mouse_hide_wait  5.0
    ```

## 4. Mengatur Ukuran Jendela Default

Kitty dapat dikonfigurasi untuk membuka jendela dengan ukuran konsisten.

8.  Nonaktifkan pengingat ukuran jendela dan tetapkan ukuran awal:
    ```
    remember_window_size  no
    initial_window_width  800
    initial_window_height 400
    ```

## 5. Menyesuaikan Tampilan Tab

Kitty menawarkan berbagai gaya untuk bilah tab.

9.  Tentukan posisi bilah tab (`top` atau `bottom`):
    ```
    tab_bar_edge bottom
    ```
10. Pilih gaya bilah tab. Opsi termasuk `fade`, `slant`, `separator`, `powerline`, dan `custom`. Contoh dengan gaya `powerline`:
    ```
    tab_bar_style powerline
    ```
11. Untuk gaya `powerline`, tentukan juga sub-gayanya (`angled`, `slanted`, `round`):
    ```
    tab_powerline_style round
    ```

## 6. Mengubah Shell Default untuk Instance Kitty

Anda dapat mengatur shell khusus untuk Kitty tanpa mengubah shell default sistem.

12. Identifikasi path shell yang diinginkan (contoh: Zsh):
    ```bash
    which zsh
    ```
13. Dalam `kitty.conf`, temukan kunci `shell .` dan ganti nilainya dengan path lengkap:
    ```
    shell /usr/bin/zsh
    ```

> Kunci `editor` dapat digunakan dengan cara serupa untuk mengatur editor teks default di dalam Kitty.
{: .prompt-info}

## 7. Mengaktifkan Notifikasi Desktop

Kitty dapat mengirim notifikasi ketika perintah yang berjalan lama selesai.

14. Aktifkan notifikasi hanya ketika jendela terminal tidak terlihat:
    ```
    notify_on_cmd_finish invisible
    ```
15. Untuk hanya menerima notifikasi untuk perintah yang berjalan lebih dari durasi tertentu (contoh: 20 detik):
    ```
    notify_on_cmd_finish invisible 20
    ```

## 8. Mengganti Tema

Kitty dilengkapi dengan berbagai tema yang dapat dijelajahi dan diterapkan dengan mudah.

16. Jalankan perintah berikut untuk menampilkan galeri tema:
    ```bash
    kitten themes
    ```
17. Gunakan tombol panah untuk menelusuri, tekan `/` untuk mencari, dan `ENTER` untuk menerapkan tema. Pilih opsi `M` untuk menerapkan tema secara permanen dengan memodifikasi file konfigurasi.

## 9. Animasi Kursor (Trail)

Versi Kitty terbaru mendukung efek animasi pada kursor.

18. Aktifkan dan sesuaikan jejak kursor di konfigurasi:
    ```
    cursor_trail 200
    cursor_trail_decay 0.1 0.4
    cursor_trail_start_threshold 2
    ```
    Nilai-nilai di atas dapat disesuaikan sesuai preferensi visual.

## 10. Tema Gelap/Terang Otomatis (Kitty v0.38+)

Kitty dapat secara otomatis beralih tema berdasarkan mode sistem.

19. Jalankan `kitten themes` dan pilih tema gelap. Pada layar konfirmasi, tekan `D` untuk menjadikannya tema default mode gelap.
20. Ulangi proses, pilih tema terang, dan tekan `L` untuk tema default mode terang.
21. Ulangi sekali lagi, pilih tema apa saja, dan tekan `N` untuk tema default jika tidak ada preferensi sistem yang terdeteksi.

## 11. Gambar Latar Belakang dan Watermark

Tambahkan elemen visual untuk personalisasi lebih lanjut.

22. Untuk menetapkan gambar latar belakang:
    ```
    background_image /path/ke/gambar.png
    background_image_layout centered # atau tile, scaled, cetered-tiled
    ```
23. Untuk menambahkan logo/watermark:
    ```
    window_logo_path /home/user/.config/kitty/logo.png # ukuran 50x50
    window_logo_position bottom-right
    window_logo_alpha 0.4
    # window_logo_scale 0
    ```

## Kesimpulan

Konfigurasi di atas merupakan dasar untuk memanfaatkan kemampuan kustomisasi Kitty Terminal yang ekstensif. Dengan menguasai file `kitty.conf`, pengguna dapat lebih jauh mengeksplorasi fitur seperti pemetaan pintasan keyboard kustom dan penggunaan utilitas "Kittens" untuk memperluas fungsionalitas terminal. Dokumentasi resmi Kitty direkomendasikan sebagai sumber referensi untuk penyesuaian yang lebih mendalam.