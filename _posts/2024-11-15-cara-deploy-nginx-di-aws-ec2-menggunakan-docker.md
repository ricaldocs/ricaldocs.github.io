---
title: Cara Deploy NGINX di AWS EC2 Menggunakan Docker
description: Pelajari cara deploy NGINX dengan Docker di AWS EC2 secara lengkap. Panduan pemula ini mencakup konfigurasi EC2 instance, instalasi Docker, implementasi Docker volumes untuk data persistence, dan pembuatan custom Dockerfile.
categories: [Cloud & On-Premise, AWS]
tags: [cloud computing, nginx, aws, docker]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan

Docker telah merevolusi cara pengembangan dan deployment aplikasi dengan teknologi containerization yang memungkinkan pengemasan kode aplikasi beserta seluruh dependensinya dalam lingkungan yang terisolasi dan portabel. Kontainer Docker menjamin konsistensi operasional di berbagai lingkungan komputasi, dari development hingga production, sekaligus menyediakan efisiensi resource yang superior dibanding virtual machine tradisional.

Integrasi Docker dengan Amazon Web Services (AWS) menciptakan solusi yang powerful untuk deployment aplikasi yang skalabel, resilient, dan cost-effective. Meskipun AWS menyediakan layanan container orchestration seperti Amazon ECS (Elastic Container Service) dan EKS (Elastic Kubernetes Service), pemahaman fundamental tentang deployment Docker pada EC2 instance tetap menjadi keterampilan esensial bagi cloud engineer.

## Prasyarat dan Persiapan

Sebelum memulai, pastikan Anda memiliki:
- Akun AWS dengan akses ke layanan EC2
- Basic understanding tentang command line interface
- Pengetahuan dasar tentang konsep networking dan web server

## Konfigurasi EC2 Instance yang Optimal

### Pemilihan dan Inisialisasi Instance

1. **Akses AWS Management Console** dan navigasi ke layanan **EC2**
2. Pilih **Launch Instance** dari dashboard
3. Pada bagian **Application and OS Images**, pilih **Ubuntu Server** sebagai AMI

![Pemilihan AMI Ubuntu](/assets/img/posts/cloud/2024-11-15-docker-on-aws/ami.png)

4. **Instance Type Selection**: Pilih **t3.small** (recommended) atau **t2.small** sebagai minimum requirement
   - 2 vCPU
   - 2 GiB RAM
   - Network performance yang memadai untuk workload container

![Pemilihan Tipe Instans](/assets/img/posts/cloud/2024-11-15-docker-on-aws/instances-type.png)

### Konfigurasi Security Group dan Network

**Key Pair Management**:
- Buat new key pair atau gunakan existing key
- Format `.pem` untuk OpenSSH clients
- Format `.ppk` untuk PuTTY users

![Pembuatan Key Pair](/assets/img/posts/cloud/2024-11-15-docker-on-aws/create-key-pair.png)

**Security Group Configuration**:
Buka akses untuk port berikut:
- **Port 22** (SSH): Untuk remote administration
- **Port 80** (HTTP): Untuk web traffic
- **Port 443** (HTTPS): Untuk secure web connections (opsional untuk testing)

![Pengaturan Jaringan](/assets/img/posts/cloud/2024-11-15-docker-on-aws/network-settings.png)

> Untuk environment production, batasi source IP addresses yang dapat mengakses instance melalui security group rules.
{: .prompt-tip}

## Instalasi Docker Engine dengan Konfigurasi Optimal

### Persiapan System dan Repository

> **Sumber:** [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/)

Update system packages dan install dependencies:

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Tambahkan Docker's official GPG key dan repository:

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

### Installation dan Post-Configuration

Install Docker packages:

```bash
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Konfigurasi Docker untuk startup otomatis dan non-root user access:

```bash
sudo systemctl enable docker && sudo systemctl start docker && sudo usermod -aG docker $USER
```

Verifikasi instalasi:

```bash
docker --version
sudo docker run hello-world
```

> Setelah menambahkan user ke docker group, logout dan login kembali untuk menerapkan perubahan permissions.
{: .prompt-tip}

## Implementasi NGINX Container dengan Best Practices

### Basic Container Deployment

Pull official NGINX image dari Docker Hub:

```bash
docker pull nginx:latest
```

Buat dan jalankan container dengan port mapping:

```bash
docker run -d --name nginx-container -p 80:80 nginx:latest
```

Verifikasi container status:

```bash
docker ps
docker logs nginx-container
```

### Custom Content Management

Buat project directory dan custom HTML content:

```bash
mkdir -p ~/docker-project/html && cd ~/docker-project/html
```

Buat custom `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to Docker on AWS</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 20px; 
            background-color: #f5f5f5;
        }
        .container { 
            background: white; 
            padding: 30px; 
            border-radius: 8px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .status { color: #28a745; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Successfully Deployed!</h1>
        <p>NGINX is running inside a Docker container on AWS EC2</p>
        <p class="status">Status: <span id="status">Active</span></p>
        <p><strong>Environment:</strong> Docker on AWS EC2</p>
        <p><strong>Container Name:</strong> nginx-container</p>
        <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
```

Copy file ke running container:

```bash
docker cp index.html nginx-container:/usr/share/nginx/html/
```

![alt text](<../assets/img/posts/cloud/2024-11-15-docker-on-aws/Screenshot From 2025-11-23 22-11-29.png>)

## Implementasi Docker Volumes untuk Data Persistence

### Persistent Storage Configuration

Hentikan dan hapus existing container:

```bash
docker stop nginx-container
docker rm nginx-container
```

Buat directory structure dan content:

```bash
mkdir -p ~/docker-project/web-content
cd ~/docker-project/web-content
```

Buat updated HTML file:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Docker Volume Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .volume-demo { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <h1>🔗 Docker Volume Implementation</h1>
    <p>This content is served via <span class="volume-demo">Docker Volume</span> mounted to the container</p>
    <p>Real-time file synchronization is active!</p>
</body>
</html>
```

Jalankan container dengan volume mounting:

```bash
docker run -d --name nginx-volume \
  -p 80:80 \
  -v /home/ubuntu/docker-project/web-content:/usr/share/nginx/html \
  nginx:latest
```

![alt text](<../assets/img/posts/cloud/2024-11-15-docker-on-aws/Screenshot From 2025-11-23 21-58-06.png>)

> Perubahan pada host directory langsung terefleksi dalam container tanpa perlu rebuild atau restart container.
{: .prompt-info}

## Otomasi Deployment dengan Dockerfile

### Custom Image Creation

Buat Dockerfile untuk automated build:

```bash
cd ~/docker-project
nano Dockerfile
```

Konten Dockerfile:

```dockerfile
FROM nginx:latest

LABEL maintainer="your-email@example.com"
LABEL description="Custom NGINX image for AWS deployment"

COPY web-content/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```

Build custom Docker image:

```bash
docker build -t custom-nginx-aws .
```

Jalankan container dari custom image:

```bash
docker run -d --name nginx-custom -p 80:80 custom-nginx-aws
```

Verifikasi deployment:

```bash
docker images
docker ps
curl http://localhost
```

## Monitoring dan Maintenance

### Basic Container Management Commands

Monitor container performance:

```bash
docker stats nginx-custom

docker logs nginx-custom

docker inspect nginx-custom
```

Management operations:

```bash
docker stop nginx-custom

docker start nginx-custom

docker restart nginx-custom

docker rm nginx-custom
```

### Cleanup Operations

Hapus unused resources:

```bash
docker container prune

docker image prune

docker system prune
```

## Best Practices dan Security Considerations

### Security Hardening

1. **Regular Updates**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   docker system prune -a
   ```

2. **Non-Root User**:
   ```bash
   docker run --user 1000:1000 nginx:latest
   ```

3. **Resource Limits**:
   ```bash
   docker run -d --memory="512m" --cpus="1.0" nginx:latest
   ```

### Production Recommendations

- Gunakan Amazon ECR untuk managed container registry
- Implementasikan Application Load Balancer untuk traffic distribution
- Configure CloudWatch untuk monitoring dan logging
- Gunakan IAM roles untuk secure credential management

## Troubleshooting Common Issues

### Connection Problems

```bash
docker ps

docker port nginx-custom

docker network ls
docker network inspect bridge
```

### Permission Issues

```bash
sudo chown -R $USER:$USER ~/docker-project

docker exec nginx-custom whoami
```

## Kesimpulan

Implementasi NGINX dalam container Docker pada AWS EC2 memberikan fondasi yang solid untuk deployment aplikasi web yang scalable dan maintainable. Eksperimen ini mendemonstrasikan:

1. **Isolation dan Portability**: Containerization memastikan konsistensi environment across different stages
2. **Resource Efficiency**: Docker containers menggunakan resources lebih efisien dibanding traditional virtualization
3. **Rapid Deployment**: Docker images memungkinkan quick provisioning dan scaling
4. **DevOps Integration**: Dockerfile memfasilitasi CI/CD pipeline implementation

Untuk project production, pertimbangkan menggunakan Amazon ECS atau EKS untuk container orchestration yang lebih robust, serta implementasi security best practices yang komprehensif.

Dengan menguasai fundamental Docker pada AWS EC2 ini, Anda telah membangun foundation yang kuat untuk mengeksplorasi advanced container technologies dan cloud-native application development.

## Referensi 
- [Docker Official Documentation](https://docs.docker.com)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)