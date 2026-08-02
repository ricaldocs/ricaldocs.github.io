---
title: Connect Devices to a Home Gateway and Monitor Your Network
description: Penghubungan perangkat IoT ke Home Gateway melibatkan konfigurasi jaringan menggunakan Cisco Packet Tracer.
categories: [Cisco Packet Tracer, Internet of Things]
tags: [cisco packet tracer, internet of things]
author: rical
last_modified_at: 2026-06-01
---

## Tujuan
- [Bagian 1: Menghubungkan Home Gateway ke Jaringan](https://ricaldocs.github.io/posts/connect-devices-to-a-home-gateway-and-monitor-your-network/#bagian-1-menghubungkan-home-gateway-ke-jaringan)
- [Bagian 2: Menambahkan End User Devices ke Jaringan](https://ricaldocs.github.io/posts/connect-devices-to-a-home-gateway-and-monitor-your-network/#bagian-2-menambahkan-end-user-devices-ke-jaringan)
- [Bagian 3: Menambahkan Perangkat IoT ke Jaringan](https://ricaldocs.github.io/posts/connect-devices-to-a-home-gateway-and-monitor-your-network/#bagian-3-menambahkan-perangkat-iot-ke-jaringan)
- [Bagian 4: Menambahkan Perangkat Bluetooth](https://ricaldocs.github.io/posts/connect-devices-to-a-home-gateway-and-monitor-your-network/#bagian-4-menambahkan-perangkat-bluetooth)

## Latar Belakang / Skenario
Dalam kegiatan ini, Anda akan menambahkan sebuah Home Gateway dan beberapa perangkat Internet of Things (IoT) ke jaringan rumah yang sudah ada, serta memantau perangkat-perangkat tersebut melalui Home Gateway.

![Connect_Devices_to_a_Home_Gateway_and_Monitor_Your_Network](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/Connect_Devices_to_a_Home_Gateway_and_Monitor_Your_Network_pka.png)

> Kegiatan ini akan dinilai. Pastikan Anda mengubah Nama Tampilan (Display Name) sesuai petunjuk yang diberikan, atau penilaian tidak akan akurat. Klik "Periksa Hasil" (Check Results) kapan saja untuk melihat kemajuan Anda.
{: .prompt-info}

## Instruksi
Unduh berkas berikut dan buka di Cisco Packet Tracer:
[Connect_Devices_to_a_Home_Gateway_and_Monitor_Your_Network_pka.pka](/assets/posts/Connect_Devices_to_a_Home_Gateway_and_Monitor_Your_Network_pka.pka)

## Bagian 1: Menghubungkan Home Gateway ke Jaringan
### Langkah 1: Menambahkan Home Gateway.

![Device-Type Selection](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/end-devices.png)
_Device-Type Selection_

- Dalam kotak **Device-Type Selection**, klik pada **Network Devices**, kemudian pilih **Wireless Devices**.
- Klik pada **Home Gateway**, lalu klik di ruang kerja **Logical** untuk menambahkan perangkat tersebut.
- Klik pada **Home Gateway0**, kemudian pilih tab **Config**. Ubah Display Name menjadi **Home Gateway**.

### Langkah 2: Menghubungkan Home Gateway ke Cable Modem
- Dalam kotak **Device-Type Selection**, klik pada **Connections**, kemudian pilih kabel **Copper Straight-Through**.
- Klik pada **Cable Modem** dan sambungkan salah satu ujung kabel ke **Port 1**.
- Klik pada **Home Gateway** dan sambungkan ujung kabel yang lainnya ke port **Internet**.

## Bagian 2: Menambahkan End User Devices ke Jaringan
### Langkah 1: Menambahkan Tablet Nirkabel ke Ruang Kerja.
- Dalam kotak **Device-Type Selection**, klik pada **End Devices**, kemudian pilih **Tablet**. Tambahkan **Tablet** ke ruang kerja.
- Klik pada **Tablet PC0**, kemudian pilih tab **Config**. Ubah Display Name menjadi **Tablet**.

![langkah-1.png](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/langkah-1.png)

### Langkah 2: Menghubungkan Tablet ke Jaringan Home Gateway.
Perhatikan bahwa **Tablet** sudah terhubung ke jaringan seluler. Sinyal nirkabel berwarna biru terhubung ke **Internet** cloud di mana penyedia seluler berada.
- Untuk menghubungkan Tablet ke jaringan Wi-Fi rumah, klik pada Antarmuka Wireless0 di panel kiri pada tab Konfigurasi.
- Ubah SSID dari **Default** menjadi **HomeGateway**. **Tablet** akan terhubung ke jaringan Wi-Fi rumah. Mungkin diperlukan satu atau dua menit untuk pengalamatan IP berubah menjadi alamat dari jaringan 192.168.25.x. Anda dapat mengklik **Fast Forward Time** (Alt+D) untuk mempercepat proses.


![langkah-2.png](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/langkah-2.png)

- Sekarang perhatikan bahwa **Tablet** memiliki dua koneksi nirkabel: seluler dan Wi-Fi. Hal ini umum terjadi pada tablet dan smartphone yang mendukung jaringan seluler.

![langkah-2-connect.png](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/langkah-2-connect.png)

### Langkah 3: Mengakses Home Gateway dari Tablet.
Dari Tablet, klik tab **Desktop** > **IoT Monitor**. Perhatikan bahwa Alamat Server IoT adalah alamat IP dari **Home Gateway**, dan "admin" digunakan sebagai nama pengguna dan kata sandi. Klik **Login**.

![IoT Monitor](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/iot-monitor.png)

Ini memverifikasi bahwa Anda dapat mengakses Home Gateway IoT Server. Perhatikan bahwa belum ada perangkat yang muncul dalam daftar **Home Gateway IoT Server - Devices**.

## Bagian 3: Menambahkan Perangkat IoT ke Jaringan
Dalam bagian ini, Anda akan menambahkan tiga perangkat IoT baru ke jaringan dan mendaftarkannya ke server Home Gateway.

### Langkah 1: Menambahkan Perangkat IoT ke Jaringan Berkabel.
Dalam langkah ini, Anda akan menghubungkan perangkat IoT baru ke jaringan berkabel.

- Dalam kotak **Device-Type Selection**, klik **End Devices** > **Home**, kemudian klik pada **Lampu** dan tambahkan ke ruang kerja.
- Klik pada perangkat **Lampu**, kemudian klik pada tab **Advanced** untuk menampilkan lebih banyak tab.
- Klik pada **I/O Config** untuk mengubah Network Adapter menjadi **PT-IOT-NM-1CFE**.

![PT-IOT-NM-1CFE](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/lamp-io-config.png)

- Klik pada tab **Config** dan ubah nama perangkat menjadi **Lamp**.
- Di panel kiri, klik **FastEthernet0**, kemudian pilih tombol radio **DHCP** agar lampu menerima alamat IPv4 dari Home Gateway.
- Klik **Connections** > **Copper Straight-Through** dan sambungkan port **FastEthernet0** dari **Lamp** ke salah satu port Ethernet yang tersedia di **Home Gateway**.

![Bagian 3 - Langkah 1](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/bagian3-langkah1.png)

### Langkah 2: Menambahkan Perangkat IoT ke Jaringan Nirkabel HomeGateway.
Dalam langkah ini, Anda akan menghubungkan dua perangkat IoT baru ke jaringan nirkabel.

- Dalam kotak **Device-Type Selection**, klik **End Devices** > **Home**. Tambahkan **Fan** dan **Door** ke ruang kerja.
- Ubah nama tampilan kipas menjadi **Fan**.
- Ubah nama tampilan pintu menjadi **Door**.
- Dalam konfigurasi **Wireless0** untuk masing-masing perangkat, perhatikan bahwa SSID sudah diatur ke **HomeGateway** dan bahwa setiap perangkat telah menerima alamat IP dari jaringan 192.168.25.x. Anda mungkin perlu mengklik **Fast Forward Time** untuk mempercepat proses.

![Bagian 3 - Langkah 2](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/bagian3-langkah2.png)

### Langkah 3: Mengonfigurasi Perangkat IoT untuk Mendaftar dengan Server Home Gateway.
Untuk masing-masing dari tiga perangkat IoT, klik tab **Config**, kemudian **Settings** di panel kiri, jika perlu. Gulir ke bawah ke daftar opsi **IoT Server** dan klik pada **Home Gateway**.

![IoT Server](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/iot-server.png)

### Langkah 4: Memverifikasi bahwa perangkat sekarang terdaftar dengan server Home Gateway.
Dari **Tablet**, klik tab **Desktop** > **IoT Monitor**, kemudian klik **Login**. Anda seharusnya melihat entri untuk ketiga perangkat IoT baru. Perluas entri untuk melihat detail perangkat. Cobalah mengontrol perangkat dan lihat hasilnya di ruang kerja.

![IoT Monitor](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/desktop-iot-monitor.png)

> Mungkin diperlukan satu atau dua menit bagi ketiga perangkat untuk mendaftar dengan server dan terdaftar di **IoT Monitor**.
{: .prompt-info}

## Bagian 4: Menambahkan Perangkat Bluetooth
Dalam bagian ini, Anda akan menambahkan sebuah speaker Bluetooth ke jaringan nirkabel. Anda akan menghubungkan pemutar musik portabel ke speaker tersebut.

### Langkah 1: Menambahkan Speaker Bluetooth ke Jaringan Nirkabel.
- Dalam kotak **Device-Type Selection**, klik **End Devices** > **Home**. Tambahkan perangkat **Bluetooth Speaker** ke ruang kerja.
- Perhatikan bahwa speaker secara otomatis terhubung ke **Home Gateway**. Setelah beberapa menit, speaker akan dikonfigurasi dengan alamat IP dari jaringan 192.168.25.x.
- Ubah Display Name speaker menjadi **Speaker**.
- Di tab **Config** untuk speaker, klik **Bluetooth** di panel kiri, kemudian aktifkan **Port Status** menjadi **On**.

### Langkah 2: Menambahkan Pemutar Media Portabel ke Jaringan Nirkabel.
- Dalam kotak **Device-Type Selection**, klik **End Devices** > **Home**. Tambahkan **Portable Music Player** ke ruang kerja.
- Perhatikan bahwa pemutar musik secara otomatis terhubung ke Home Gateway. Setelah beberapa menit, pemutar musik akan dikonfigurasi dengan alamat IP dari jaringan 192.168.25.x.
- Ubah Display Name menjadi **Music Player**.

### Langkah 3: Memasangkan Pemutar Musik dengan Speaker.
- Aktifkan **Port Status** Bluetooth menjadi **On**.
- Klik **Discover** di bawah Discoverable Devices, klik **Speaker**, klik **Pair**, dan kemudian klik **Yes**.
- Tahan tombol Alt dan klik **Music Player**. 

![IoT Monitor](assets/img/posts/2025-03-08-connect-devices-to-a-home-gateway-and-monitor-your-network/bluetooth-paired.png)

> Pastikan speaker pada komputer fisik Anda dalam keadaan menyala.
{: .prompt-tip} 

### Langkah 4: Menjelajahi Jaringan.
Silakan tambahkan lebih banyak perangkat berkabel dan nirkabel ke jaringan.

> Untuk perangkat IoT, tahan tombol Alt dan klik perangkat-perangkat tersebut untuk berinteraksi dengan mereka.
{: .prompt-tip} 

> Dengan tombol Alt ditekan, Anda dapat menyalakan Pemutar Musik, membuka Pintu, serta menyalakan Lampu dan Kipas.
{: .prompt-info} 

Jangan lupa bahwa Anda juga dapat mengontrol perangkat IoT dari aplikasi IoT Monitor di Smartphone atau Tablet.