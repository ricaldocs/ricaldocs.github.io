---
title: Membangun Aplikasi Routing dengan Graphhopper API dan Python
description: Tutorial Python Graphhopper API untuk geocoding lokasi dan mendapatkan rute perjalanan lengkap dengan durasi, jarak, dan petunjuk arah. Pelajari parsing JSON, penanganan error, serta dukungan berbagai moda transportasi car, bike, dan foot. Cocok untuk pemula yang ingin menguasai integrasi REST API dalam proyek nyata.
categories: [no categories]
tags: [graphhopper, python, rest api]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Artikel ini memandu Anda membangun aplikasi routing berbasis Python secara bertahap, mulai dari konversi nama lokasi menjadi koordinat hingga menampilkan petunjuk arah langkah demi langkah. GraphHopper API menyediakan dua layanan utama yang dieksplorasi dalam tutorial ini: Geocoding API untuk menerjemahkan alamat menjadi titik koordinat, dan Directions API untuk menghitung rute optimal antar titik. Dengan mempraktikkan materi ini, Anda akan memperoleh pemahaman fundamental tentang integrasi REST API, penanganan format JSON, serta strategi validasi dan error handling yang esensial dalam pengembangan aplikasi modern.

## 1. Inisialisasi Lingkungan Kerja

Langkah pertama adalah menyiapkan direktori proyek dan membuka editor kode. Langkah ini krusial untuk memastikan seluruh file latihan terorganisasi dalam satu wadah dan siap dijalankan secara berurutan.

1.  Luncurkan terminal dan buat direktori kerja baru `graphhopper` dengan perintah:
    ```bash
    mkdir -p ~/labs/devnet-src/graphhopper && cd ~/labs/devnet-src/graphhopper && touch graphhopper_parse-json_{1..7}.py
    ```
2.  Buka aplikasi **Visual Studio Code**.
3.  Arahkan ke direktori proyek yang baru dibuat melalui menu **File > Open Folder…**, lalu pilih `~/labs/devnet-src/graphhopper`.

## 2. Akuisisi Kredensial GraphHopper API

Untuk mengotentikasi permintaan ke server GraphHopper, Anda memerlukan sebuah API Key. Kunci ini mengidentifikasi akun Anda dan menentukan kuota pemakaian layanan. Tanpa API Key yang valid, seluruh permintaan akan ditolak oleh server.

1.  Akses portal pengembang GraphHopper di [https://www.graphhopper.com/](https://www.graphhopper.com/).
2.  Lakukan registrasi akun baru melalui tombol **Sign Up**.
3.  Lakukan verifikasi terhadap alamat email yang telah didaftarkan (periksa folder spam apabila perlu).
4.  Setelah berhasil login, navigasikan ke bagian **API Keys** pada halaman dasbor.
5.  Klik **Add API Key**, masukkan deskripsi opsional, lalu konfirmasi dengan **Add Key**.
6.  **Salin API Key** yang dihasilkan dan simpan di tempat yang aman. Kunci ini akan digunakan di seluruh tahapan lab.
    ![alt text](<../assets/img/posts/2026-05-11-membangun-aplikasi-routing-dengan-graphhopper-api-dan-python/Screenshot From 2026-05-10 20-23-23.png>)

## 3. Implementasi Modul Geocoding

Fungsi geocoding bertanggung jawab untuk mengonversi nama lokasi tekstual (misal: "Jakarta") menjadi koordinat geografis (lintang dan bujur). Proses ini adalah fondasi aplikasi, karena API routing selanjutnya membutuhkan pasangan koordinat, bukan nama tempat. Modul ini mengekstrak data terstruktur dari respons JSON GraphHopper.

### 3.1. Pengiriman Permintaan Awal

Buka file `graphhopper_parse-json_1.py` dan implementasikan kode berikut untuk melakukan panggilan API pertama. Skrip ini bertujuan untuk memvalidasi konektivitas, memahami struktur respons mentah, dan memastikan API Key berfungsi.

```python
import requests
import urllib.parse

# Konfigurasi endpoint dan parameter awal
geocode_url = "https://graphhopper.com/api/1/geocode?"
route_url = "https://graphhopper.com/api/1/route?"
loc1 = "Jakarta"
loc2 = "Bandung"
key = "API_KEY_ANDA"  # Ganti placeholder ini dengan API Key valid

# Membentuk URL untuk permintaan geocoding
url = geocode_url + urllib.parse.urlencode({"q": loc1, "limit": "1", "key": key})

# Mengirim GET request dan mem-parsing respons
replydata = requests.get(url)
json_data = replydata.json()
json_status = replydata.status_code

# Menampilkan respons JSON mentah
print(json_data)
```

Eksekusi skrip akan menampilkan struktur JSON mentah yang berisi objek `hits` dengan data koordinat (`lat`, `lng`), nama resmi, negara, dan metadata geospasial lainnya dari lokasi "Jakarta". Memahami struktur ini penting untuk langkah ekstraksi data selanjutnya.

```
{'hits': [{'point': {'lat': -6.1754049, 'lng': 106.827168}, 'extent': [106.3146732, -6.3744575, 106.973975, -4.9993635], 'name': 'Jakarta', 'country': 'Indonesia', 'countrycode': 'ID', 'state': 'Jawa', 'osm_id': 6362934, 'osm_type': 'R', 'osm_key': 'place', 'osm_value': 'city'}], 'locale': 'default'}
```

### 3.2. Pemeriksaan Status HTTP dan Formasi URL

Untuk meningkatkan transparansi operasi, simpan file sebagai `graphhopper_parse-json_2.py` dan lakukan modifikasi untuk menampilkan URL yang dibentuk serta memvalidasi kode status respons. Praktik ini adalah teknik debugging standar saat bekerja dengan API: Anda harus dapat melihat persis URL apa yang dikirim ke server.

```python
json_status = replydata.status_code
# Menampilkan URL dan pesan sukses hanya jika status adalah 200 OK
if json_status == 200:
    print("Geocoding API URL for " + loc1 + ":\n" + url)
```

### 3.3. Abstraksi Fungsi Geocoding

Lakukan refaktorisasi kode dengan mengenkapsulasi logika geocoding ke dalam sebuah fungsi `geocoding()`. Desain ini memungkinkan penggunaan ulang serta ekstraksi data terstruktur seperti lintang, bujur, dan alamat terformat. Prinsip DRY (Don't Repeat Yourself) diterapkan agar pemanggilan untuk lokasi asal dan tujuan tidak menulis ulang kode yang sama.

```python
def geocoding(location, key):
    geocode_url = "https://graphhopper.com/api/1/geocode?"
    url = geocode_url + urllib.parse.urlencode({"q": location, "limit": "1", "key": key})
    replydata = requests.get(url)
    json_data = replydata.json()
    json_status = replydata.status_code
    print("Geocoding API URL for " + location + ":\n" + url)
    if json_status == 200:
        lat = json_data["hits"][0]["point"]["lat"]
        lng = json_data["hits"][0]["point"]["lng"]
        name = json_data["hits"][0]["name"]
        value = json_data["hits"][0]["osm_value"]
        if "country" in json_data["hits"][0]:
            country = json_data["hits"][0]["country"]
        else:
            country = ""
        if "state" in json_data["hits"][0]:
            state = json_data["hits"][0]["state"]
        else:
            state = ""
        if len(state) != 0 and len(country) != 0:
            new_loc = name + ", " + state + ", " + country
        elif len(state) != 0:
            new_loc = name + ", " + country
        else:
            new_loc = name
        print("Geocoding API URL for " + new_loc + " (Location Type: " + value + ")\n" + url)
    else:
        lat = "null"
        lng = "null"
        new_loc = location
    return json_status, lat, lng, new_loc
```

Panggil fungsi untuk kedua lokasi. Pemanggilan ini menunjukkan bagaimana fungsi dimanfaatkan untuk mengisi variabel `orig` dan `dest` dengan tuple berisi empat nilai penting.

```python
orig = geocoding(loc1, key)
print(orig)
dest = geocoding(loc2, key)
print(dest)
```

Output akan menampilkan tuple berisi `(status_kode, lintang, bujur, nama_terformat)` untuk masing-masing lokasi.

```
(200, -6.1754049, 106.827168, 'Jakarta, Jawa, Indonesia')
```

## 4. Interaktivitas Pengguna dan Penanganan Kesalahan

Aplikasi yang baik harus responsif terhadap masukan pengguna dan tahan terhadap kesalahan. Sub-bab ini memperkenalkan interaktivitas melalui command-line serta validasi untuk mencegah aplikasi berhenti mendadak akibat input yang tidak valid.

### 4.1. Implementasi Loop Interaktif

Simpan skrip sebagai `graphhopper_parse-json_3.py`. Ganti variabel statis `loc1` dan `loc2` dengan mekanisme input dinamis menggunakan loop `while True` untuk memungkinkan pengguna memasukkan lokasi secara bergantian atau keluar dengan perintah "quit"/"q". Ini adalah pola baku untuk aplikasi CLI interaktif dalam Python.

```python
while True:
    loc1 = input("Starting Location: ")
    if loc1 == "quit" or loc1 == "q":
        break
    orig = geocoding(loc1, key)
    loc2 = input("Destination: ")
    if loc2 == "quit" or loc2 == "q":
        break
    dest = geocoding(loc2, key)
    print("dest")
```

### 4.2. Validasi Input dan Pengembalian Kode Error

Simpan sebagai `graphhopper_parse-json_4.py`. Optimalkan ketahanan aplikasi dengan menambahkan dua lapis penanganan:
1.  Menambahkan loop `while` di awal fungsi `geocoding` untuk meminta input ulang jika pengguna memberikan string kosong. Ini mencegah pengiriman permintaan API dengan parameter `q` yang tidak bermakna.
    ```python
    def geocoding(location, key):
        while location == "":
            location = input("Enter the location again: ")
        geocode_url = "https://graphhopper.com/api/1/geocode?"
        url = geocode_url + urllib.parse.urlencode({"q": location, "limit": "1", "key": key})
    ```

2.  Memodifikasi logika `if-else` agar secara spesifik menampilkan pesan kesalahan dari API jika status kode bukan `200 OK`. Pola ini memanfaatkan fakta bahwa GraphHopper menyertakan penjelasan human-readable dalam properti `message` pada respons galat.
    ```python
    else:
        lat = "null"
        lng = "null"
        new_loc = location
        if json_status != 200:
            print(f"Geocode API status: {json_status}\nError message: {json_data['message']}")
    return json_status, lat, lng, new_loc
    ```

    > Uji coba dengan memasukkan lokasi kosong dan API Key yang sengaja diubah untuk memvalidasi bahwa sistem secara tepat menolak input invalid dan menampilkan pesan `401 Unauthorized` atau pesan error yang sesuai dari respons JSON.
    {: .prompt-tip}

## 5. Membangun Aplikasi Routing

Setelah berhasil mengimplementasikan modul geocoding yang mengonversi nama lokasi menjadi koordinat geografis, tahap selanjutnya adalah membangun fungsionalitas inti aplikasi: pengambilan dan pemrosesan data rute. GraphHopper Directions API menyediakan endpoint `/route` yang menerima serangkaian titik koordinat dan mengembalikan informasi jalur optimal lengkap dengan metrik perjalanan serta instruksi navigasi langkah demi langkah.

### 5.1 Request ke Routing API

Simpan file sebagai `graphhopper_parse-json_5.py`. Komponen utama yang perlu diperhatikan dalam implementasi ini adalah struktur endpoint Routing API. Berbeda dengan endpoint geocoding yang hanya memerlukan parameter `q` (query) dan `key`, endpoint routing membutuhkan parameter `point` yang berisi pasangan koordinat `latitude,longitude` untuk setiap titik yang dilalui. Setiap titik ditambahkan sebagai parameter `point` terpisah dalam URL, dengan koordinat yang di-encode menggunakan format URL encoding di mana koma (`,`) diganti dengan `%2C`.

```python
while True:
    loc1 = input("Starting Location: ")
    if loc1 == "quit" or loc1 == "q":
        break
    orig = geocoding(loc1, key)
    loc2 = input("Destination: ")
    if loc2 == "quit" or loc2 == "q":
        break
    dest = geocoding(loc2, key)
    print("=================================================")
    if orig[0] == 200 and dest[0] == 200:
        op = "&point=" + str(orig[1]) + "%2C" + str(orig[2])
        dp = "&point=" + str(dest[1]) + "%2C" + str(dest[2])
        paths_url = route_url + urllib.parse.urlencode({"key": key}) + op + dp
        paths_status = requests.get(paths_url).status_code
        paths_data = requests.get(paths_url).json()
        print("Routing API Status: " + str(paths_status) + "\nRouting API URL:\n" + paths_url)
```

**Penjelasan Teknis:**
- Variabel `op` (origin point) dan `dp` (destination point) dikonstruksi secara manual menggunakan format `&point=lat%2Clng` karena `urllib.parse.urlencode` tidak secara otomatis menangani multiple values untuk parameter yang sama dengan benar dalam semua kasus.
- Kode status HTTP diperiksa melalui `paths_status` untuk memastikan validitas respons sebelum pemrosesan lebih lanjut.
- Objek `paths_data` menyimpan seluruh payload JSON yang dikembalikan, yang berisi array `paths` dengan setiap elemen merepresentasikan satu alternatif rute.

**Output yang Diharapkan:**
```
Starting Location: Jakarta
Geocoding API URL for Jakarta, Jawa, Indonesia (Location Type: city)
Destination: Bandung
Geocoding API URL for Bandung, Jawa Barat, Indonesia (Location Type: city)
=================================================
Routing API Status: 200
Routing API URL:
Starting Location: q
```

### 5.2 Menampilkan Ringkasan Rute

Untuk memberikan gambaran umum perjalanan kepada pengguna, tambahkan blok kode yang mengekstrak dan menampilkan metrik utama: total jarak dan estimasi durasi perjalanan. Data ini berada dalam objek pertama array `paths`, yang secara default merupakan rute tercepat yang ditemukan oleh algoritma GraphHopper.

```python
print("=================================================")
print("Directions from " + orig[3] + " to " + dest[3])
print("=================================================")
if paths_status == 200:
    print("Distance Traveled: " + str(paths_data["paths"][0]["distance"]) + " m")
    print("Trip Duration: " + str(paths_data["paths"][0]["time"]) + " millisec")
    print("=================================================")
```

**Struktur Data yang Diakses:**
- `paths_data["paths"][0]["distance"]`: Jarak total dalam satuan meter (tipe data: numerik).
- `paths_data["paths"][0]["time"]`: Durasi total dalam satuan milidetik (tipe data: numerik).

**Output:**
```
=================================================
Directions from Jakarta, Jawa, Indonesia to Bandung, Jawa Barat, Indonesia
=================================================
Distance Traveled: 152132.934 m
Trip Duration: 8727417 millisec
=================================================
```

### 5.3 Konversi Metrik dan Pemformatan Durasi

Pada tahap ini, data mentah dari API perlu diolah agar lebih bermakna bagi pengguna akhir. Jarak dalam meter dikonversi menjadi kilometer (faktor 1000) dan mil (faktor 1000 × 1,61), sementara durasi dalam milidetik dipecah menjadi komponen jam, menit, dan detik menggunakan operator modulus dan pembagian integer. Pendekatan pemformatan string dengan metode `.format()` memastikan tampilan numerik yang konsisten.

```python
if paths_status == 200:
    miles = (paths_data["paths"][0]["distance"])/1000/1.61
    km = (paths_data["paths"][0]["distance"])/1000
    sec = int(paths_data["paths"][0]["time"]/1000%60)
    min = int(paths_data["paths"][0]["time"]/1000/60%60)
    hr = int(paths_data["paths"][0]["time"]/1000/60/60)
    print("Distance Traveled: {0:.1f} miles / {1:.1f} km".format(miles, km))
    print("Trip Duration: {0:02d}:{1:02d}:{2:02d}".format(hr, min, sec))
    print("=================================================")
```

**Rincian Algoritma Konversi Durasi:**
1. `time/1000`: Konversi milidetik ke detik.
2. `%60`: Mendapatkan sisa detik yang tidak membentuk menit penuh.
3. `/60%60`: Mendapatkan total menit, lalu mengambil sisa yang tidak membentuk jam penuh.
4. `/60/60`: Mendapatkan total jam.

**Format String:**
- `{0:.1f}`: Menampilkan angka desimal dengan satu digit di belakang koma.
- `{0:02d}`: Menampilkan integer dengan minimal dua digit (ditambahkan nol di depan jika perlu).

**Output Tervalidasi:**
```
=================================================
Directions from Jakarta, Jawa, Indonesia to Bandung, Jawa Barat, Indonesia
=================================================
Distance Traveled: 94.5 miles / 152.1 km
Trip Duration: 02:25:27
=================================================
```

### 5.4 Iterasi dan Menampilkan Instruksi Perjalanan

Simpan skrip sebagai `graphhopper_parse-json_6.py`. Untuk memberikan nilai tambah berupa panduan navigasi turn-by-turn, aplikasi perlu mengiterasi array `instructions` yang terdapat dalam setiap objek rute. Setiap elemen instruksi berisi teks deskriptif dan jarak tempuh untuk segmen jalan tertentu. Loop `for` dengan `range(len(...))` digunakan agar indeks dapat diakses jika diperlukan untuk keperluan penomoran atau logika lanjutan.

```python
print("Trip Duration: {0:02d}:{1:02d}:{2:02d}".format(hr, min, sec))
print("=============================================")
for each in range(len(paths_data["paths"][0]["instructions"])):
    path = paths_data["paths"][0]["instructions"][each]["text"]
    distance = paths_data["paths"][0]["instructions"][each]["distance"]
    print("{0} ( {1:.1f} km / {2:.1f} miles )".format(path, distance/1000, distance/1000/1.61))
print("=============================================")
```

**Struktur Objek `instructions`:**
- `text`: Instruksi dalam bahasa Inggris (default), misalnya "Turn right onto New York Avenue Northwest".
- `distance`: Jarak yang ditempuh pada segmen instruksi tersebut, dalam meter.
- `sign`: Kode numerik yang mengindikasikan jenis manuver (belok kiri, kanan, lurus, dll).
- `interval`: Array berisi indeks geometri jalan yang sesuai dengan segmen instruksi.

**Output dengan Petunjuk Arah Detail:**
```
=================================================
Directions from Jakarta, Jawa, Indonesia to Bandung, Jawa Barat, Indonesia
=================================================
Distance Traveled: 94.5 miles / 152.1 km
Trip Duration: 02:25:27
=============================================
Continue ( 0.0 km / 0.0 miles )
Turn left ( 0.0 km / 0.0 miles )
Turn left ( 0.1 km / 0.0 miles )
Turn right ( 0.0 km / 0.0 miles )
Turn left ( 0.1 km / 0.0 miles )
Turn left onto Jalan Medan Merdeka Timur ( 0.7 km / 0.5 miles )
Keep left and drive toward Kemayoran, Ancol ( 0.3 km / 0.2 miles )
Keep right onto Jalan Lapangan Banteng Selatan ( 0.4 km / 0.3 miles )
Turn right onto Jalan Gunung Sahari Raya and drive toward Senen, Salemba, Blok M ( 3.7 km / 2.3 miles )
Continue onto Jalan Matraman ( 1.9 km / 1.2 miles )
Keep left onto Jalan Matraman ( 0.5 km / 0.3 miles )
Keep left onto Jalan Bekasi Barat Raya ( 1.0 km / 0.6 miles )
Turn right and drive toward Cawang, Tol Jagorawi ( 1.0 km / 0.6 miles )
Keep left and take 2 toward Bogor, Pondok Indah ( 2.3 km / 1.4 miles )
Keep left and take 7 toward Bandung, Cimkampek, Grogol ( 0.3 km / 0.2 miles )
Keep left and take 7 toward Bekasi, Cikampek, Bandung ( 66.2 km / 41.1 miles )
Keep left onto Jalan Tol Cikampek–Purwakarta–Padalarang and drive toward Bandung ( 1.2 km / 0.7 miles )
Keep right onto Jalan Tol Cikampek–Purwakarta–Padalarang and drive toward Bandung ( 65.1 km / 40.4 miles )
Keep left onto Simpang Susun Pasirkoja and take 11 toward Pasir Koja, Leuwi Panjang, Soroja ( 0.3 km / 0.2 miles )
Keep left onto Simpang Susun Pasirkoja and drive toward Pasir Koja, Leuwi Panjang, Jamika ( 5.6 km / 3.5 miles )
Continue onto Jalan Pungkur ( 0.7 km / 0.4 miles )
Turn left onto Jalan Dewi Sartika ( 0.7 km / 0.4 miles )
Turn left ( 0.1 km / 0.1 miles )
Arrive at destination ( 0.0 km / 0.0 miles )
=============================================
```

### 5.5 Penanganan Kesalahan Routing API

Tidak semua pasangan koordinat dapat menghasilkan rute yang valid. GraphHopper API mengembalikan kode status HTTP `400 Bad Request` ketika algoritma routing gagal menemukan koneksi antara dua titik—situasi yang umum terjadi pada rute lintas benua (misalnya Beijing ke Jakarta) di mana tidak ada jaringan jalan yang menghubungkan secara kontinu. Tanpa penanganan yang tepat, aplikasi akan mengalami crash saat mencoba mengakses `paths_data["paths"][0]` karena array `paths` kosong atau tidak ada.

Untuk mengatasi hal ini, tambahkan struktur `else` pada pengecekan `if paths_status == 200`. Pada blok `else`, aplikasi mengekstrak properti `message` dari respons JSON yang berisi deskripsi kesalahan dari server.

Uji dengan rute yang tidak memungkinkan:
```
Starting Location: Beijing, China
Destination: Jakarta
```

**Output Skenario Gagal:**
```
=================================================
Routing API Status: 400
Routing API URL:
https://graphhopper.com/api/1/route?key=65a8a3b8-ad1d-4a3c-a973-64a62e9a2765&point=39.9057136%2C116.3912972&point=-6.1754049%2C106.827168
=================================================
Directions from 北京市 to Jakarta, Jawa, Indonesia
=================================================
Error message: Connection between locations not found
*************************************************
```

Implementasikan penanganan error sebagai berikut:

```python
    for each in range(len(paths_data["paths"][0]["instructions"])):
        path = paths_data["paths"][0]["instructions"][each]["text"]
        distance = paths_data["paths"][0]["instructions"][each]["distance"]
        print("{0} ( {1:.1f} km / {2:.1f} miles )".format(path, distance/1000, distance/1000/1.61))
    print("=============================================")
else:
    # Menampilkan pesan kesalahan dari respons API jika rute gagal
    print("Error message: " + paths_data["message"])
    print("*************************************************")
```

**Output dengan Pesan Error:**
```
Error message: Connection between locations not found
*************************************************
```

**Kesalahan Umum yang Mungkin Terjadi:**
- `400 Bad Request`: Parameter tidak valid atau rute tidak ditemukan.
- `401 Unauthorized`: API key tidak valid atau kedaluwarsa.
- `429 Too Many Requests`: Melebihi batas rate limit API gratis.
- `500 Internal Server Error`: Kesalahan pada sisi server GraphHopper.

### 5.6 Dukungan Multi-Moda Transportasi

Simpan skrip sebagai `graphhopper_parse-json_7.py`. GraphHopper Directions API mendukung berbagai profil kendaraan yang masing-masing memiliki karakteristik rute berbeda. Profil `car` mengoptimalkan untuk jalan raya dengan kecepatan tinggi, `bike` memprioritaskan jalur sepeda dan menghindari jalan tol, sementara `foot` menghasilkan rute pejalan kaki termasuk trotoar dan penyeberangan. Implementasi fitur ini memerlukan mekanisme validasi input untuk memastikan hanya profil yang didukung yang dikirim ke API, dengan fallback ke `car` untuk input yang tidak dikenal.

```python
while True:
    print("\n+++++++++++++++++++++++++++++++++++++++++++++")
    print("Vehicle profiles available on Graphhopper:")
    print("+++++++++++++++++++++++++++++++++++++++++++++")
    print("car, bike, foot")
    print("+++++++++++++++++++++++++++++++++++++++++++++")
    profile = ["car", "bike", "foot"]
    vehicle = input("Enter a vehicle profile from the list above: ")
    if vehicle == "quit" or vehicle == "q":
        break
    elif vehicle in profile:
        vehicle = vehicle
    else:
        vehicle = "car"
        print("No valid vehicle profile was entered. Using the car profile.")
```

**Validasi dan Sanitasi Input:**
- List `profile` berfungsi sebagai whitelist nilai yang diizinkan.
- Keyword `quit` dan `q` tetap dipertahankan untuk keluar dari loop utama.
- Input yang tidak valid secara otomatis diarahkan ke profil `car`, yang merupakan opsi paling umum dan selalu tersedia.

Penyesuaian konstruksi URL routing: parameter `vehicle` ditambahkan ke query string melalui `urllib.parse.urlencode` bersama dengan `key`, sementara `op` dan `dp` tetap ditambahkan secara manual karena karakteristik multiple parameter `point`.

```python
paths_url = route_url + urllib.parse.urlencode({"key":key, "vehicle":vehicle}) + op + dp
```

Header output juga disesuaikan untuk mencerminkan moda transportasi yang dipilih, memberikan transparansi penuh kepada pengguna tentang parameter yang digunakan dalam perhitungan rute.

```python
print("=================================================")
print("Directions from " + orig[3] + " to " + dest[3] + " by " + vehicle)
print("=================================================")
```

**Verifikasi Fungsionalitas Penuh:**

Jalankan skrip `graphhopper_parse-json_7.py` untuk menguji integrasi seluruh komponen. Uji kasus berikut mencakup penggunaan normal, fallback moda, dan penanganan rute tidak valid.

**Uji Kasus 1: Rute Sepeda Jakarta ke Bandung**
```
+++++++++++++++++++++++++++++++++++++++++++++
Vehicle profiles available on Graphhopper:
+++++++++++++++++++++++++++++++++++++++++++++
car, bike, foot
+++++++++++++++++++++++++++++++++++++++++++++
Enter a vehicle profile from the list above: bike
Starting Location: Jakarta
Destination: Bandung
=================================================
Routing API Status: 200
Routing API URL:
=================================================
Directions from Jakarta, Jawa, Indonesia to Bandung, Jawa Barat, Indonesia by bike
=================================================
Distance Traveled: 109.4 miles / 176.2 km
Trip Duration: 10:58:09
=============================================
Continue ( 0.0 km / 0.0 miles )
...
Arrive at destination ( 0.0 km / 0.0 miles )
=============================================
```

**Uji Kasus 2: Input Tidak Valid dan Rute Lintas Benua**
```
Enter a vehicle profile from the list above: 
No valid vehicle profile was entered. Using the car profile.

Enter a vehicle profile from the list above: car
Starting Location: Beijing, China
Destination: Jakarta
=================================================
Routing API Status: 400
...
Error message: Connection between locations not found
*************************************************
```

**Perbandingan Hasil untuk Rute yang Sama:**

Tabel di bawah mengilustrasikan bagaimana pemilihan moda transportasi memengaruhi metrik rute untuk perjalanan dari Jakarta ke Bandung.

| Profil | Jarak    | Durasi   | Karakteristik                           |
| ------ | -------- | -------- | --------------------------------------- |
| `car`  | 152 km   | 02:25:27 | Rute via jalan tol                      |
| `bike` | 176.2 km | 10:58:09 | Rute via jalur sepeda                   |
| `foot` | 166.6 km | 35:41:23 | Rute via trotoar dan jalur pejalan kaki |

Aplikasi kini telah mencapai fungsionalitas penuh yang mencakup: interaksi pengguna interaktif, geocoding dengan penanganan error, pemilihan moda transportasi, pengambilan data rute, konversi metrik, tampilan petunjuk arah detail, serta penanganan kegagalan routing yang informatif.