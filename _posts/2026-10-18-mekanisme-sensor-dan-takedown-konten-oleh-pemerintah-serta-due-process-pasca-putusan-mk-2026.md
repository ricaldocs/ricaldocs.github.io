---
title: Mekanisme Sensor dan Takedown Konten oleh Pemerintah serta Due Process Pasca Putusan MK 2026
description: Ulasan teknis dan hukum mengenai sensor serta takedown konten oleh pemerintah. Pelajari alur pemblokiran, sistem SAMAN, tenggat kepatuhan 4 dan 24 jam, temuan overmoderasi, serta dampak putusan MK 311/2026 bagi pengguna dan penyedia platform digital di Indonesia.
categories: [Cybersecurity, Sumber Daya Hukum]
tags: [privacy]
author: rical
last_modified_at: 2026-10-18
image:
  path: /assets/img/posts/2026-10-18-mekanisme-sensor-dan-takedown-konten-oleh-pemerintah-serta-due-process-pasca-putusan-mk-2026/thumbnail.webp
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
---

## Pendahuluan

Pemerintah memiliki kewenangan hukum untuk memutus akses konten digital yang melanggar hukum, tetapi eksekusinya selama ini berjalan di zona abu-abu antara diskresi administratif dan pelanggaran due process of law. Artikel ini membedah bagaimana proses itu bekerja secara teknis, mengapa ia menjadi kontroversi, dan apa yang berubah setelah Mahkamah Konstitusi memutuskan bahwa notifikasi dan alasan tertulis wajib dikeluarkan sebelum pemblokiran.

## 1. Dasar Hukum dan Titik Kritis

Kewenangan pemerintah bersumber dari **Pasal 40 ayat (2b) UU ITE** (terakhir diubah dengan UU 1/2024). Pasal ini memberi pemerintah hak untuk memutus akses dan/atau memerintahkan Penyelenggara Sistem Elektronik (PSE) memutus akses terhadap informasi elektronik yang memiliki muatan melanggar hukum.

Masalahnya bukan pada ada atau tidaknya kewenangan. Masalahnya ada pada **prosedur**. Sebelum putusan MK 2026, pasal tersebut tidak mengatur kewajiban notifikasi, alasan tertulis, maupun mekanisme keberatan bagi pihak yang terdampak. Pemerintah bisa memblokir konten tanpa memberi tahu pemilik akun apa alasan pemblokirannya. Inilah yang oleh Mahkamah Agung dalam analisisnya disebut sebagai kondisi di mana "diskresi administratif" berjalan tanpa pagar prosedural, membuka ruang penyalahgunaan wewenang (detournement de pouvoir).

## 2. Bagaimana Prosesnya Bekerja Secara Teknis

### Jalur A: Pemblokiran di Level Infrastruktur (DNS/IP)

Pemerintah meminta ISP memblokir akses ke domain atau alamat IP tertentu. Hingga awal Oktober 2026, Komdigi mencatat telah menindak **5.318.582 konten terlarang** dalam periode 20 Oktober 2024 hingga 4 Oktober 2026. Dari jumlah itu, **4.558.235 situs web** diblokir dan **760.347 konten media sosial** diturunkan. Konten perjudian mendominasi dengan **4.161.950 pemblokiran**, disusul pornografi (990.925), penipuan (58.691), dan pelanggaran HKI (9.447).

**Kelemahan teknisnya** adalah metode ini mudah diakali. Pemerintah sendiri mengakui pola "putus satu, tumbuh seribu" dan sedang menyiapkan regulasi khusus VPN untuk menutup celah. Konten yang diblokir di level ISP tidak hilang dari server aslinya, ia hanya tidak dapat diakses dari jaringan Indonesia.

### Jalur B: Perintah Takedown ke Platform (Sistem SAMAN)

Untuk platform besar, Komdigi menggunakan **Sistem Kepatuhan Moderasi Konten (SAMAN)**. Alurnya:

1. Sistem otomatis atau laporan masyarakat menemukan konten yang diduga melanggar.
2. Permintaan penghapusan dikirim ke PSE.
3. Konten krusial (pornografi anak, terorisme, radikalisme) harus dihapus dalam **4 jam**; konten negatif lainnya dalam **24 jam**.
4. Jika platform tidak patuh, sanksi administratif berlaku, hingga pemblokiran layanan.

## 3. Bukti Empiris Kesewenangan

Kritik terhadap mekanisme ini bukan sekadar teori. Riset bersama **SAFEnet dan Remotivi** terhadap **73 konten** yang dimoderasi sepanjang April–Agustus 2026 menemukan pola yang mengkhawatirkan, **90,4% pemutusan akses diprakarsai oleh Komdigi**, dan notifikasi yang dikeluarkan platform tidak pernah mencantumkan pasal pelanggaran hukum secara jelas. Mayoritas konten yang diturunkan memuat kritik terhadap program prioritas pemerintah, mulai dari Makan Bergizi Gratis, penanganan bencana, hingga Board of Peace.

Sebaran take down terbesar terjadi di platform **X (74%)**, disusul Instagram, Threads, Facebook, TikTok, dan WhatsApp. Temuan ini memperkuat dugaan bahwa moderasi konten tidak netral secara politik, melainkan berpotensi menjadi instrumen untuk mengontrol narasi.

Kasus lain yang mencuat pada Oktober 2026, yaitu sejumlah pengguna Instagram melaporkan konten terkait kebakaran hutan di Kalimantan diturunkan, dan jumlah view Story mereka anjlok drastis dari biasanya di atas 100 menjadi hanya 4. SAFEnet menilai pembatasan jangkauan semacam ini merupakan pelanggaran hak asasi manusia.

## 4. Putusan MK 311/2026

Pada **29 September 2026**, Mahkamah Konstitusi mengabulkan sebagian uji materi Pasal 40 ayat (2b) UU ITE yang diajukan tujuh mahasiswa UPN Veteran Jakarta. Amar putusan menyatakan bahwa pasal tersebut **bertentangan dengan UUD 1945** sepanjang tidak dimaknai bahwa pemerintah wajib menerbitkan **notifikasi digital atau pemberitahuan tertulis beserta alasannya** sebelum memutus akses.

Yang menarik adalah MK **menolak** gagasan bahwa setiap pemblokiran harus melalui izin pengadilan. Pertimbangannya, karakter ruang digital memungkinkan penyebaran konten berlangsung sangat cepat dan masif, sehingga kewajiban memperoleh keputusan pengadilan terlebih dahulu berpotensi melumpuhkan fungsi pencegahan. MK memilih jalan tengah, yaitu kecepatan tetap dipertahankan, tetapi harus disertai akuntabilitas prosedural.

Putusan ini secara eksplisit memberi dasar hukum bagi pihak yang terdampak untuk **menggugat ke PTUN** jika pemblokiran dilakukan tanpa notifikasi. Ini adalah pergeseran dari "diskresi" menuju "due process of law".

## 5. Respons Pemerintah dan Apa yang Belum Selesai

Komdigi menyatakan sedang mempelajari putusan dan akan menyesuaikan prosedur moderasi. Namun SAFEnet mendesak agar notifikasi tidak berhenti di level platform (melalui SAMAN), melainkan juga **transparan kepada pengguna akhir** yang kontennya terdampak.

Yang perlu dicatat secara tajam adalah putusan MK ini **tidak otomatis menyelesaikan masalah**. Kewenangan Komdigi sebagai regulator sekaligus implementator masih sangat besar. Notifikasi formal bisa saja dipenuhi secara teknis tanpa mengubah substansi, seperti konten kritis tetap diturunkan, hanya kali ini dengan selembar kertas alasan yang mungkin tetap kabur. Indikator "muatan melanggar hukum" masih sangat karet, dan praktik overmoderasi sudah banyak memakan korban.

Bagi profesional IT dan pengelola layanan digital, implikasinya jelas, dokumentasi alasan penolakan dan mekanisme banding internal bukan lagi kemewahan, melainkan kebutuhan kepatuhan. Bagi pengguna, putusan ini memberi senjata hukum, tetapi senjata itu hanya berguna jika digunakan.

Pemerintah bisa memblokir konten atau memerintahkan platform menghapusnya. Dulu, mereka bisa melakukannya tanpa memberi tahu alasannya. Sejak putusan MK September 2026, mereka wajib memberi notifikasi dan alasan tertulis. Kalau tidak, kamu bisa menggugatnya ke PTUN. Tapi pengawasan tetap perlu karena praktik lama tidak serta-merta hilang hanya karena ada putusan.

Kewenangan ada di UU ITE Pasal 40(2b), dieksekusi via SAMAN dengan SLA 4/24 jam. Titik kritis ada pada due process, yaitu notifikasi dan justifikasi tertulis kini menjadi kewajiban konstitusional pasca-MK 311/2026. Data SAFEnet-Remotivi (90,4% take down diprakarsai Komdigi, mayoritas konten kritik) menunjukkan bahwa risiko overmoderasi bersifat sistemik, bukan insidental. Sistem deteksi otomatis rentan false positive, verifikasi manual dan dokumentasi alasan menjadi kontrol internal yang tidak bisa ditawar.

## Referensi
1. [Pemutusan Akses terhadap Informasi Elektronik Harus Didahului Notifikasi](https://www.mkri.id/berita/pemutusan-akses-informasi-elektronik-harus-disertai-notifikasi-25833)
2. [Dari Diskresi menuju Due Process of Law: Reorientasi Kewenangan Pemutusan Akses Digital Pasca Putusan MK Nomor 311/2026](https://marinews.mahkamahagung.go.id/artikel/dari-diskresi-menuju-due-process-of-law-0b1K)
3. [Platform Digital Harus Hentikan Over-Moderasi Konten Kritis Warga](https://safenet.or.id/platform-digital-harus-hentikan-over-moderasi-konten-kritis-warga/)
4. [Kemkomdigi minta Wikimedia Commons segera registrasi PSE](https://m.antaranews.com/berita/5495878/kemkomdigi-minta-wikimedia-commonssegera-registrasi-pse)
5. [Pemerintah blokir 4,1 juta konten judol, tekan kejahatan transnasional](https://www.antaranews.com/berita/5767452/pemerintah-blokir-41-juta-konten-judol-tekan-kejahatan-transnasional)
6. [Puluhan Layanan Digital Terancam Diblokir, Siapa Saja?](https://rri.co.id/denpasar/nasional/2748731/puluhan-layanan-digital-terancam-diblokir-siapa-saja)

## Artikel Lainnya
- [Pelacakan Digital oleh Perusahaan Teknologi Besar dan Pemerintah](https://docs.ricalnet.my.id/posts/pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/) 