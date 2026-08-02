---
title: Docker Command Reference
description: Referensi lengkap perintah Docker untuk orkestrasi container, manajemen image, dan operasi sistem dengan contoh praktis dan best practice. 
categories: [no categories]
tags: [docker]
author: rical
last_modified_at: 2026-06-01
---

# Referensi Perintah Docker

## Pendahuluan

Docker adalah platform sumber terbuka untuk mengembangkan, mengirimkan, dan menjalankan aplikasi dalam wadah terisolasi. Dokumen ini memberikan referensi lengkap untuk perintah-perintah Docker yang umum digunakan.

## 1. Manajemen Container

### Menjalankan Container
```docker
docker run -d --name nama_container -p host_port:container_port -v host_dir:container_dir image:tag
```

**Parameter:**
- `-d`: Menjalankan container dalam mode detach (latar belakang)
- `--name`: Menetapkan nama kustom untuk container
- `-p`: Mapping port antara host dan container
- `-v`: Binding volume antara host dan container

### Operasi Siklus Hidup Container

| Perintah                        | Deskripsi                                                     |
| ------------------------------- | ------------------------------------------------------------- |
| `docker start nama_container`   | Menjalankan container yang dalam status berhenti              |
| `docker stop nama_container`    | Menghentikan container dengan proses graceful shutdown        |
| `docker restart nama_container` | Memulai ulang container                                       |
| `docker rm nama_container`      | Menghapus container yang berhenti                             |
| `docker rm -f nama_container`   | Memaksa penghapusan container (termasuk yang sedang berjalan) |
| `docker ps`                     | Menampilkan daftar container yang sedang berjalan             |
| `docker ps -a`                  | Menampilkan semua container (termasuk yang berhenti)          |
| `docker logs nama_container`    | Menampilkan log container                                     |
| `docker logs -f nama_container` | Memantau log secara real-time                                 |

## 2. Manajemen Image

### Operasi Image Docker

| Perintah                              | Deskripsi                       |
| ------------------------------------- | ------------------------------- |
| `docker pull nama_image:tag`          | Mengunduh image dari Docker Hub |
| `docker build -t nama_image:tag .`    | Membangun image dari Dockerfile |
| `docker images`                       | Menampilkan semua image lokal   |
| `docker rmi nama_image:tag`           | Menghapus image lokal           |
| `docker push username/nama_image:tag` | Mengunggah image ke Docker Hub  |

## 3. Operasi dalam Container

### Interaksi dengan Container

| Perintah                                        | Deskripsi                                                                     |
| ----------------------------------------------- | ----------------------------------------------------------------------------- |
| `docker exec -it nama_container bash`           | Mengakses shell dalam container<br>*Ganti `bash` dengan `sh` jika diperlukan* |
| `docker cp nama_container:/path/file /host/dir` | Menyalin file dari container ke host                                          |
| `docker cp /host/file nama_container:/path`     | Menyalin file dari host ke container                                          |

## 4. Manajemen Jaringan

### Konfigurasi Jaringan

| Perintah                                 | Deskripsi                                    |
| ---------------------------------------- | -------------------------------------------- |
| `docker network ls`                      | Menampilkan daftar jaringan                  |
| `docker network create nama_jaringan`    | Membuat jaringan baru                        |
| `docker run --network=nama_jaringan ...` | Menjalankan container pada jaringan tertentu |

## 5. Manajemen Volume

### Pengelolaan Penyimpanan Persisten

| Perintah                             | Deskripsi                          |
| ------------------------------------ | ---------------------------------- |
| `docker volume create nama_volume`   | Membuat volume baru                |
| `docker volume ls`                   | Menampilkan daftar volume          |
| `docker run -v nama_volume:/dir ...` | Menggunakan volume dalam container |
| `docker volume rm nama_volume`       | Menghapus volume                   |

## 6. Operasi Sistem

### Perintah Administratif dan Pemeliharaan

| Perintah                 | Deskripsi                                                                             |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `docker system prune`    | Menghapus:<br>- Container yang berhenti<br>- Jaringan tidak terpakai<br>- Build cache |
| `docker system prune -a` | Menghapus seluruh data tidak terpakai (termasuk image)                                |
| `docker stats`           | Memantau penggunaan resource (CPU/Memory)                                             |
| `docker info`            | Menampilkan informasi sistem Docker                                                   |

### Membersihkan Semua Data
```bash
docker rm -f $(docker ps -aq) && docker rmi -f $(docker images -q) && docker volume rm $(docker volume ls -q) && docker network rm $(docker network ls -q)
```

## 7. Docker Compose

### Pengelolaan Aplikasi Multi-Container

```bash
docker-compose up -d      # Menjalankan layanan
docker-compose down       # Menghentikan dan menghapus layanan
docker-compose logs -f    # Melihat log terintegrasi
```

## Contoh Konfigurasi Kompleks

```bash
docker run -d \
  --name myapp \
  -p 8080:80 \
  -v /data/app:/var/www/html \
  -e DB_HOST=database \
  --network my_network \
  --restart unless-stopped \
  nginx:latest
```

**Konfigurasi:**
- Menjalankan container Nginx dalam mode detach
- Mapping port `8080 (host) → 80 (container)`
- Mount volume lokal `/data/app` ke `/var/www/html`
- Menetapkan environment variable `DB_HOST`
- Menghubungkan ke jaringan `my_network`
- Kebijakan restart otomatis kecuali dihentikan manual

## Praktik Terbaik

1. Gunakan `docker-compose` untuk aplikasi multi-container ([contoh file](https://docs.docker.com/compose/compose-file/))
2. Untuk otentikasi Docker Hub:
   ```bash
   docker login
   ```
3. Lihat dokumentasi lengkap: [https://docs.docker.com/engine/reference/commandline/docker/](https://docs.docker.com/engine/reference/commandline/docker/)
