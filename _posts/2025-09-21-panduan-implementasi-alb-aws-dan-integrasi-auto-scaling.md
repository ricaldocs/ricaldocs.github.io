---
title: Panduan Implementasi Application Load Balancer AWS dan Integrasi Auto Scaling
description: Pelajari cara implementasi Application Load Balancer (ALB) AWS secara step-by-step. Panduan komprehensif mencakup konfigurasi EC2, setup Target Group, monitoring health check, hingga integrasi Auto Scaling Group untuk arsitektur cloud yang scalable dan highly available.
categories: [Cloud & On-Premise, AWS]
tags: [cloud computing, aws]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Application Load Balancer (ALB) merupakan layanan penyeimbang beban tingkat aplikasi yang disediakan oleh Amazon Web Services (AWS). Layanan ini beroperasi pada lapisan ketujuh model OSI dan dirancang untuk mendistribusikan lalu lintas aplikasi web secara dinamis across multiple target, seperti instance Amazon EC2, kontainer, dan alamat IP.

## Konfigurasi Instance EC2

### Pembuatan Instance Ganda
Proses dimulai dengan membuat dua instance EC2 secara simultan melalui AWS Management Console. Konfigurasi ini memastikan ketersediaan tinggi dan mendukung arsitektur fault-tolerant.

![Antarmuka Pembuatan instance EC2](../assets/img/posts/cloud/application-load-balancer/create-instance.png)
_Antarmuka pembuatan instance EC2 pada AWS Management Console_

### Pengaturan Jaringan dan Key Pair
Pada tahap konfigurasi jaringan, penting untuk memastikan instance terletak dalam Virtual Private Cloud (VPC) yang sesuai dengan pengaturan keamanan yang diperlukan. Pemilihan key pair yang tepat diperlukan untuk mengamankan akses SSH.

![Pengaturan Jaringan dan Key Pair](../assets/img/posts/cloud/application-load-balancer/network-settings.png)
_Konfigurasi pengaturan jaringan dan pemilihan key pair_

### Konfigurasi Data Pengguna
User data digunakan untuk melakukan otomatisasi konfigurasi instance saat proses boot. Skrip berikut menginstal dan mengonfigurasi server web Apache:

```bash
#!/bin/bash

apt-get update -y
apt-get upgrade -y

apt-get install -y apache2

systemctl enable apache2
systemctl start apache2

echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html

systemctl restart apache2
```

### Penamaan dan Pengelompokan Instance
Pemberian nama yang deskriptif pada setiap instance memudahkan identifikasi dan manajemen dalam lingkungan dengan banyak sumber daya.

![Modifikasi Penamaan Instance](../assets/img/posts/cloud/application-load-balancer/edit-instance.png)
_Proses pemberian nama pada instance EC2_

### Konfigurasi Security Group
Security Group harus dikonfigurasi untuk mengizinkan lalu lintas HTTP pada port 80 guna memastikan akses web yang tepat.

![Aturan Masuk Security Group](../assets/img/posts/cloud/application-load-balancer/inbound-rules.png)
_Konfigurasi aturan masuk untuk lalu lintas HTTP_

## Implementasi Application Load Balancer

### Inisiasi Load Balancer
ALB dibuat melalui konsol AWS dengan memilih layanan Load Balancer.

![Antarmuka konsol Load Balancer](../assets/img/posts/cloud/application-load-balancer/create-load-balancer.png)
_Antarmuka konsol Load Balancer_

### Seleksi Tipe Load Balancer
Application Load Balancer dipilih karena kemampuannya menangani lalu lintas HTTP/HTTPS dan mendukung fitur advanced routing.

![Pemilihan Application Load Balancer](../assets/img/posts/cloud/application-load-balancer/select-alb.png)
_Antarmuka pemilihan jenis load balancer pada AWS_

### Penamaan dan Zona Ketersediaan
ALB memerlukan penamaan yang unik dan harus diletakkan pada minimal dua Availability Zone (AZ) berbeda untuk memastikan redundansi dan ketersediaan tinggi.

![Penamaan ALB](../assets/img/posts/cloud/application-load-balancer/load-balancer-name.png)
_Proses penamaan ALB_

![Pemilihan AZ](../assets/img/posts/cloud/application-load-balancer/select-az.png)
_Seleksi Availability Zone_


### Konfigurasi Security Group untuk ALB
Security Group khusus dibuat untuk ALB guna mengontrol lalu lintas yang diizinkan mengakses load balancer.

![Pembuatan Security Group Baru](../assets/img/posts/cloud/application-load-balancer/create-new-sg.png)
_Pembuatan Security Group khusus untuk Application Load Balancer_

### Pembuatan Target Group
Target Group berfungsi sebagai kelompok tujuan yang menerima lalu lintas dari ALB. Konfigurasi meliputi penentuan protokol, port, dan pemeriksaan kesehatan.

![_Antarmuka konfigurasi Listeners and routing_](../assets/img/posts/cloud/application-load-balancer/create-tg.png)
_Antarmuka konfigurasi Listeners and routing_

![_Antarmuka konfigurasi Target Group_](../assets/img/posts/cloud/application-load-balancer/create-tg-name.png)
_Antarmuka konfigurasi Target Group_

### Registrasi Target
Instance EC2 yang telah dibuat didaftarkan sebagai target dalam Target Group.

![Pendaftaran Target](../assets/img/posts/cloud/application-load-balancer/include-as-pending-below.png)
_Proses registrasi instance EC2 sebagai target dalam Target Group_

![Create target group](../assets/img/posts/cloud/application-load-balancer/review-targets.png)
_Proses registrasi instance EC2 sebagai target dalam Target Group_

### Penyelesaian Konfigurasi ALB
Setelah Target Group berhasil dibuat, ALB dikonfigurasi untuk mengarahkan lalu lintas ke target group tersebut.

![Penghubungan ALB dengan Target Group](../assets/img/posts/cloud/application-load-balancer/select-alb-tg.png)
_Penyelesaian konfigurasi dengan menghubungkan ALB ke Target Group_

## Validasi dan Pengujian

### DNS Endpoint ALB
Setelah berhasil dibuat, ALB menyediakan endpoint DNS yang digunakan untuk mengakses aplikasi. Endpoint ini akan secara otomatis mendistribusikan lalu lintas ke instance yang sehat.

![Endpoint DNS ALB](../assets/img/posts/cloud/application-load-balancer/dns-alb.png)
_Endpoint DNS yang dihasilkan untuk mengakses Application Load Balancer_

### Pengujian Load Balancing
Akses berulang ke endpoint DNS akan menunjukkan respons dari instance, membuktikan bahwa lalu lintas didistribusikan secara acak (round-robin).

![Respons dari Berbagai Instance](../assets/img/posts/cloud/application-load-balancer/ip-alb.png)
_Hasil akses yang menunjukkan respons dari hostname instance_

### Uji Ketersediaan Tinggi
Untuk menguji kemampuan failover, salah satu instance dihentikan. ALB secara otomatis mendeteksi perubahan status kesehatan dan mengalihkan lalu lintas ke instance yang masih berjalan.

![Penghentian Salah Satu Instance](../assets/img/posts/cloud/application-load-balancer/stop-instance.png)
_Proses penghentian (stop) salah satu instance EC2_

### Monitoring Status Kesehatan
Target Group secara kontinu memantau status kesehatan target. instance yang dihentikan akan menunjukkan status tidak digunakan (Unused), sementara instance lain tetap melayani lalu lintas.

![Status Kesehatan Target](../assets/img/posts/cloud/application-load-balancer/health-status.png)
_Tampilan status kesehatan target dalam Target Group_

## Pemulihan dan Kesimpulan
Setelah instance yang dihentikan diaktifkan kembali, ALB secara otomatis akan mendeteksi pemulihan status kesehatan dan kembali memasukkan instance tersebut ke dalam rotasi layanan. Mekanisme ini menunjukkan kemampuan ALB dalam menjaga ketersediaan layanan secara otomatis tanpa intervensi manual.

## ACF Lab: Scale and Load Balance Your Architecture

### Arsitektur awal

![alt text](../assets/img/posts/cloud/application-load-balancer/aws-lab/starting-architecture.png)

### Arsitektur akhir

![alt text](../assets/img/posts/cloud/application-load-balancer/aws-lab/final-architecture.png)

### Tugas 1: Membuat AMI untuk Auto Scaling

Dalam tugas ini, Anda akan membuat AMI dari Web Server 1 yang sudah ada. Ini akan menyimpan konten disk boot sehingga instance baru dapat diluncurkan dengan konten yang identik.

1.  Di Konsol Manajemen AWS, pada kotak pencarian di samping **Services**, cari dan pilih **EC2**.
2.  Di panel navigasi kiri, pilih **Instances**.
3.  Pertama, Anda akan memastikan bahwa instance sedang berjalan.

    >  Tunggu hingga **Status Checks** untuk Web Server 1 menampilkan **2/2 checks passed**. Jika perlu, pilih **refresh** untuk memperbarui status. Anda sekarang akan membuat AMI berdasarkan instance ini.
    {: .prompt-info}

4.  Pilih **Web Server 1**.
5.  Pada menu **Actions**, pilih **Image and templates** > **Create image**, lalu konfigurasikan:
    *   **Image name**: `WebServerAMI`
    *   **Image description**: `Lab AMI for Web Server`
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 18-51-54.png>)
        
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 18-54-13.png>)

6.  Pilih **Create image**
7.  Spanduk konfirmasi akan menampilkan ID AMI untuk AMI baru Anda.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 18-57-59.png>)

8.  Anda akan menggunakan AMI ini saat meluncurkan grup Auto Scaling nanti di lab.

### Tugas 2: Membuat Load Balancer

Dalam tugas ini, Anda pertama akan membuat target group dan kemudian membuat load balancer yang dapat menyeimbangkan lalu lintas di beberapa instance EC2 dan Availability Zone.

1.  Di panel navigasi kiri, pilih **Target Groups**.

    > Target Group mendefinisikan ke mana lalu lintas yang masuk ke Load Balancer akan dikirim. Application Load Balancer dapat mengirim lalu lintas ke beberapa Target Group berdasarkan URL permintaan yang masuk, seperti mengirim permintaan dari aplikasi seluler ke set server yang berbeda. Aplikasi web Anda akan menggunakan satu Target Group.
    {: .prompt-info}

2.  Pilih **Create target group**
3.  Konfigurasikan:
    *   **Target type**: **Instances**
    *   **Target group name**, masukkan: `LabGroup`
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 18-59-37.png>)

    *   Pilih **Lab VPC** dari menu drop-down VPC.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-02-07.png>)

4.  Pilih **Next**. Layar **Register targets** akan muncul.

    > Target adalah instance individu yang akan merespons permintaan dari Load Balancer.
    {: .prompt-info}

    > Anda belum memiliki instance aplikasi web, jadi langkah ini dapat dilewati.
    {: .prompt-tip}

5.  Tinjau pengaturan dan pilih **Create target group**
6.  Di panel navigasi kiri, pilih **Load Balancers**.
7.  Di bagian atas layar, pilih **Create load balancer**.
    
    > Beberapa jenis load balancer ditampilkan. Anda akan menggunakan Application Load Balancer yang beroperasi pada tingkat permintaan (layer 7), mengarahkan lalu lintas ke target — instance EC2, container, alamat IP, dan fungsi Lambda — berdasarkan konten permintaan.
    {: .prompt-info}

    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-04-24.png>)

8.  Di bawah **Application Load Balancer**, pilih **Create**
9.  Di bawah **Load balancer name**, masukkan: `LabELB`
10. Gulir ke bawah ke bagian **Network mapping**, lalu:
    *   Untuk **VPC**, pilih **Lab VPC**
    
        > Anda akan menentukan subnet mana yang akan digunakan Load Balancer. Load balancer akan bersifat internet facing, jadi Anda akan memilih kedua **Public Subnet**.
        {: .prompt-tip}

    *   Pilih Availability Zone pertama yang ditampilkan, lalu pilih **Public Subnet 1** dari menu drop-down **Subnet** yang muncul di bawahnya.
    *   Pilih Availability Zone kedua yang ditampilkan, lalu pilih **Public Subnet 2** dari menu drop-down **Subnet** yang muncul di bawahnya.

    *   Anda sekarang seharusnya memiliki dua subnet yang dipilih: **Public Subnet 1** dan **Public Subnet 2**.

        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-06-15.png>)

11. Di bagian **Security groups**:
    *   Pilih menu drop-down **Security groups** dan pilih **Web Security Group**.
    *   Di bawah menu drop-down, pilih **X** di sebelah security group default untuk menghapusnya.
    *   Security group **Web Security Group** sekarang seharusnya satu-satunya yang muncul.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-07-18.png>)
  
12. Untuk baris **Listener HTTP:80**, atur **Default action** menjadi **forward to LabGroup**.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-08-22.png>)

13. Gulir ke bawah dan pilih **Create load balancer**
    > Load balancer berhasil dibuat.
    {: .prompt-info}

14. Pilih **View load balancer**
    > Load balancer akan menampilkan status **provisioning**. Tidak perlu menunggu hingga siap. Silakan lanjutkan dengan tugas berikutnya.
    {: .prompt-tip}

### Tugas 3: Membuat Launch Template dan Auto Scaling Group

Dalam tugas ini, Anda akan membuat launch template untuk grup Auto Scaling Anda. Launch template adalah template yang digunakan grup Auto Scaling untuk meluncurkan instance EC2. Saat membuat launch template, Anda menentukan informasi untuk instance seperti AMI, tipe instance, key pair, dan security group.

1.  Di panel navigasi kiri, pilih **Launch Templates**.
2.  Pilih **Create launch template**
3.  Konfigurasikan pengaturan launch template dan buat:
    *   **Launch template name**: `LabConfig`
    *   Di bawah **Auto Scaling guidance**, pilih **Provide guidance to help me set up a template that I can use with EC2 Auto Scaling**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-10-18.png>)
  
    *   Di area **Application and OS Images (Amazon Machine Image)**, pilih **My AMIs**.
    *   **Amazon Machine Image (AMI)**: pilih **WebServerAMI**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-11-35.png>)

    *   **Instance type**: pilih **t2.micro**.
    *   **Key pair name**: pilih **vockey**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-12-33.png>)

    *   **Firewall (security groups)**: pilih **Select existing security group**.
    *   **Security groups**: pilih **Web Security Group**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-13-49.png>)
  
    *   Gulir ke bawah ke area **Advanced details** dan perluas.
    *   Gulir ke bawah ke pengaturan **Detailed CloudWatch monitoring**. Pilih **Enable**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-15-18.png>)

        > Ini akan memungkinkan Auto Scaling bereaksi cepat terhadap perubahan utilisasi.
        {: .prompt-info}

    *   Pilih **Create launch template**
    *   Selanjutnya, Anda akan membuat grup Auto Scaling yang menggunakan launch template ini.
4.  Dalam dialog **Success**, pilih launch template **LabConfig**.
5.  Dari menu **Actions**, pilih **Create Auto Scaling group**
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-16-53.png>)

6.  Konfigurasikan detail di **Langkah 1 (Choose launch template)**:
    *   **Auto Scaling group name**: `Lab Auto Scaling Group`
    *   **Launch template**: konfirmasi bahwa template **LabConfig** yang baru saja Anda buat dipilih.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-18-17.png>)

    *   Pilih **Next**
7.  Konfigurasikan detail di **Langkah 2 (Choose instance launch options)**:
    *   **VPC**: pilih **Lab VPC**
    *   **Availability Zones and subnets**: Pilih **Private Subnet 1** dan kemudian **Private Subnet 2**.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-19-34.png>)

    *   Pilih **Next**
8.  Konfigurasikan detail di **Langkah 3 (Configure advanced options)**:
    *   Pilih **Attach to an existing load balancer**
        *   **Existing load balancer target groups**: pilih **LabGroup**.
            ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-21-51.png>)

    *   Di panel **Additional settings**:
        *   Pilih **Enable group metrics collection within CloudWatch**
            ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-23-04.png>)

            > Ini akan menangkap metrik pada interval 1-menit, yang memungkinkan Auto Scaling bereaksi cepat terhadap pola penggunaan yang berubah.
            {: .prompt-info}

    *   Pilih **Next**
9.  Konfigurasikan detail di **Langkah 4 (Configure group size and scaling policies - optional)**:
    *   Di bawah **Group size**, konfigurasikan:
        *   **Desired capacity**: `2`
        *   **Minimum capacity**: `2`
        *   **Maximum capacity**: `6`
            ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-24-25.png>)

            > Ini akan memungkinkan Auto Scaling secara otomatis menambah/menghapus instance, selalu menjaga antara 2 hingga 6 instance yang berjalan.
            {: .prompt-info}

    *   Di bawah **Scaling policies**, pilih **Target tracking scaling policy** dan konfigurasikan:
        *   **Scaling policy name**: `LabScalingPolicy`
        *   **Metric type**: **Average CPU Utilization**
        *   **Target value**: `60`
            ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-26-00.png>)

            > Ini memberi tahu Auto Scaling untuk mempertahankan utilisasi CPU rata-rata di semua instance pada 60%. Auto Scaling akan secara otomatis menambah atau mengurangi kapasitas sesuai kebutuhan untuk menjaga metrik pada atau mendekati nilai target yang ditentukan. Ini menyesuaikan dengan fluktuasi dalam metrik karena pola beban yang berfluktuasi.
            {: .prompt-info}

    *   Pilih **Next**
10. Konfigurasikan detail di **Langkah 5 (Add notifications - optional)**:
    
    > Auto Scaling dapat mengirim notifikasi ketika peristiwa scaling terjadi. Anda akan menggunakan pengaturan default.
    {: .prompt-info}

    *   Pilih **Next**
11. Konfigurasikan detail di **Langkah 6 (Add tags - optional)**:
    
    > Tag yang diterapkan pada grup Auto Scaling akan secara otomatis disebarkan ke instance yang diluncurkan.
    {: .prompt-info}

    *   Pilih **Add tag** dan Konfigurasikan berikut:
        *   **Key**: `Name`
        *   **Value**: `Lab Instance`
            ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-27-14.png>)

    *   Pilih **Next**
12. Konfigurasikan detail di **Langkah 6 (Review)**:
    *   Tinjau detail grup Auto Scaling Anda.
    *   Pilih **Create Auto Scaling group**

        > Grup Auto Scaling Anda awalnya akan menampilkan jumlah instance nol, tetapi instance baru akan diluncurkan untuk mencapai **Desired count** sebanyak 2 instance.
        {: .prompt-info}

### Tugas 4: Verifikasi bahwa Load Balancing Berfungsi

Dalam tugas ini, Anda akan memverifikasi bahwa Load Balancing berfungsi dengan benar.

1.  Di panel navigasi kiri, pilih **Instances**.
    
    > Anda akan melihat dua instance baru bernama **Lab Instance**. Ini diluncurkan oleh Auto Scaling.
    {: .prompt-info}

    > Jika instance atau nama tidak ditampilkan, tunggu 30 detik dan pilih **refresh** di kanan atas.
    {: .prompt-tip}

    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-32-35.png>)
  
2.  Selanjutnya, Anda akan memastikan bahwa instance baru telah lulus **Health Check** mereka.
3.  Di panel navigasi kiri, pilih **Target Groups**.
4.  Pilih **LabGroup**
5.  Pilih tab **Targets**.

    > Dua instance target bernama **Lab Instance** harus terdaftar dalam target group.
    {: .prompt-info}

6.  Tunggu hingga **Status** kedua instance berubah menjadi **healthy**.
    *   Pilih **Refresh** di kanan atas untuk memeriksa pembaruan jika perlu.
    *   **Healthy** menunjukkan bahwa instance telah lulus health check Load Balancer. Ini berarti Load Balancer akan mengirim lalu lintas ke instance.
        ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-34-50.png>)

7.  Anda sekarang dapat mengakses grup Auto Scaling melalui Load Balancer.
8.  Di panel navigasi kiri, pilih **Load Balancers**.
9.  Pilih load balancer **LabELB**.
10. Di panel **Details**, salin **DNS name** load balancer, pastikan untuk menghilangkan "(A Record)".
    *   Seharusnya terlihat seperti: `labelb-480774025.us-east-1.elb.amazonaws.com`
11. Buka tab browser web baru, tempel **DNS Name** yang baru saja disalin, dan tekan **Enter**.

    > Aplikasi akan muncul di browser Anda. Ini menunjukkan bahwa Load Balancer menerima permintaan, mengirimkannya ke salah satu instance EC2, lalu mengembalikan hasilnya.
    {: .prompt-info}

    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-37-27.png>)

### Tugas 5: Menguji Auto Scaling

Anda membuat grup Auto Scaling dengan minimum dua instance dan maksimum enam instance. Saat ini dua instance sedang berjalan karena ukuran minimum adalah dua dan grup saat ini tidak di bawah beban apa pun. Anda sekarang akan meningkatkan beban untuk menyebabkan Auto Scaling menambah instance tambahan.

1.  Kembali ke Konsol Manajemen AWS.
  
    > Jangan tutup tab aplikasi — Anda akan kembali segera.
    {: .prompt-tip}

2.  Pada kotak pencarian di samping **Layanan**, cari dan pilih **CloudWatch**.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-39-44.png>)

1.  Di panel navigasi kiri, pilih **All alarms**.
    
    > Dua alarm akan ditampilkan. Ini dibuat secara otomatis oleh grup Auto Scaling. Mereka akan secara otomatis menjaga beban CPU rata-rata mendekati 60% sambil tetap berada dalam batasan memiliki dua hingga enam instance.
    {: .prompt-info}    

    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-41-08.png>)

    *   **Catatan**: Silakan ikuti langkah-langkah ini hanya jika Anda tidak melihat alarm dalam 60 detik.
        *   Pada menu **Layanan**, pilih **EC2**.
        *   Di panel navigasi kiri, pilih **Auto Scaling Groups**.
        *   Pilih **Lab Auto Scaling Group**.
        *   Di bagian bawah halaman, pilih tab **Automatic Scaling**.
        *   Pilih **LabScalingPolicy**.
        *   Pilih **Actions** dan **Edit**.
        *   Ubah **Target Value** menjadi `50`.
        *   Pilih **Update**
        *   Pada menu **Layanan**, pilih **CloudWatch**.
        *   Di panel navigasi kiri, pilih **All alarms** dan verifikasi Anda melihat dua alarm.
2.  Pilih alarm **OK**, yang memiliki **AlarmHigh** dalam namanya.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-46-31.png>)

    > Jika tidak ada alarm yang menunjukkan **OK**, tunggu satu menit lalu pilih **refresh** di kanan atas hingga status alarm berubah.
    {: .prompt-tip}

    > **OK** menunjukkan bahwa alarm belum terpicu. Ini adalah alarm untuk **CPU Utilization > 60**, yang akan menambah instance ketika CPU rata-rata tinggi. Grafik seharusnya menunjukkan tingkat CPU yang sangat rendah saat ini.
    {: .prompt-info}

3.  Anda sekarang akan memerintahkan aplikasi untuk melakukan kalkulasi yang seharusnya meningkatkan tingkat CPU.
4.  Kembali ke tab browser dengan aplikasi web.
5.  Pilih **Load Test** di samping logo AWS.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-48-06.png>)

    > Ini akan menyebabkan aplikasi menghasilkan beban tinggi. Halaman browser akan secara otomatis menyegarkan sehingga semua instance dalam grup Auto Scaling akan menghasilkan beban.
    {: .prompt-info}

    > Jangan tutup tab ini.
    {: .prompt-tip}

6.  Kembali ke tab browser dengan konsol CloudWatch.

    > Dalam kurang dari 5 menit, alarm **AlarmLow** harus berubah menjadi **OK** dan status alarm **AlarmHigh** harus berubah menjadi **In alarm**.
    {: .prompt-info}

    > Anda dapat memilih **Refresh** di kanan atas setiap 60 detik untuk memperbarui tampilan.
    {: .prompt-tip}

    > Anda akan melihat grafik **AlarmHigh** yang menunjukkan peningkatan persentase CPU. Setelah melewati garis 60% selama lebih dari 3 menit, itu akan memicu Auto Scaling untuk menambah instance tambahan.
    {: .prompt-info}

7.  Tunggu hingga alarm **AlarmHigh** memasuki status **In alarm**.
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-49-49.png>)

8.  Pada kotak pencarian di samping **Services**, cari dan pilih **EC2**.
9.  Di panel navigasi kiri, pilih **Instances**.
    
    > Lebih dari dua instance berlabel **Lab Instance** sekarang seharusnya berjalan. Instance baru dibuat oleh Auto Scaling sebagai respons terhadap alarm CloudWatch.
    {: .prompt-info}

### Tugas 6: Menghentikan Web Server 1

Dalam tugas ini, Anda akan menghentikan Web Server 1. Instance ini digunakan untuk membuat AMI yang digunakan oleh grup Auto Scaling Anda, tetapi sudah tidak diperlukan lagi.

1.  Pilih **Web Server 1** (dan pastikan itu adalah satu-satunya instance yang dipilih).
2.  Pada menu **Instance state**, pilih **Instance State** > **Terminate Instance**.
3.  Pilih **Terminate**
    ![alt text](<../assets/img/posts/cloud/application-load-balancer/aws-lab/Screenshot From 2025-11-09 19-53-30.png>)