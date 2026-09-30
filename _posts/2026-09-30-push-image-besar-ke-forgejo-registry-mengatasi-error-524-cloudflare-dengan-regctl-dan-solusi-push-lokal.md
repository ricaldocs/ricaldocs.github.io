---
title: Push Image Besar ke Forgejo Registry, Mengatasi Error 524 Cloudflare dengan regctl dan Solusi Push Lokal
description: Panduan teknis mengatasi error 524 Cloudflare saat push image Docker atau Podman ke Forgejo Container Registry melalui Cloudflare Tunnel. Gunakan regctl chunked upload dengan konfigurasi blob-chunk 20MB, atau bypass Cloudflare sepenuhnya dengan push lokal ke 127.0.0.1 untuk image besar di server ARM.
categories: [Digital Independence]
tags: [forgejo, cloudflare, regctl, podman, oci, self-hosted, raspberry pi]
author: rical
last_modified_at: 2026-09-30
---

## Latar Belakang Masalah

Forgejo Container Registry yang diakses melalui Cloudflare Tunnel menghadapi batasan keras, yaitu Proxy Read Timeout 125 detik dari edge Cloudflare. Ketika Podman/Docker melakukan push image dengan layer besar (misalnya 957MB), proses upload melewati batas waktu tersebut dan koneksi diputus dengan error `524 <none>`.

![alt text](<../assets/img/posts/2026-09-30-push-image-besar-ke-forgejo-registry-mengatasi-error-524-cloudflare-dengan-regctl-dan-solusi-push-lokal/Screenshot From 2026-09-30 21-58-36.webp>)

Akar masalahnya bukan pada Forgejo, melainkan pada mekanisme upload Podman/Docker yang mengirim layer sebagai satu blob besar. Tidak ada opsi `--chunk-size` di CLI Podman/Docker untuk memecah upload.

Solusinya gunakan `regctl` (dari proyek `regclient`) yang mendukung chunked upload di sisi client. Dengan memecah layer menjadi potongan 20MB, setiap request HTTP selesai jauh sebelum timeout 125 detik tercapai.

Mengapa harus `regctl` dan bukan `skopeo` atau tool lain? Karena `regctl` menyediakan kontrol granular atas `--blob-chunk` dan `--blob-max` per registry, serta mendukung pembacaan langsung dari OCI layout directory tanpa perlu konversi format tambahan.

## Alur Lengkap

### Tambahkan Tag pada Image Lokal

Sebelum memulai proses push, pastikan image yang sudah di-build di Podman memiliki tag yang sesuai dengan target registry Forgejo. Jika image masih bernama `localhost/globaleaks-arm64:latest`, tambahkan tag baru tanpa perlu build ulang:

```bash
podman tag localhost/globaleaks-arm64:latest git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

Mengapa langkah ini:
- `podman tag` hanya membuat referensi tambahan ke image yang sama di storage lokal. Tidak ada layer baru, tidak ada rebuild, dan tidak ada konsumsi disk space signifikan.
- Kedua nama (`localhost/globaleaks-arm64:latest` dan `git.ricalnet.my.id/rical/globaleaks-arm64:latest`) akan menunjuk ke image ID yang identik.
- Format penamaan `{registry}/{owner}/{image}:{tag}` mengikuti spesifikasi OCI Distribution, sehingga `regctl` dapat mengetahui ke registry mana image harus di-push.
- Verifikasi dengan `podman images | grep globaleaks` — harusnya ada dua baris dengan image ID yang sama.

### 1. Instalasi Binary regctl

Unduh binary regctl (sesuaikan versi & arch):
```bash
wget https://github.com/regclient/regclient/releases/download/v0.11.6/regctl-linux-arm64
mv regctl-linux-arm64 regctl
chmod 755 regctl
sudo mv regctl /usr/local/bin
regctl version
```

Mengapa langkah ini:
- `regctl` didistribusikan sebagai single static binary tanpa dependency runtime, sehingga instalasi cukup unduh dan beri izin eksekusi.
- `chmod 755` memberikan izin `rwxr-xr-x` — owner bisa eksekusi, group dan others bisa baca+eksekusi.
- `sudo mv` ke `/usr/local/bin` menempatkannya di PATH standar Linux, sehingga bisa dipanggil dari direktori mana pun.
- Sesuaikan `linux-arm64` dengan arsitektur server (gunakan `linux-amd64` untuk x86_64).
- Verifikasi wajib: `regctl version` memastikan binary yang terpasang benar (`regctl`, bukan `regbot` atau `regsync` yang memiliki subcommand berbeda).

### 2. Login ke Registry Forgejo

Login ke registry Forgejo:
```bash
regctl registry login git.ricalnet.my.id
```

Mengapa langkah ini:
- Kredensial disimpan di `~/.regctl/config.json` dalam bentuk token, bukan plaintext password.
- Login cukup sekali. Selama token belum di-revoke atau expired, push berikutnya tidak perlu login ulang.
- Jika 2FA aktif di Forgejo, gunakan Personal Access Token (PAT) sebagai password, bukan password akun.

### 3. Konfigurasi Chunked Upload

Set konfigurasi chunk (cukup sekali, tersimpan di `~/.regctl/config.json`):
```bash
regctl registry set --blob-chunk 20971520 --blob-max 104857600 git.ricalnet.my.id
```

Mengapa langkah ini — bagian paling krusial:
- `--blob-chunk 20971520` = 20MB per potongan upload. Layer akan dipecah menjadi chunk sebesar ini.
- `--blob-max 104857600` = 100MB. Layer di bawah ukuran ini dikirim utuh; layer di atasnya otomatis di-chunk.
- Perhitungan: 125 detik timeout ÷ 20MB chunk ≈ 6.25 MB/s throughput minimum yang dibutuhkan. Selama koneksi di atas kecepatan ini, push akan selesai sebelum timeout.
- Konfigurasi tersimpan permanen per host. Push berikutnya ke `git.ricalnet.my.id` otomatis memakai setting ini.
- Jika masih timeout, turunkan `--blob-chunk` ke `10485760` (10MB).

### 4. Export Image dari Podman ke OCI Layout

Export image dari Podman ke OCI layout directory:
```bash
podman save --format oci-dir -o ./globaleaks-oci git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

Mengapa langkah ini:
- `regctl` tidak bisa membaca storage internal Podman (overlayfs). Perlu export ke format netral.
- Format `oci-dir` menghasilkan OCI Image Layout standar: `index.json`, `oci-layout`, dan folder `blobs/`. Ini format yang dipahami `regctl` via prefiks `ocidir://`.
- Jangan gunakan `--format oci-archive` (tar) karena GNU tar menambahkan prefix `./` yang menyebabkan `regctl` gagal parsing dengan error `unable to export all files from tar: not found`.
- Jangan gunakan perintah `tar` manual untuk mengemas ulang — akan menghasilkan masalah yang sama.

### 5. Push dengan regctl image copy

Push menggunakan regctl image copy:
```bash
regctl image copy ocidir://./globaleaks-oci:latest git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

Mengapa langkah ini:
- `ocidir://` adalah skema URI yang memberitahu `regctl` untuk membaca dari OCI layout directory, bukan dari registry.
- `:latest` setelah path direktori adalah tag di dalam OCI layout yang harus cocok dengan tag saat export.
- `image copy` bukan `image import`: `import` hanya menerima file arsip (tar), sedangkan `copy` bisa membaca langsung dari `ocidir://`.
- Layer reuse otomatis: layer yang sudah ada di registry tujuan akan di-skip (ditandai `skipped` di output), sehingga push berikutnya jauh lebih cepat.
- Output contoh:
  ```
  Manifests: 1/1 | Blobs: 158.891MB copied, 47.131MB skipped | Elapsed: 416s
  ```

### 6. Bersihkan Direktori OCI (Opsional)

(Opsional) Bersihkan direktori OCI setelah selesai:
```bash
rm -rf ./globaleaks-oci
```

Mengapa langkah ini:
- OCI layout directory berisi duplikat penuh image (bisa ratusan MB). Setelah push berhasil, direktori ini tidak diperlukan lagi.
- Menghapusnya menghemat disk space, terutama di server dengan storage terbatas seperti Raspberry Pi.

## Alur Rutin untuk Push Berikutnya

Setelah instalasi, login, dan `registry set` selesai (cukup sekali), alur push berikutnya menyusut menjadi tiga baris:

```bash
podman save --format oci-dir -o ./globaleaks-oci git.ricalnet.my.id/rical/globaleaks-arm64:latest
regctl image copy ocidir://./globaleaks-oci:latest git.ricalnet.my.id/rical/globaleaks-arm64:latest
rm -rf ./globaleaks-oci
```

Konfigurasi chunk, kredensial login, dan preferensi registry semuanya dibaca otomatis dari `~/.regctl/config.json`.

## Verifikasi

Setelah push selesai, verifikasi keberhasilan:

```bash
regctl image digest git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

Atau cek di web Forgejo pada tab Packages repositori. Image harus muncul dengan ukuran yang sesuai.

![alt text](<../assets/img/posts/2026-09-30-push-image-besar-ke-forgejo-registry-mengatasi-error-524-cloudflare-dengan-regctl-dan-solusi-push-lokal/Screenshot From 2026-09-30 22-07-27.webp>)

Uji pull untuk memastikan image bisa diambil kembali:

```bash
podman pull git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

## Catatan Teknis

Pengaturan `regctl` tersimpan di `~/.regctl/config.json` dan tidak mempengaruhi Podman, Docker, atau tool lain. Batasan chunk 20MB hanya berlaku untuk `regctl`; `podman pull` tetap menggunakan mekanisme defaultnya.

Untuk keluar dari registry, gunakan `regctl registry logout git.ricalnet.my.id`. Untuk menghapus semua konfigurasi, hapus direktori `~/.regctl/`.

Cukup `sudo rm /usr/local/bin/regctl` dan `rm -rf ~/.regctl/` jika ingin menghapus `regctl`. Tidak ada systemd service, cron, atau dependency yang tertinggal.

Jika push masih timeout, turunkan `--blob-chunk` (misalnya 10MB). Jika koneksi stabil dan ingin lebih cepat, naikkan ke 30-50MB — tetapi jangan terlalu besar agar tidak kembali menyentuh batas 125 detik.

Error 524 bukan masalah Forgejo. Error ini murni dari edge Cloudflare yang memutus koneksi karena origin tidak merespons dalam 125 detik. Forgejo menerima request dengan normal; yang gagal adalah siklus HTTP-nya.

## Alur Alternatif untuk Push Lokal (Bypass Cloudflare Tunnel)

Jika semua upaya chunked upload melalui Cloudflare Tunnel masih gagal dengan `524` atau `416`, ini menandakan ada batasan fundamental pada edge Cloudflare yang tidak dapat diakali dari sisi client. Proxy Read Timeout 125 detik, batas ukuran upload 100MB per request, dan bug `cloudflared` yang menjatuhkan `Transfer-Encoding: chunked` adalah tiga batasan yang tidak dapat dihilangkan pada paket Free.

Solusi paling andal adalah melakukan push langsung ke registry Forgejo melalui koneksi lokal, tanpa melewati Cloudflare Tunnel sama sekali. Cara ini menghilangkan semua batasan tersebut secara instan.

### Prasyarat

- Forgejo berjalan di container dan terikat di `127.0.0.1:3002` (port loopback lokal).
- Image sudah ada di Podman dengan tag yang menunjuk ke registry publik, misalnya `git.ricalnet.my.id/rical/globaleaks-arm64:latest`.

### Langkah 1: Verifikasi Image Lokal

```bash
podman images | grep globaleaks
```

Output yang diharapkan:
```
localhost/globaleaks-arm64                  latest    375c277c1ee4  About an hour ago  957 MB
git.ricalnet.my.id/rical/globaleaks-arm64   latest    375c277c1ee4  About an hour ago  957 MB
```

Catat IMAGE ID (`375c277c1ee4`). Image ID ini akan tetap sama setelah di-tag ulang karena tag hanyalah referensi, bukan duplikasi data.

### Langkah 2: Tambahkan Tag untuk Alamat Lokal

Podman mencocokkan nama image persis dengan argumen push. Tanpa tag `127.0.0.1:3002/...`, Podman akan mengembalikan error `image not known`.

```bash
podman tag localhost/globaleaks-arm64:latest 127.0.0.1:3002/rical/globaleaks-arm64:latest
```

Verifikasi dengan `podman images | grep globaleaks`. Harusnya muncul tiga baris dengan IMAGE ID yang sama.

### Langkah 3: Konfigurasi Insecure Registry

Registry lokal berjalan di HTTP, sedangkan Podman default menggunakan HTTPS. Alih-alih menambahkan flag `--tls-verify=false` di setiap perintah, konfigurasikan secara permanen:

```bash
sudo tee /etc/containers/registries.conf.d/forgejo-local.conf <<'EOF'
[[registry]]
location = "127.0.0.1:3002"
insecure = true
EOF
```

Aman karena registry hanya terikat di loopback interface. Tidak ada traffic yang keluar dari mesin.

### Langkah 4: Login ke Registry Lokal

```bash
podman login 127.0.0.1:3002
```

Jika Langkah 3 belum dilakukan, gunakan `podman login --tls-verify=false 127.0.0.1:3002`. Masukkan username Forgejo dan Personal Access Token (PAT) sebagai password, bukan password akun. Jika 2FA aktif, PAT wajib digunakan.

### Langkah 5: Push Image ke Registry Lokal

```bash
podman push 127.0.0.1:3002/rical/globaleaks-arm64:latest
```

Jika Langkah 3 belum dilakukan, tambahkan `--tls-verify=false`.

Output yang diharapkan:
```
Getting image source signatures
Copying blob 7cf7fef22e55 done
Copying blob a84af156567d done
Copying blob 8227a1264c7f done
Copying config 375c277c1ee4 done
Writing manifest to image destination
```

Koneksi ke `127.0.0.1:3002` berjalan sepenuhnya di dalam loopback interface, tidak melewati `cloudflared`, tidak menyentuh edge Cloudflare. Semua batasan yang sebelumnya menghantui tidak berlaku. Estimasi waktu 30 detik hingga 3 menit untuk image 957 MB, tergantung kecepatan disk dan beban CPU.

### Langkah 6: Verifikasi Push Berhasil

Cek via web Forgejo di `http://127.0.0.1:3002` pada tab **Packages** di repo `rical/globaleaks-arm64`. Image harus muncul dengan tag `latest` dan ukuran yang sesuai.

Verifikasi via CLI:
```bash
podman manifest inspect 127.0.0.1:3002/rical/globaleaks-arm64:latest
```

### Langkah 7: Bersihkan Tag Sementara (Opsional)

Jika tidak memerlukan tag `127.0.0.1:3002/...` untuk penggunaan rutin:

```bash
podman rmi 127.0.0.1:3002/rical/globaleaks-arm64:latest
```

Perintah ini hanya menghapus tag, bukan image-nya, selama masih ada tag lain yang menunjuk ke IMAGE ID yang sama.

### Langkah 8: Pull dari Mesin Lain via Domain Publik

Setelah image ada di registry, pull dari mesin lain melalui `git.ricalnet.my.id` akan berjalan normal:

```bash
podman pull git.ricalnet.my.id/rical/globaleaks-arm64:latest
```

Pull tidak melibatkan upload blob besar. Cloudflare Tunnel hanya meneruskan permintaan GET yang selesai dalam hitungan milidetik, jauh di bawah timeout 125 detik. Batasan yang menghantui push tidak berlaku untuk pull.

### Ringkasan Alur Push Lokal

| Langkah | Perintah | Tujuan |
|---------|----------|--------|
| 1 | `podman images \| grep globaleaks` | Verifikasi image ada |
| 2 | `podman tag ... 127.0.0.1:3002/...` | Tambah tag lokal |
| 3 | `tee /etc/containers/registries.conf.d/...` | Konfigurasi insecure registry |
| 4 | `podman login 127.0.0.1:3002` | Autentikasi ke registry |
| 5 | `podman push 127.0.0.1:3002/...` | Push image |
| 6 | Buka web Forgejo | Verifikasi push |
| 7 | `podman rmi 127.0.0.1:3002/...` | Bersihkan tag (opsional) |
| 8 | `podman pull git.ricalnet.my.id/...` | Pull dari mesin lain |

### Catatan Teknis untuk Alur Lokal

Mengapa tidak menggunakan `git.ricalnet.my.id` langsung? Domain tersebut melewati Cloudflare Tunnel yang memiliki tiga batasan keras, yaitu Proxy Read Timeout 125 detik, batas ukuran upload 100MB per request, dan bug `cloudflared` yang menghapus `Transfer-Encoding: chunked` pada body request. Ketiganya membuat push blob besar tidak mungkin berhasil.

Mengapa tidak menggunakan `regctl` untuk push lokal? Sebenarnya bisa, tetapi tidak perlu. `regctl` diperlukan hanya ketika upload harus melewati Cloudflare Tunnel yang memiliki timeout. Untuk koneksi lokal, Podman sudah cukup dan lebih sederhana.

Mengapa registry Forgejo hanya terikat di `127.0.0.1`? Konfigurasi container Anda memetakan `127.0.0.1:3002->3000/tcp`, artinya registry hanya mendengarkan di loopback. Ini adalah praktik keamanan yang baik, karena registry tidak terekspos langsung ke jaringan dan hanya bisa diakses dari mesin itu sendiri atau melalui tunnel.