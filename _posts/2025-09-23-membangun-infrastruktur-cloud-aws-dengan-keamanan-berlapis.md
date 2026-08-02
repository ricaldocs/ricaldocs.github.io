---
title: Membangun Infrastruktur Cloud AWS dengan Keamanan Berlapis
description: Implementasi praktis Amazon VPC, segmentasi subnet, Bastion Host untuk akses terjamin, NAT Gateway untuk koneksi internet terbatas, serta konfigurasi NACL, Security Group, VPC Peering, dan IPv6.
categories: [Cloud & On-Premise, AWS]
tags: [cloud computing, aws]
author: rical
last_modified_at: 2026-06-01
---

## Pembuatan Amazon VPC

### Mengakses Layanan VPC

Proses konfigurasi dimulai dengan mengakses konsol layanan Amazon VPC melalui AWS Management Console. Pengguna dapat membuat VPC baru dengan menentukan parameter jaringan sesuai kebutuhan.

![Dashboard VPC](../assets/img/posts/cloud/amazon-vpc/vpc-dashboard.png)

### Konfigurasi Blok CIDR

Blok CIDR (Classless Inter-Domain Routing) menentukan rentang alamat IP privat yang akan digunakan dalam VPC. AWS mendukung blok CIDR antara /16 hingga /28, dengan /16 menyediakan hingga 65.536 alamat IP. **Pakar keamanan merekomendasikan** penggunaan rentang IP privat RFC 1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16).

> [**IP Address Guide**](https://www.ipaddressguide.com/cidr)

![Kalkulator CIDR](../assets/img/posts/cloud/amazon-vpc/cidr-web.png)

### Pengaturan VPC

Pada tahap konfigurasi, pengguna menentukan nama VPC dan blok CIDR yang diinginkan. Opsi tambahan termasuk penyediaan alamat IPV6 CIDR dan penentuan tenancy - default untuk shared hardware atau dedicated untuk isolasi penuh.

![Pengaturan VPC](../assets/img/posts/cloud/amazon-vpc/vpc-settings.png)

### Detail VPC yang Dibuat

Setelah proses pembuatan selesai, sistem menampilkan detail VPC termasuk VPC ID, status, dan blok CIDR yang terkait. **VPC ini berfungsi sebagai container logis** untuk semua sumber daya jaringan.

![Detail VPC](../assets/img/posts/cloud/amazon-vpc/vpc-details.png)

### Modifikasi Blok CIDR

Fleksibilitas VPC memungkinkan penambahan blok CIDR tambahan setelah pembuatan melalui opsi edit CIDRs, memungkinkan perluasan ruang alamat IP jika diperlukan tanpa mengganggu operasi yang berjalan.

![Edit CIDR](../assets/img/posts/cloud/amazon-vpc/edit-cidrs.png)

## Konfigurasi Subnet

### Mengakses Menu Subnet

Subnet merupakan segmen jaringan dalam VPC yang mengelompokkan sumber daya berdasarkan kebutuhan keamanan dan fungsi. Untuk membuat subnet, akses menu Subnets dalam layanan VPC.

![Dashboard Subnet](../assets/img/posts/cloud/amazon-vpc/subnet/subnets-dashboard.png)

### Membuat Subnet Baru

Pilih VPC target yang telah dibuat sebelumnya, kemudian tentukan nama subnet, Availability Zone, dan blok CIDR yang merupakan subset dari blok CIDR VPC. **Setiap subnet harus berada dalam satu Availability Zone**.

![Buat Subnet](../assets/img/posts/cloud/amazon-vpc/subnet/create-subnet.png)

### Arsitektur Subnet yang Direkomendasikan

Desain jaringan yang optimal mengikuti prinsip **high availability** dengan minimal empat subnet yang disebar across dua Availability Zone:

- **Public Subnet A**: Untuk resources yang memerlukan akses internet langsung di AZ A
- **Public Subnet B**: Untuk resources yang memerlukan akses internet langsung di AZ B
- **Private Subnet A**: Untuk resources backend yang terisolasi di AZ A
- **Private Subnet B**: Untuk resources backend yang terisolasi di AZ B

![Public Subnet A](../assets/img/posts/cloud/amazon-vpc/subnet/public-subnet-a.png)
![Public Subnet B](../assets/img/posts/cloud/amazon-vpc/subnet/public-subnet-b.png)
![Private Subnet A](../assets/img/posts/cloud/amazon-vpc/subnet/private-subnet-a.png)
![Private Subnet B](../assets/img/posts/cloud/amazon-vpc/subnet/private-subnet-b.png)

### Hasil Konfigurasi Subnet

Setelah proses selesai, sistem menampilkan daftar semua subnet yang telah dibuat dalam VPC. **Infrastruktur multi-AZ ini memastikan ketahanan terhadap kegagalan satu availability zone**.

![Semua Subnet](../assets/img/posts/cloud/amazon-vpc/subnet/all-subnet.png)

## Internet Gateway dan Tabel Rute

### Persiapan Instance EC2

Untuk menguji konfigurasi jaringan, buat instance EC2 baru dengan memilih VPC dan subnet yang sesuai. **Security group harus dikonfigurasi dengan prinsip least privilege** - hanya mengizinkan akses inbound sesuai protokol yang diperlukan.

![Buat Instance](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/create-instance.png)
![Pengaturan Jaringan](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/network-settings.png)
![Aturan Security Group](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/inbound-security-group-rules.png)

### Mengaktifkan Auto-assign IP Publik

Pada subnet publik, aktifkan opsi "Enable auto-assign public IPv4 address" untuk memberikan alamat IP publik secara otomatis kepada instance yang diluncurkan. **Fitur ini krusial untuk resources yang memerlukan akses inbound dari internet**.

![Edit Subnet Public A](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/edit-subnet-settings-public-a.png)
![Auto-assign IP Subnet Public A](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/auto-assign-ip-subnet-public-a.png)

> Implementasikan prosedur serupa untuk PublicSubnetB untuk konsistensi konfigurasi.
{: .prompt-tip}

Pada keluaran yang dihasilkan, tampak bahwa instance telah diprovisi dengan alamat IP publik, namun konektivitas masih terhambat.

![IP Public](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/ip-public.png)

> **Troubleshooting Required**: Upaya koneksi ke server menggunakan layanan EC2 Instance Connect tidak berhasil. Investigasi mengungkapkan akar masalah - Internet Gateway belum terpasang pada VPC, mengisolasi jaringan dari internet.
{: .prompt-info}

### Konfigurasi Internet Gateway

Internet Gateway (IGW) merupakan komponen VPC horizontal yang scalable dan highly available, memungkinkan komunikasi antara instance dalam VPC dan internet. **Setiap VPC hanya mendukung satu IGW**.

![Internet Gateways VPC](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/internat-gateways-vpc.png)
![Buat IGW](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/create-igw.png)
![Attach ke VPC](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/attach-to-vpc.png)
![IGW Terattach](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/igw-attached.png)

### Konfigurasi Tabel Rute

Tabel rute mengandung set rules (routes) yang menentukan kemana lalu lintas jaringan diarahkan. **Pisahkan tabel rute untuk subnet publik dan privat** untuk kontrol granuler atas routing traffic.

![Tab Tabel Rute](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/route-tables-tab.png)
![Buat Tabel Rute Publik](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/create-public-route-table.png)
![Buat Tabel Rute Privat](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/create-private-route-table.png)

### Asosiasi Subnet dengan Tabel Rute

Asosiasikan subnet publik dengan tabel rute publik, dan subnet privat dengan tabel rute privat. **Setiap subnet hanya bisa terkait dengan satu route table**, namun satu route table bisa terkait multiple subnets.

![Asosiasi Subnet Publik](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/add-public-subnet.png)
![Asosiasi Subnet Privat](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/add-private-subnet.png)
![Asosiasi Eksplisit Subnet](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/explicit-subnet-associations.png)

### Konfigurasi Rute ke Internet

Pada tabel rute publik, tambahkan rute yang mengarahkan lalu lintas internet (0.0.0.0/0) ke Internet Gateway. **Route ini yang memberdayakan konektivitas outbound ke internet**.

![Edit Rute](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/edit-routes.png)

### Verifikasi Konektivitas

Setelah konfigurasi lengkap, instance EC2 dalam subnet publik berhasil terhubung ke internet melalui EC2 Instance Connect. **Infrastruktur sekarang fully operational dengan konektivitas terkontrol**.

![Hasil Konektivitas](../assets/img/posts/cloud/amazon-vpc/internet-gateway-and-route-tables/hasil.png)

> Dengan menyelesaikan langkah-langkah di atas, pengguna berhasil membangun infrastruktur jaringan AWS yang aman, terisolasi, dan highly available dengan konektivitas internet yang terkontrol melalui Amazon VPC, subnet, Internet Gateway, dan tabel rute. Arsitektur ini memberikan fondasi robust untuk deployment aplikasi production dengan resilience terhadap kegagalan zona availability.

## Implementasi Bastion Host

### Konfigurasi Awal Bastion Host

Instance EC2 yang sebelumnya bernama "MyServer" diubah menjadi "BastionHost" sebagai titik akses terkontrol yang menjadi satu-satunya gerbang menuju "PrivateInstance" dalam VPC.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/rename-myserver.png)

### Pembuatan Key Pair

Dibuat key pair khusus berformat `.pem` untuk otentikasi aman ke PrivateInstance. Kunci RSA ini menjadi kunci digital yang harus dijaga kerahasiaannya.

> Format `.pem` khusus untuk sistem operasi Linux, sementara Windows menggunakan format `.ppk`
{: .prompt-info}

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/create-key-pair.png)

### Pembuatan Private Instance

PrivateInstance dibuat tanpa alamat IP publik, mengisolasi sepenuhnya dari internet. **Strategi zero-trust ini memastikan** tidak ada akses langsung dari luar VPC.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/create-private-instance.png)

### Penetapan Key Pair

Key pair yang telah dibuat ditautkan ke PrivateInstance, menerapkan **model otentikasi berbasis kriptografi asimetris** yang lebih aman daripada password.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/use-key-pair.png)

### Konfigurasi Jaringan

Instance dikonfigurasi berada dalam subnet privat dengan routing terbatas. **Arsitektur ini memastikan** semua traffic harus melalui BastionHost yang berfungsi sebagai jump server.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/network-settings.png)

### Verifikasi Konfigurasi

PrivateInstance terbukti tidak memiliki IP publik, mengonfirmasi isolasi jaringan yang berhasil. **Hanya koneksi internal VPC** yang diperbolehkan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/instance-summary.png)

### Inisiasi Koneksi

Akses BastionHost dilakukan melalui EC2 Instance Connect, menyediakan **antarmuka berbasis browser** yang aman tanpa perlu software SSH tambahan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/instance-connect.png)

### Proses Autentikasi

Upaya koneksi SSH langsung ke PrivateInstance ditolak sistem keamanan:

```
ssh ubuntu@10.0.30.19
// Respons: Permission denied (publickey)
```

> Penolakan akses mengonfirmasi efektivitas konfigurasi keamanan. PrivateInstance benar-benar terisolasi tanpa kunci yang tepat.
{: .prompt-info}

### Penyiapan Kunci Akses

File kunci privat dipersiapkan di BastionHost dengan langkah-langkah keamanan ketat:

```bash
nano KeyPairPrivate.pem
# Salin konten kunci yang didownload
chmod 400 KeyPairPrivate.pem  # Batasi izin file
```

**Pembatasan izin 400 memastikan** hanya pemilik yang dapat membaca file kunci.

### Koneksi Berhasil

Akses ke PrivateInstance berhasil dengan spesifikasi kunci pribadi:

```
ssh ubuntu@10.0.30.19 -i KeyPairPrivate.pem
// Respons: Welcome to Ubuntu 24.04.3 LTS
```

## NAT Gateway: Memberdayakan Instance Privat dengan Akses Internet Terkontrol

PrivateInstance dalam VPC Amazon Web Services (AWS) telah terisolasi dengan baik melalui bastion host, namun **menghadapi keterbatasan kritis** - tidak dapat mengakses internet untuk update keamanan dan download package.

### Langkah Konfigurasi NAT Gateway

#### Akses Layanan VPC

Dashboard layanan VPC diakses melalui konsol AWS, dengan navigasi ke menu NAT gateways untuk memulai konfigurasi.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nat-gateways/vpc-dashboard.png)

#### Pembuatan NAT Gateway

Tombol **Create NAT Gateway** diaktifkan untuk memulai proses deployment gateway baru. **NAT Gateway berfungsi sebagai translator** yang memungkinkan instance privat menginisiasi koneksi keluar.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nat-gateways/create-nate-gateways.png)

#### Verifikasi Status

Status **Available** mengonfirmasi NAT Gateway siap beroperasi. **Komponen highly available** ini di-deploy secara redundan dalam Availability Zone.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nat-gateways/nat-gateway-details.png)

#### Konfigurasi Routing

Tabel rute privat diedit untuk mengintegrasikan NAT Gateway:

- Pilih **Route Tables**
- Pilih **PrivateRouteTable**
- Klik **Edit routes**

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nat-gateways/private-route-table.png)

#### Penambahan Rute Internet

Entri rute baru ditambahkan yang mengarahkan traffic internet (0.0.0.0/0) ke NAT Gateway. **Konfigurasi ini memberdayakan** PrivateInstance mengakses internet tanpa exposure langsung.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nat-gateways/edit-routes.png)

### Hasil Verifikasi Konektivitas

Setelah konfigurasi selesai, PrivateInstance berhasil terhubung ke internet dengan latency optimal:

```
ubuntu@ip-10-0-30-19:~$ ping google.com
PING google.com (172.253.115.113) 56(84) bytes of data.
64 bytes from bg-in-f113.1e100.net (172.253.115.113): icmp_seq=1 ttl=105 time=2.36 ms
64 bytes from bg-in-f113.1e100.net (172.253.115.113): icmp_seq=2 ttl=105 time=1.86 ms
--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3006ms
rtt min/avg/max/mdev = 1.858/1.983/2.356/0.214 ms
```

## NACL dan Security Group: Pertahanan Berlapis untuk Bastion Host

### Konfigurasi Keamanan Multi-Layer

#### Persiapan Awal

Pastikan BastionHost terhubung ke internet sebelum memulai konfigurasi keamanan berlapis.

#### Audit Security Group

Instance BastionHost diperiksa dan Security Group (SG) yang terkait diidentifikasi. **Security Group berfungsi sebagai firewall tingkat instance** yang stateful.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/security-details.png)

#### Penambahan Rule HTTP

Security Group diperbarui dengan menambahkan protokol HTTP (port 80) pada inbound rules. **Port 80 diperlukan** untuk layanan web Apache2.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/edit-inbound-rules.png)

#### Deployment Apache2

Web server Apache2 diinstal pada BastionHost menggunakan perintah:
```bash
sudo apt update && sudo apt install -y apache2
```

#### Aktivasi Layanan

Apache2 diaktifkan dan dimulai sebagai service:
```bash
sudo systemctl enable apache2 && sudo systemctl start apache2
```

#### Kustomisasi Halaman Web

Halaman default Apache dimodifikasi untuk identifikasi:
```bash
sudo su
echo "Welcome to Ricalnet" > /var/www/html/index.html
```

#### Verifikasi Akses Web

Akses web berhasil diverifikasi melalui browser menggunakan alamat IP public BastionHost.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/browser.png)

#### Konfigurasi Network ACL

Network Access Control List (NACL) dikonfigurasi sebagai **firewall stateless tingkat subnet**:

- Ubah nama NACL untuk identifikasi jelas  
   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/rename%20nacl.png)
- Tambahkan aturan penolakan HTTP (port 80) pada DefaultNACL  
   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/edit-inbound-rules-deny.png)

#### Testing Blokir NACL

Akses web gagal akibat aturan NACL yang memblokir HTTP, **membuktikan efektivitas NACL** sebagai lapisan keamanan tambahan.

#### Penyesuaian Ururan Rule

Urutan aturan NACL disesuaikan dengan mengubah rule number ke nilai lebih tinggi, memanfaatkan **mekanisme evaluasi berurutan NACL**.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/edit-rule-number.png)

#### Verifikasi Akhir

Website kembali dapat diakses karena NACL mengevaluasi aturan berdasarkan nomor terkecil terlebih dahulu.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/nacl-dan-security-group/browser.png)

> **Arsitektur Keamanan Berlapis**: Kombinasi Security Group (stateful, instance-level) dan NACL (stateless, subnet-level) menciptakan defense-in-depth. Security Group mengizinkan HTTP, sementara NACL dapat memblokirnya berdasarkan urutan rule number.
{: .prompt-info}

## VPC Peering: Menghubungkan Dunia Terisolasi dengan Aman

### Persiapan Infrastruktur Jaringan

#### Standardisasi Penamaan VPC

Dashboard VPC diakses melalui konsol AWS. VPC default diubah namanya menjadi "DefaultVPC" untuk konsistensi penamaan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/rename-vpc.png)

### Deployment Instance Baru

Instance baru diluncurkan dalam DefaultVPC dengan konfigurasi spesifik:

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/launch-an-instance.png)

- **Key Pair**: Dipilih key pair yang sesuai untuk otentikasi

   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/key-pair.png)

- **Network Settings**: Dipastikan memilih DefaultVPC untuk isolasi jaringan

   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/network-settings.png)

### Verifikasi Konektivitas Awal

#### Testing Lokal Bastion Host

Koneksi lokal BastionHost diuji menggunakan curl:

```
ubuntu@ip-10-0-0-183:~$ curl 10.0.0.183:80
// Response: Welcome to RicalNet 
```

### Testing Cross-VPC Awal

Dari InstanceDefaultVPC, akses ke BastionHost di VPC lain diuji:

```
ubuntu@ip-172-31-18-213:~$ curl 10.0.0.183:80
```

> **Diagnosis Jaringan**: Koneksi cross-VPC belum berhasil, mengonfirmasi isolasi jaringan antara VPC yang berbeda sebelum peering
{: .prompt-info}

### Membangun Jembatan VPC Peering

#### Inisiasi Koneksi Peering

Layanan VPC → Peering Connections → Create Peering Connection diakses untuk memulai proses.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/vpc-dashboard.png)

#### Konfigurasi Peering

Pengaturan koneksi dikonfigurasi:

- **Requester VPC**: DemoVPC
- **Accepter VPC**: DefaultVPC

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/peering-connection-settings.png)

#### Penyelesaian Koneksi

Request koneksi di-accept untuk menyelesaikan proses pembangunan jembatan jaringan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/accept-request.png)

### Konfigurasi Routing Terpadu

#### Standardisasi Tabel Rute

Nama tabel rute VPC default diubah untuk identifikasi yang lebih jelas.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/rename-route-tables.png)

> **Pentingnya Dokumentasi CIDR**: Informasi CIDR setiap VPC harus dicatat untuk perencanaan routing dan menghindari conflict alamat IP.
{: .prompt-info}

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/cidr-info.png)

#### PublicRouteTable DemoVPC

- Edit rute existing
- Tambahkan rute ke CIDR DefaultVPC (172.31.0.0/16) melalui koneksi peering
   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/public-route-table.png)

#### DefaultVPCMainRouteTable

- Edit rute default
- Tambahkan rute ke CIDR DemoVPC (10.0.0.0/16) melalui koneksi peering
   ![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/vpc-peering/DefaultVPCMainRouteTable.png)

### Verifikasi Keberhasilan Integrasi

Koneksi akhir dari InstanceDefaultVPC berhasil:

```
ubuntu@ip-172-31-18-213:~$ curl 10.0.0.183:80
// Response: Welcome to RicalNet
```

> **Pencapaian Arsitektur**: VPC Peering berhasil menghubungkan dua VPC yang terisolasi, memungkinkan komunikasi langsung menggunakan IP private antar instance di VPC berbeda tanpa traversing internet.

## IPv6: Melangkah Menuju Masa Depan Internet dengan Dual-Stack

### Alokasi Blok IPv6 untuk VPC

#### Assessment Kesiapan IPv6

Dashboard layanan VPC dibuka dan VPC target dipilih. Monitoring menunjukkan **IPv6 belum aktif**, mengindikasikan ketergantungan penuh pada IPv4.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/cidrs-tab.png)

#### Inisiasi Alokasi IPv6

Opsi "Edit CIDRs" dipilih dari menu untuk memulai proses alokasi IPv6.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/edit-cidrs.png)

#### Penyediaan Blok IPv6

"Add IPv6 CIDR" diaktifkan, dan AWS secara otomatis menyediakan blok alamat IPv6 /56 untuk VPC. **Blok /56 menyediakan 256 subnet IPv6**, kapasitas yang sangat besar untuk pertumbuhan masa depan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/add-ipv6-cidr.png)

#### Konfirmasi Dual-Stack

VPC kini memiliki kedua blok alamat, IPv4 dan IPv6, mengimplementasikan **arsitektur dual-stack** yang memungkinkan transisi seamless.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/ipv4-and-ipv6-cidrs.png)

### Distribusi IPv6 ke Subnet

#### Navigasi ke Subnet

Menu "Subnets" diakses dari layanan VPC untuk distribusi alamat IPv6 ke level subnet.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/subnets.png)

#### Alokasi CIDR IPv6 Subnet

Subnet target dipilih dan "Edit IPv6 CIDRs" diaktifkan untuk alokasi blok IPv6 khusus subnet.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/edit-ipv6-cidrs.png)

Blok CIDR IPv6 yang telah dialokasikan sebelumnya ditambahkan ke pengaturan subnet.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/edit-subnet-settings.png)

### Aktivasi Auto-Assignment IPv6

#### Enable Automatic Addressing

Opsi "Enable auto-assign IPv6 address" diaktifkan pada pengaturan subnet. **Fitur ini memastikan** instance baru secara otomatis mendapatkan alamat IPv6 saat diluncurkan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/enable-auto-assing-ipv6.png)

### Aktualisasi IPv6 pada BastionHost

#### Management IP Address

Instance "BastionHost" yang berjalan diperbarui melalui tab "Networking" dengan memilih "Manage IP addresses".

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/instance-networking-manage-ip-address.png)

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/manage-ip--addresses.png)

#### Verifikasi Alamat IPv6

Instance BastionHost berhasil mendapatkan alamat IPv6 publik baru, **melengkapi konektivitas dengan dual-stack capability**.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/ipv6-address.png)

### Penyempurnaan Keamanan IPv6

#### Audit Security Group

"Security Groups" yang terkait dengan instance BastionHost dibuka untuk penyesuaian aturan keamanan.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/security-groups.png)

#### Ekstensi Aturan Keamanan

Aturan masuk (inbound rules) diperbarui untuk mencerminkan izin yang sama yang sebelumnya hanya berlaku untuk IPv4, sekarang diperluas untuk protokol IPv6.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/edit-inbound-rules.png)

Aturan masuk yang telah diperbarui menunjukkan koneksi SSH yang diizinkan baik dari IPv4 maupun IPv6.

![](../assets/img/posts/cloud/amazon-vpc/bastion-hosts/ipv6-for-vpc/inbound-rules.png)

> **Transformasi Lengkap**: Dengan menyelesaikan seluruh langkah di atas, infrastruktur cloud telah bertransformasi menjadi arsitektur dual-stack (IPv4 dan IPv6) yang siap menghadapi masa depan internet dan memenuhi persyaratan compliance modern.