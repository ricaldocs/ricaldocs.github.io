---
title: Create a Simple Network
description: Membangun jaringan sederhana di Packet Tracer dalam Logical Workspace.
categories: [Cisco Packet Tracer, Telco]
tags: [cisco packet tracer]
author: rical
last_modified_at: 2026-06-01
---

## Tujuan
Dalam aktivitas ini, Anda akan membangun jaringan sederhana di Packet Tracer dalam Logical Workspace.

- [Bagian 1: Membangun Jaringan Sederhana](https://ricaldocs.github.io/posts/create-a-simple-network/#bagian-1-membangun-jaringan-sederhana)
- [Bagian 2: Mengonfigurasi End Devices dan Memverifikasi Konektivitas](https://ricaldocs.github.io/posts/create-a-simple-network/#bagian-2-mengonfigurasi-end-devices-dan-memverifikasi-konektivitas)

## Instruksi 
Unduh berkas berikut dan buka di Cisco Packet Tracer: [Create_a_Simple_Network_pka.pka](/assets/posts/Create_a_Simple_Network_pka.pka)


## Bagian 1: Membangun Jaringan Sederhana
Dalam bagian ini, Anda akan membangun jaringan sederhana dengan menyebarkan dan menghubungkan perangkat jaringan di Logical Workspace.

### Langkah 1: Tambahkan perangkat jaringan ke ruang kerja.
Dalam langkah ini, Anda akan menambahkan sebuah PC, laptop, dan modem kabel ke Logical Workspace.

> Modem kabel adalah perangkat keras yang memungkinkan komunikasi dengan Internet Service Provider (ISP). Kabel koaksial dari ISP terhubung ke modem kabel, dan kabel Ethernet dari jaringan lokal juga terhubung. Modem kabel mengubah koneksi koaksial menjadi koneksi Ethernet.
{: .prompt-info}

Dengan menggunakan Device-Type Selection Box, tambahkan perangkat berikut ke ruang kerja. Kategori dan sub-kategori yang terkait dengan perangkat tersebut tercantum di bawah ini:

- **PC**: End Devices > End Devices > PC
- **Laptop**: End Devices > End Devices > Laptop
- **Cable Modem**: Network Devices > WAN Emulation > Cable Modem

### Langkah 2: Ubah nama tampilan perangkat jaringan.
- Untuk mengubah nama tampilan perangkat jaringan, klik ikon perangkat di Logical Workspace.
- Klik tab **Config** di jendela konfigurasi perangkat.
- Masukkan nama baru untuk perangkat yang baru ditambahkan ke dalam kolom Display Name: PC, Laptop, dan Cable Modem.

### Langkah 3: Tambahkan kabel fisik antara perangkat di ruang kerja.
Dengan menggunakan Device-Type Selection Box, tambahkan kabel fisik antara perangkat di ruang kerja.

- PC akan memerlukan kabel copper straight-through untuk terhubung ke router nirkabel. Dengan menggunakan Device-Type Selection Box, klik Connections (ikon petir). Pilih kabel copper straight-through di Device-Specific Selection Box dan sambungkan ke antarmuka **FastEthernet0** dari PC dan antarmuka **GigabitEthernet 1** dari router nirkabel.
- Router nirkabel akan memerlukan kabel copper cross-over untuk terhubung ke modem kabel. Pilih kabel copper cross-over di Device-Specific Selection Box dan sambungkan ke antarmuka internet dari router nirkabel dan antarmuka **Port 1** dari modem kabel.
- Modem kabel akan memerlukan kabel koaksial untuk terhubung ke internet cloud. Pilih kabel koaksial di Device-Specific Selection Box dan sambungkan ke antarmuka **Port 0** dari modem kabel dan antarmuka **Coaxial 7** dari internet cloud.

![Topologi](assets/img/posts/2025-03-10-create-a-simple-network/create-a-simple-network.png)
_Topologi Jaringan_

## Bagian 2: Mengonfigurasi End Devices dan Memverifikasi Konektivitas
Dalam bagian ini, Anda akan menghubungkan sebuah PC dan laptop ke router nirkabel. PC akan terhubung ke jaringan menggunakan kabel Ethernet. Untuk laptop, Anda akan mengganti Network Interface Card (NIC) Ethernet berkabel dengan NIC nirkabel dan menghubungkan laptop ke router secara nirkabel.

Setelah kedua perangkat akhir terhubung ke jaringan, Anda akan memverifikasi konektivitas ke cisco.srv. PC dan laptop masing-masing akan diberikan alamat IP (Internet Protocol). Internet Protocol adalah seperangkat aturan untuk pengaturan dan pengalamatan data di internet. Alamat IP digunakan untuk mengidentifikasi perangkat di jaringan dan memungkinkan perangkat untuk terhubung dan mentransfer data di jaringan.

### Langkah 1: Konfigurasi PC.
Anda akan mengonfigurasi PC untuk jaringan berkabel dalam langkah ini.

- Klik **PC**. Di tab **Desktop**, navigasikan ke **IP Configuration** untuk memverifikasi bahwa DHCP diaktifkan dan PC telah menerima alamat IP.

Pilih **DHCP** untuk judul IP Configuration jika Anda tidak melihat alamat IP untuk kolom IPv4 Adress. Tutup jendela IP Configuration setelah selesai. Amati proses saat PC menerima alamat IP dari server DHCP.

> DHCP adalah singkatan dari Dynamic Host Configuration Protocol. Protokol ini secara dinamis memberikan alamat IP kepada perangkat. Dalam jaringan sederhana ini, Wireless Router dikonfigurasi untuk memberikan alamat IP kepada perangkat yang meminta alamat IP. Jika DHCP dinonaktifkan, Anda perlu menetapkan alamat IP dan mengonfigurasi semua informasi yang diperlukan untuk berkomunikasi dengan perangkat lain di jaringan dan internet.
{: .prompt-info}

- Tutup **IP Configuration**. Di tab **Desktop**, klik **Command Prompt**.
- Di prompt, masukkan `ipconfig /all` untuk meninjau informasi pengalamatan IPv4 dari server DHCP. PC seharusnya telah menerima alamat IPv4 dalam rentang 192.168.0.x.

> Ada dua jenis alamat IP: IPv4 dan IPv6. Alamat IPv4 (Internet Protocol Version 4) adalah deretan angka dalam bentuk x.x.x.x seperti yang telah Anda gunakan dalam lab ini. Seiring dengan pertumbuhan internet, kebutuhan akan lebih banyak alamat IP menjadi penting. Oleh karena itu, IPv6 (Internet Protocol Version 6) diperkenalkan pada akhir 1990-an untuk mengatasi keterbatasan IPv4. Rincian pengalamatan IPv6 berada di luar cakupan aktivitas ini.
{: .prompt-info}

- Uji konektivitas ke **cisco.srv** dari PC. Dari command prompt, keluarkan perintah `ping cisco.srv`. Mungkin diperlukan beberapa detik untuk ping kembali. Empat balasan harus diterima.

### Langkah 2: Konfigurasi Laptop.
Dalam langkah ini, Anda akan mengonfigurasi Laptop untuk mengakses jaringan nirkabel.

- Klik **Laptop**, dan pilih tab **Physical**.
- Di tab **Physical**, Anda perlu menghapus modul Ethernet copper dan menggantinya dengan modul Wireless WPC300N.

    1. Matikan **Laptop** dengan mengklik tombol daya di sisi laptop.
    2. Hapus modul Ethernet copper yang saat ini terpasang dengan mengklik modul tersebut di sisi laptop dan menyeretnya ke panel **MODULES** di sebelah kiri jendela laptop.
    3. Pasang modul nirkabel **WPC300N** dengan mengkliknya di panel **MODULES** dan menyeretnya ke port modul kosong di sisi Laptop.
    4. Nyalakan **Laptop** dengan mengklik tombol daya Laptop lagi.

    ![WPC300N](assets/img/posts/2025-03-10-create-a-simple-network/wpc300n.png)

- Dengan modul nirkabel terpasang, sambungkan Laptop ke jaringan nirkabel. Klik tab **Desktop** dan pilih **PC Wireless**.
- Pilih tab **Connect**. Setelah sedikit penundaan, jaringan nirkabel **HomeNetwork** akan terlihat dalam daftar jaringan nirkabel. Klik **Refresh** jika perlu untuk melihat daftar jaringan yang tersedia. Pilih **HomeNetwork**. Klik **Connect**.

![PC Wireless](assets/img/posts/2025-03-10-create-a-simple-network/pc-wireless.png)

- Tutup **PC Wireless**. Pilih **Web Browser** di tab Desktop.
- Di Web Browser, navigasikan ke **cisco.srv**.

## Refleksi
Sekarang setelah Anda memverifikasi konektivitas ke cisco.srv, gunakan perintah ipconfig dari Command Prompt untuk mengisi tabel pengalamatan IP di bawah ini:

| Perangkat | Alamat IP                     | Subnet Mask                     | Default Gateway                     |
| --------- | ----------------------------- | ------------------------------- | ----------------------------------- |
| PC        | [Isi dengan alamat IP PC]     | [Isi dengan subnet mask PC]     | [Isi dengan default gateway PC]     |
| Laptop    | [Isi dengan alamat IP Laptop] | [Isi dengan subnet mask Laptop] | [Isi dengan default gateway Laptop] |

Alamat IP untuk perangkat akhir dapat berkisar dari 192.168.0.2 hingga 192.168.0.254. Setiap NIC akan mendapatkan alamat IP unik dalam jaringan yang sama.

Subnet mask digunakan untuk membedakan antara bagian ID host dan bagian ID jaringan dari alamat IP. Anda dapat mengaitkan alamat IP dengan alamat jalan Anda. Subnet mask mendefinisikan panjang nama jalan. Bagian jaringan dari alamat adalah jalan Anda, yaitu 192.168.0. Nomor rumah adalah port host dari alamat IP. Untuk alamat IP 192.168.0.2, nomor rumahnya adalah 2 dan jalannya adalah 192.168.0. Jika ada lebih dari satu rumah di jalan yang sama, misalnya, nomor rumah 3, maka akan memiliki alamat 192.168.0.3. Jumlah maksimum rumah di jalan ini adalah 253, berkisar dari 2 hingga 254.

Default gateway dapat dianalogikan dengan persimpangan jalan. Lalu lintas dari jalan 192.168.0 harus keluar melalui persimpangan menuju jalan lain. Jalan lain adalah jaringan lain. Dalam jaringan ini, default gateway adalah router nirkabel yang mengarahkan lalu lintas dari jaringan lokal ke modem kabel, dan lalu lintas tersebut kemudian dikirim ke ISP.