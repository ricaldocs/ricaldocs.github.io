---
title: Pelacakan Digital oleh Perusahaan Teknologi Besar dan Pemerintah
description: Penyadapan Presiden Prabowo membuktikan pelacakan digital bukan sekadar isu privasi. Pelajari cara kerja cookie, fingerprint, metadata, AI, dan panduan melindungi komunikasi.
categories: [Cybersecurity, Privacy]
tags: [privacy]
author: rical
last_modified_at: 2026-11-05
pin: true
image:
  path: /assets/img/posts/2025-03-28-pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/Digital Privacy Network.webp
  lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
---

Setiap kali Anda membuka internet, Anda meninggalkan jejak digital yang dilacak secara sistematis. Itu kalimat pembuka artikel saya sebelumnya—dan hingga hari ini, kalimat itu tetap benar. Yang berubah adalah konteksnya. Pekan ini, Indonesia dihebohkan oleh penangkapan tiga perwira tinggi, termasuk Listyo Sigit Prabowo, mantan Kapolri yang baru beralih ke posisi Kepala Staf Kepresidenan. Tuduhannya, penyadapan ilegal terhadap telepon Presiden Prabowo Subianto sepanjang 2025–2026, sekaligus terhadap menteri, politikus, tokoh media, aktivis, dan pengusaha. Sistem LIMS (Lawful Interception Management System) yang seharusnya "legal" dipakai dengan melewati seluruh prosedur verifikasi—tanpa surat perintah, tanpa dasar penegakan hukum, dan bahkan dengan upaya menghapus jejak.

Artikel ini menggabungkan dua hal yang selama ini sering dibahas terpisah: bagaimana pelacakan digital bekerja dan mengapa ia kini menjadi persoalan bertahan hidup, bukan sekadar kenyamanan. Karena kasus penyadapan presiden membuktikan satu hal yang sudah lama kita tahu tetapi sering kita abaikan: ketika kemampuan teknis bertemu kekuasaan, target pelacakan bisa merangkak naik sampai ke level tertinggi negara. Dan jika level tertinggi bisa menjadi target, asumsi "saya bukan siapa-siapa, jadi aman" adalah ilusi.

## Mengapa Data Anda Begitu Berharga?

Data adalah komoditas paling berharga di abad ke-21. Setiap klik, durasi menonton, lokasi, bahkan gerakan kursor bisa diubah menjadi profil perilaku yang akurat. Profil ini dijual ke pengiklan, digunakan untuk memprediksi keputusan Anda, atau menentukan kelayakan pinjaman bank. Pemerintah pun menginginkan akses yang sama—karena informasi adalah kekuatan.

Bukan karena perusahaan jahat. Mereka hanya sangat kreatif dalam menyedot informasi karena data menghasilkan uang. Iklan yang ditargetkan menghasilkan pendapatan 5–10 kali lipat dibanding iklan acak. Tetapi logika yang sama—kumpulkan sebanyak mungkin, ekstrak nilainya—juga bekerja di ranah negara. Perusahaan memakainya untuk menjual iklan. Pemerintah, atau lebih tepatnya orang-orang di dalamnya, memakainya untuk mengendalikan arus informasi atau setidaknya mengetahui ke mana informasi itu mengalir.

## Bagaimana Mereka Melakukannya

### Cookie Pelacak

![Cookies and Analytics Dashboard](<../assets/img/posts/2025-03-28-pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/Cookies and Analytics Dashboard.webp>)
_Cookies and Analytics Dashboard_

Cookie menempel di browser Anda begitu Anda menyentuh situs. Facebook Pixel dan Google Analytics merekam halaman yang dibuka, durasi, tombol yang diklik. Perusahaan tahu produk apa yang membuat Anda ragu, konten apa yang membuat Anda berhenti scrolling, dan iklan jenis apa yang paling mungkin membuat Anda mengeluarkan uang.

### Sidik Jari Digital

![Digital Fingerprint Cookie Cleanup](<../assets/img/posts/2025-03-28-pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/Digital Fingerprint Cookie Cleanup.webp>)
_Digital Fingerprint Cookie Cleanup_

Setiap perangkat punya "sidik jari" unik—kombinasi OS, resolusi layar, jenis font, preferensi bahasa. Bekerja tanpa menyimpan file di perangkat Anda. Cookie bisa dihapus. Sidik jari tidak. Anda tidak tahu sedang dilacak. Platform bisa mengenali Anda meski sudah ganti browser atau menghapus cookie.

### Metadata

![Metadata Leakage Infographic](<../assets/img/posts/2025-03-28-pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/Metadata Leakage Infographic.webp>)
_Metadata Leakage Infographic_

Metadata adalah "data tentang data"—siapa yang Anda telepon, jam berapa, durasi, dari lokasi mana. Bukan isi percakapan. Metadata lebih mudah dikumpulkan secara massal dan tetap sangat mengungkapkan. Seperti analogi klasik: tidak perlu tahu isi percakapan dengan rumah sakit jika catatan menunjukkan Anda menelepon klinik onkologi sepuluh kali seminggu pada jam 3 pagi.

Di sinilah kasus penyadapan presiden menjadi sangat relevan. Sistem LIMS yang dipakai para tersangka bekerja justru di level metadata dan akses sistem—bukan dengan meretas enkripsi, tetapi dengan masuk ke sistem yang seharusnya hanya bisa diakses dengan prosedur ketat. Ketika prosedur itu dilewati, metadata berubah dari alat analisis menjadi senjata.

### AI dan Pola

![AI Data Prediction Flow](<../assets/img/posts/2025-03-28-pelacakan-digital-oleh-perusahaan-teknologi-besar-dan-pemerintah/AI Data Prediction Flow.webp>)
_AI Data Prediction Flow_

AI dilatih dengan miliaran titik data untuk mengenali pola yang tidak kasatmata oleh manusia. AI tidak hanya melihat apa yang sudah terjadi, tetapi meramalkan apa yang akan Anda lakukan. Prediksi sering kali lebih bernilai daripada fakta. Dalam konteks pengawasan negara, prediksi berarti kemampuan mengidentifikasi "siapa yang mungkin melakukan sesuatu" sebelum sesuatu itu terjadi—dan itu adalah kekuatan yang sangat mudah disalahgunakan.

## Dari Mana Data Ini Berasal?

Bukan dari peretasan. Dari aktivitas paling biasa yang Anda anggap sepele:

- Like, share, komentar → menunjukkan afiliasi politik, preferensi estetika, bahkan kecenderungan depresi
- Pencarian Google → saat mencari "cara move on" jam 2 pagi, Anda memberikan data paling jujur tentang kerentanan pribadi
- Aplikasi ponsel → meminta akses GPS, kamera, mikrofon dengan alasan "agar layanan optimal"
- Asisten virtual (ChatGPT dll) → merekam percakapan untuk pelatihan di masa depan

Dalam kasus penyadapan presiden, kategori target yang diumumkan polisi mencakup "media" dan "jurnalis" secara eksplisit. Ini bukan kerusakan sampingan. Alat utama jurnalisme investigatif adalah sumber rahasia dan komunikasi yang belum dipublikasikan. Jika komunikasi itu bisa diambil alih oleh oknum aparat, ruang hidup investigasi dicabut sampai ke akarnya. Dan bagi jurnalis, pertanyaan konkretnya adalah: apakah Signal atau Matrix yang dipakai untuk menghubungi narasumber benar-benar aman jika perangkat lawan bicara sudah disusupi?

## Kolaborasi Silicon Valley dan Negara

Pemerintah bilang butuh akses data untuk menangkal terorisme. Perusahaan mengangguk patuh, apalagi jika ada surat perintah. Mengapa perusahaan bersedia? Kepatuhan adalah harga lisensi untuk tetap beroperasi di pasar raksasa tanpa hambatan regulasi.

### Praktik Berbahaya

- National Security Letters (AS) → permintaan data tanpa pengawasan pengadilan. Perusahaan dilarang memberi tahu pengguna.
- Program PRISM (Snowden) → NSA mendapat akses langsung ke server Google, Apple, dan Facebook. Pemerintah bisa mengambil data jutaan pengguna sekaligus.

Mengapa ini skandal? Bukan sekadar kerja sama biasa. Pemerintah tidak perlu surat perintah satu per satu. Dan dalam kasus Indonesia, LIMS menunjukkan bahwa sistem yang dibangun untuk "legal interception" bisa dipakai tanpa prosedur—bahkan terhadap presiden sendiri.

## Skandal yang Membuka Mata

### Cambridge Analytica (2018)
87 juta data Facebook dipanen untuk memanipulasi pemilu AS. Facebook memberikan akses API lebar-lebar ke pengembang pihak ketiga dan tidak mengawasi penggunaannya. Ini terjadi karena Facebook tidak mengawasi bagaimana data digunakan setelah diambil.

### Sistem Kredit Sosial China
Pemerintah menilai warganya berdasarkan perilaku digital. Terlambat bayar tagihan, mengkritik partai, atau membeli terlalu banyak video game bisa menurunkan skor Anda. Bukan hanya penjahat yang dihukum; warga biasa kehilangan hak bepergian atau akses pinjaman.

### Spyware Pegasus
Perangkat lunak yang bisa masuk ke ponsel tanpa klik, membaca pesan terenkripsi, mengaktifkan kamera, merekam suara. Dibuat oleh perusahaan swasta (NSO Group) dan dijual ke pemerintah—termasuk rezim otoriter untuk mengintai lawan politik dan jurnalis.

Pegasus adalah jembatan antara pelacakan komersial dan penyadapan negara. Ia tidak membobol enkripsi; ia langsung tinggal di dalam ponsel Anda. Begitu perangkat dikuasai, Signal pun tidak menyelamatkan isi percakapan yang sudah terbaca di layar. Inilah mengapa panduan privasi di bawah ini tidak berhenti pada "pakai aplikasi enkripsi", tetapi dimulai dari perangkat itu sendiri.

### Penyadapan Presiden Indonesia (2026)
Tiga perwira tinggi ditangkap karena memasukkan nomor target ke sistem LIMS tanpa verifikasi. Targetnya termasuk presiden, menteri, politikus, media, dan jurnalis. Salah satu tersangka memerintahkan penghapusan catatan penyadapan. Kompolnas menyebut ini peristiwa pertama dalam sejarah kepolisian Indonesia. Komisioner Komnas HAM menyoroti: jika telepon presiden saja bisa diperlakukan demikian, bagaimana dengan warga biasa?

## Hukum yang Datang Terlambat

### GDPR (Eropa)
Memaksa perusahaan meminta persetujuan eksplisit sebelum mengumpulkan data. Mengapa dampaknya terbatas? Anda dibombardir pop-up "Terima cookie", dan mayoritas tetap klik "Terima Semua" karena desain pop-up membuat "Tolak" lebih sulit.

### UU PDP (Indonesia)
Landasan hukum untuk menuntut perusahaan yang lalai atau menyalahgunakan data warga. Mengapa belum bisa bertepuk tangan? Implementasi masih harus diawasi ketat. Tanpa pengadilan yang kompeten dan aparat yang paham teknologi, UU ini bisa menjadi macan kertas.

Kasus LIMS membuktikan titik lemah ini. Peraturan Kapolri tentang penyadapan masih mengacu pada aturan 2010 yang, menurut Kompolnas, tidak memungkinkan pengawasan eksternal—bahkan pengawasan internal pun sulit masuk. Pemerintah sudah menyatakan akan meninjau ulang regulasi penyadapan. Tetapi masalah yang dibuka kasus ini jauh lebih dalam daripada "merevisi satu aturan": ketika kemampuan teknis berlari lebih cepat daripada institusi, penyalahgunaan hanyalah soal waktu.

## Panduan Privasi Digital yang Benar-Benar Bekerja

Kasus penyadapan presiden mengubah pertanyaan dari "apakah mereka melacak saya?" menjadi "apa yang bisa saya lakukan agar pelacakan itu tidak mudah digunakan untuk menekan saya?" Berikut langkah konkret yang bisa Anda ambil hari ini.

### 1. Mulai dari Perangkat: Ponsel Anda adalah Titik Terlemah

Penyadapan modern tidak selalu membobol enkripsi. Spyware kelas Pegasus bekerja dengan masuk ke perangkat itu sendiri—membaca pesan setelah didekripsi di layar, mengaktifkan mikrofon, melacak lokasi secara real-time.

- Perbarui sistem operasi dan aplikasi secara otomatis. Perangkat usang adalah target termudah.
- Aktifkan notifikasi keamanan. Apple (sejak iOS 16) dan Android versi terbaru mengirim peringatan jika mendeteksi aktivitas spyware.
- Waspadai tanda-tanda aneh: ponsel panas saat idle, baterai terkuras tidak wajar, proses latar belakang tak dikenal. Ini bukan bukti pasti, tetapi sinyal untuk memeriksa lebih lanjut.
- Untuk jurnalis dan aktivis: pertimbangkan Lockdown Mode di iPhone atau mode keamanan ketat di Android jika risiko Anda tinggi. Fitur ini membatasi permukaan serangan yang biasanya dieksploitasi spyware.

### 2. Komunikasi: Enkripsi Bukan Solusi Tunggal, tetapi Awal yang Wajib

- Gunakan Signal untuk komunikasi sensitif. Signal adalah standar emas saat ini: open-source, E2EE secara default, dan meminimalkan metadata. Panduan keamanan jurnalis Indonesia secara eksplisit merekomendasikan Signal.
- Hindari Facebook Messenger, WhatsApp, atau SMS untuk hal yang benar-benar sensitif. WhatsApp memiliki E2EE, tetapi dimiliki Meta—perusahaan yang model bisnisnya bergantung pada pengumpulan data. SMS sama sekali tidak terenkripsi.
- Aktifkan pesan menghilang. Ini membatasi berapa lama pesan sensitif tersimpan di perangkat lawan bicara. Jika perangkat mereka disita atau disusupi, jendela paparan menjadi lebih kecil.
- Verifikasi kontak. Pastikan Anda berbicara dengan orang yang benar, bukan akun yang disusupi. Signal memiliki fitur "safety number" untuk memverifikasi identitas.

### 3. Jejak Digital: Kurangi Permukaan yang Bisa Dipetakan

- Audit izin aplikasi. Buka pengaturan ponsel, lihat aplikasi mana yang punya akses ke lokasi, mikrofon, dan kamera. Cabut izin yang tidak esensial. Aplikasi belanja tidak perlu tahu lokasi Anda sepanjang waktu.
- Gunakan browser yang fokus privasi. Chrome adalah produk Google yang ikut mengumpulkan data. Pertimbangkan Firefox dengan pengaturan ketat, LibreWolf, atau Brave. Untuk pencarian, gunakan DuckDuckGo atau Startpage.
- Hapus cookie secara rutin, tetapi jangan bergantung padanya. Cookie bisa dihapus, tetapi sidik jari browser tidak. Satu-satunya cara efektif melawan fingerprinting adalah menggunakan browser yang secara aktif melakukan randomisasi atau memblokir teknik tersebut.
- Periksa apa yang sudah bocor tentang Anda. Cari nama Anda di Google, cek archive.org, dan gunakan layanan seperti Have I Been Pwned untuk melihat apakah email Anda ada dalam kebocoran data.

### 4. Jurnalis dan Sumber: Lindungi Rantai Komunikasi, Bukan Hanya Diri Sendiri

- Matikan location tracking saat bertemu sumber sensitif. Jika perangkat melacak lokasi, pertemuan dengan narasumber bisa direkonstruksi dari data lokasi. Matikan GPS dan location history sebelum pertemuan.
- Pilah informasi yang dibagikan ke kontak. Jurnalis bisa menjadi rentan bukan hanya karena perangkatnya, tetapi karena kontaknya. Jika narasumber tidak menerapkan keamanan yang sama, rantai komunikasi tetap terbuka.
- Simpan salinan aman, lalu hapus dari perangkat. Informasi sensitif yang tidak perlu ada di ponsel sebaiknya disimpan di penyimpanan terenkripsi terpisah, dan dihapus dari perangkat utama.
- Gunakan perangkat terpisah untuk peliputan berisiko tinggi. Jika analisis risiko menunjukkan peliputan sangat berbahaya, pertimbangkan untuk tidak membawa ponsel cerdas sama sekali—gunakan ponsel basic dengan SIM prabayar.

### 5. Regulasi Tidak Akan Menyelamatkan Anda Sendiri—Tetapi Tetap Penting

- Dukung dan awasi implementasi UU PDP.
- Jika Anda bekerja di organisasi atau media, dorong adanya penilaian risiko digital sebagai bagian dari prosedur standar—bukan hanya untuk peliputan investigatif, tetapi untuk semua pekerjaan yang menyentuh isu sensitif.
- Untuk jurnalis, AJI menyediakan Perangkat Penilaian Risiko yang mencakup sesi Keamanan Digital dengan pertanyaan konkret tentang kesiapan perangkat dan praktik komunikasi. Gunakan itu.

## Intinya

Pelacakan digital adalah pisau bermata dua. Keamanan dan personalisasi menuntut data, sementara privasi menuntut batasan. Kasus penyadapan Presiden Prabowo bukan sekadar skandal politik yang akan berlalu—ia adalah demonstrasi publik tentang bagaimana infrastruktur pengawasan yang dibangun untuk "keamanan" bisa berbalik menjadi alat penekanan ketika kontrolnya longgar.

Pertanyaan bukan lagi "apakah mereka melacak Anda?" —jawabannya pasti ya.

Pertanyaannya: Apakah Anda tahu untuk apa data Anda digunakan, apakah Anda setuju, dan apakah Anda memiliki kendali atas apa yang Anda bagikan?

Panduan di atas tidak akan membuat Anda kebal. Tidak ada yang kebal. Tetapi mengurangi permukaan serangan, mengenkripsi komunikasi yang memang sensitif, dan memahami di mana data Anda berada—itu adalah perbedaan antara menjadi target yang mudah dan target yang setidaknya membutuhkan usaha. Privasi bukan tentang menyembunyikan sesuatu. Privasi adalah tentang memiliki kendali atas apa yang Anda bagikan, kepada siapa, dan untuk apa. Dalam dunia di mana pelacakan adalah default, mengambil kembali kendali itu membutuhkan usaha sadar—dan itu dimulai dari langkah-langkah kecil yang Anda ambil hari ini.

## Referensi

1. [UU PDP Indonesia](https://docs.ricalnet.my.id/posts/panduan-lengkap-undang-undang-perlindungan-data-pribadi/)
2. [The Guardian - NSA Files](https://www.theguardian.com/world/interactive/2013/nov/01/snowden-nsa-files-surveillance-revelations-decoded)
3. [GDPR](https://gdpr-info.eu/)
4. Laporan transparansi: [Google](https://transparencyreport.google.com/) & [Facebook](https://transparency.facebook.com/)
5. RRI, "Kasus Penyadapan Presiden Prabowo, LSP Lakukan Dugaan Akses Ilegal" (3 November 2026)
6. ANTARA News, "Prabowo informed of illegal wiretapping, minister says" (3 November 2026)
7. ANTARA News, "Mensesneg belum mengetahui isi percakapan dalam kasus penyadapan" (4 November 2026)
8. BeritaSatu, "Kompolnas: Kapolri Sadap Presiden Kejadian Pertama dalam Sejarah RI" (4 November 2026)
9. ANTARA News, "RI to review wiretap regulations after alleged spying on president" (4 November 2026)
10. ANTARA News, "Menteri HAM dorong Polri usut tuntas kasus penyadapan ilegal" (4 November 2026)
11. ABC News, "Indonesian police generals accused of illegally tapping phone of president, journalists" (4 November 2026)
12. Suara Merdeka, "HP Presiden Prabowo Disadap, Tiga Pejabat Tinggi Ditahan" (3 November 2026)