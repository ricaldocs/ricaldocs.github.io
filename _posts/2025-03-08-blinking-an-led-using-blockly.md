---
title: Blinking an LED Using Blockly
description: Menggunakan pemrograman Blockly untuk mengendalikan objek IoT seperti LED.
categories: [Internet of Things]
tags: [cisco packet tracer, internet of things]
author: rical
last_modified_at: 2026-06-01
---

## Tujuan
- [Bagian 1: Memeriksa Program Blockly yang Sudah Dibangun](https://ricaldocs.github.io/posts/blinking-an-led-using-blockly/#bagian-1-memeriksa-program-blockly-yang-sudah-dibangun)
- [Bagian 2: Mengendalikan LED RGB Menggunakan Blockly](https://ricaldocs.github.io/posts/blinking-an-led-using-blockly/#bagian-2-mengendalikan-led-rgb-menggunakan-blockly)

## Latar Belakang
Blockly adalah bahasa pemrograman visual yang memungkinkan pengguna untuk membuat program dengan menghubungkan blok-blok yang mewakili berbagai struktur logika bahasa, alih-alih menulis kode secara langsung. Blockly berjalan di dalam peramban web dan dapat menerjemahkan program yang dibuat secara visual menjadi JavaScript, PHP, atau Python. Dalam aktivitas Packet Tracer ini, Anda akan menggunakan Blockly untuk mempelajari pemrograman Blockly dan mengendalikan LED.

## Skenario
Menggunakan pemrograman Blockly untuk mengendalikan objek IoT seperti LED. Dalam aktivitas ini, Cisco Packet Tracer digunakan karena menyediakan dukungan Blockly untuk objek IoT.

## Instruksi
Unduh berkas berikut dan buka di Cisco Packet Tracer:
[Blinking_an_LED_Using_Blockly_pka.pka](/assets/posts/Blinking_an_LED_Using_Blockly_pka.pka)

## Bagian 1: Memeriksa Program Blockly yang Sudah Dibangun
Pada bagian ini, Anda akan mengakses program Cisco Packet Tracer dan memeriksa pengendalian LED menggunakan pemrograman Blockly.

![Bagian 1: Memeriksa Program Blockly yang sudah Dibangun](assets/img/posts/2025-03-08-blinking-led-using-blockly/part-1.png)

### Langkah 1: Memeriksa Penggunaan LED
- Klik **LED** untuk membuka jendela konfigurasi.
- Tinjau spesifikasi untuk LED. Informasi ini diperlukan saat memprogram LED di kemudian hari dalam aktivitas ini. Biarkan jendela terbuka untuk referensi.

### Langkah 2: Memeriksa Program Blockly yang Sudah Dibangun
- Klik **MCU** untuk membuka jendela konfigurasi.
- Klik tab **Programming** untuk menampilkan program Blockly yang sudah dibangun.
- Klik **Run**.

Pertanyaan: Apakah LED berkedip? Jelaskan.

- Click **Stop**, dan ubah kolom Nilai pada blok digitalWrite pertama menjadi **1023**.
- Click **Run**. LED seharusnya sekarang berkedip.

### Langkah 3: Beralih dari Digital ke Analog
Spesifikasi LED menunjukkan bahwa fungsi analogWrite dapat digunakan untuk mengatur kecerahan perangkat. Pada langkah ini, Anda akan beralih dari digital ke analog dan mengamati perubahan kecerahan LED saat Anda mengubah nilai dalam program.

- Di tab **Programming** pada **MCU**, klik grup **Pin Access** untuk melihat semua opsi yang tersedia.
- Pilih **analogWrite** untuk menggantikan **digitalWrite** dalam program Blockly. Pertahankan semua nilai lainnya tetap sama.
- Sekarang, ubah nilai pada blok **analogWrite** pertama dan kedua, dan amati berbagai tingkat kecerahan LED setelah memulai ulang program. Misalnya, ubah nilai menjadi 100 dan 1023 untuk melihat perbedaan tingkat kecerahan LED.

![MCU > Programming](assets/img/posts/2025-03-08-blinking-led-using-blockly/mcu-programming.png)

- Klik **Stop** untuk menghentikan program.

## Bagian 2: Mengendalikan LED RGB Menggunakan Blockly
Pada bagian ini, Anda akan menggunakan Blockly untuk mengendalikan LED RGB. LED RGB dapat menampilkan berbagai warna dengan kombinasi merah, hijau, dan biru.

![Bagian 2: Mengendalikan LED RGB Menggunakan Blockly](assets/img/posts/2025-03-08-blinking-led-using-blockly/part-2.png)

### Langkah 1: Menambahkan Papan MCU dan LED RGB
Pada langkah ini, Anda akan menambahkan papan MCU lain dan LED RGB ke dalam ruang kerja.

- Salin **MCU** di ruang kerja. Dengan **MCU** yang disorot, salin (Ctrl + C) dan tempel (Ctrl + V) ke dalam ruang kerja. Klik dua kali pada nama tampilan papan yang disalin dan ganti nama **MCU(1)** menjadi **MCU-RGB**.
- Klik **Components** dan pilih **Actuators** lalu tambahkan **RGB LED** ke dalam ruang kerja. Ganti nama RGB LED menjadi **LED-RGB**.

### Langkah 2: Menghubungkan Papan MCU ke LED RGB
- Klik **RGB LED** untuk melihat spesifikasinya. Tinjau informasi yang disediakan agar Anda dapat menghubungkan dan memprogram LED dengan benar. Catat bahwa pin input yang berbeda mewakili warna yang berbeda. Biarkan jendela tetap terbuka.
- Klik kategori **Connections**. Pilih tiga **IoT Custom Cables** untuk menghubungkan **MCU-RGB** dan **LED-RGB**.

> Menurut spesifikasi LED RGB:
- A0: Merah
- A1: Hijau
- A2: Biru
{: .prompt-info}

Oleh karena itu, port **MCU-RGB D0** terhubung ke port **RGB-LED A0** untuk warna LED merah.

> Pada papan MCU, pastikan Anda terhubung ke port digital (D0, D1, dan D2). Di sisi LED, port analog (A0, A1, A2) digunakan.
{: .prompt-info}

> Ulangi prosedur yang sama untuk warna LED hijau dan biru.
- Hijau: **MCU-RGB D1** ke **LED-RGB A1**
- Biru: **MCU-RGB D2** ke **LED-RGB A2**
- Merah: **MCU-RGB D0** ke **LED-RGB A0**
{: .prompt-tip}

### Langkah 3: Memodifikasi Program Blockly
Pada langkah ini, Anda akan memprogram LED RGB dengan memodifikasi program yang digunakan untuk LED berwarna tunggal.

- Klik **MCU-RGB**. Klik **Programming**. Anda seharusnya melihat program untuk mengendalikan LED berwarna tunggal yang telah dimodifikasi pada bagian sebelumnya.

- Perluas grup **Pin Access**, dan tambahkan dua blok **pinMode** lagi untuk mengatur tiga slot sebagai  **OUTPUT** (dari MCU-RGB untuk mengirim sinyal ke RGB-LED).

- Atur nilai slot untuk slot 1, 2, dan 3 untuk setiap warna LED.

- Dalam loop pengulangan, tambahkan blok untuk mengontrol kapan dan berapa lama setiap warna dinyalakan. Berikut adalah contoh program:

![Blinking LED](assets/img/posts/2025-03-08-blinking-led-using-blockly/blockly-program.png)

- Klik **Run**. LED seharusnya menampilkan warna MERAH, HIJAU, dan BIRU secara berurutan. Jika program tidak berjalan, periksa kembali apakah kabel terhubung dengan benar.

![Blinking LED](assets/img/posts/2025-03-08-blinking-led-using-blockly/blinking-led.png)