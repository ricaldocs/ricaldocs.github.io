---
title: Automasi Instalasi Web Server dengan Ansible
description: Pelajari cara mengotomatiskan instalasi dan konfigurasi server web Apache2 menggunakan Ansible. Artikel ini mencakup setup environment, inventory, playbook pengujian, instalasi Apache, aktivasi mod_rewrite, serta perubahan port virtual host secara deklaratif dan idempoten.
categories: [Infrastructure as Code, Ansible]
tags: [ansible, python]
author: rical
last_modified_at: 2026-06-01
---

Dokumentasi ini menjelaskan proses otomatisasi instalasi Apache HTTP Server pada mesin remote menggunakan Ansible. Dengan Ansible, seluruh konfigurasi server dapat dideklarasikan dalam file playbook, sehingga instalasi bersifat **repeatable**, **idempoten**, dan mudah di-versioning.  

Lingkup yang dibahas meliputi:
- Persiapan Python virtual environment dan instalasi Ansible.
- Konfigurasi koneksi ke node target (inventory dan `ansible.cfg`).
- Pengujian koneksi dan eksekusi perintah ad-hoc.
- Pembuatan playbook untuk instalasi Apache, aktivasi `mod_rewrite`, dan penyesuaian port `8081`.
- Verifikasi hasil konfigurasi pada server target.

## Prasyarat

- **Node kontrol**: Sistem berbasis Linux (contoh menggunakan Ubuntu/Debian) dengan Python 3 terinstal.
- **Node target**: Server Ubuntu/Debian dengan akses SSH dan pengguna yang memiliki hak `sudo`.
- **Konektivitas jaringan**: Node kontrol dapat menjangkau node target melalui IP `192.168.1.103`.
- **Kredensial akses**: Nama pengguna dan kata sandi (atau lebih baik, kunci SSH) untuk node target.

> Penggunaan kata sandi plaintext di file inventory hanya untuk keperluan demonstrasi. Untuk lingkungan produksi, gunakan autentikasi kunci SSH dan Ansible Vault untuk menyimpan rahasia.
{: .prompt-warning}

## 1. Menyiapkan Lingkungan Kerja

### 1.1 Virtual Environment Python
Gunakan *virtual environment* agar dependensi Ansible terisolasi dari sistem global.

```bash
python3 -m venv venv
source venv/bin/activate
```
Sekarang terminal berada dalam lingkungan virtual, ditandai dengan `(venv)` di awal prompt.

### 1.2 Instalasi Ansible
```bash
pip install ansible
```
Setelah selesai, versi Ansible dapat diperiksa dengan `ansible --version`.

## 2. Menyiapkan Koneksi SSH ke Node Target

Pastikan server target memiliki **OpenSSH Server** aktif.

```bash
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Verifikasi status layanan:
```bash
sudo systemctl status ssh
```
Pastikan status menunjukkan `active (running)`.

## 3. Membuat Direktori Proyek Ansible

Buat direktori khusus untuk proyek otomatisasi ini.

```bash
mkdir ansible-apache
cd ansible-apache
```

Semua file konfigurasi dan playbook akan disimpan di dalam direktori ini.

## 4. Menyusun File Inventory

Inventory mendefinisikan host target dan parameter koneksi.

Buat file `hosts`:
```bash
nano hosts
```

Isi dengan:
```ini
[webservers]
192.168.1.103 ansible_ssh_user=user ansible_ssh_pass=password
```

- **`[webservers]`** : Nama grup untuk host target.
- **`ansible_ssh_user`** : Nama pengguna SSH pada node remote.
- **`ansible_ssh_pass`** : Kata sandi pengguna (tidak disarankan untuk produksi).

Sesuaikan alamat IP, pengguna, dan kata sandi dengan kondisi nyata.

## 5. Konfigurasi `ansible.cfg`

File `ansible.cfg` mengontrol perilaku Ansible di direktori proyek, mengesampingkan konfigurasi global.

Buat file:
```bash
nano ansible.cfg
```

Isi dengan:
```ini
[defaults]
# Gunakan file hosts lokal di folder ini
inventory = ./hosts
# Nonaktifkan pengecekan fingerprint host SSH (hanya untuk lab/testing)
host_key_checking = False
# Jangan buat file retry (.retry) jika playbook gagal
retry_files_enabled = False
```

Penjelasan:
- **`inventory`**: Menunjuk ke file inventory lokal.
- **`host_key_checking`**: Menonaktifkan verifikasi kunci host SSH, berguna untuk lingkungan percobaan. Pada produksi tetap aktifkan.
- **`retry_files_enabled`**: Mencegah pembuatan file retry yang dapat mengotori direktori kerja.

## 6. Menguji Koneksi dengan Modul `ping`

Modul `ping` digunakan untuk memverifikasi bahwa Ansible dapat berkomunikasi dengan node target **dan** Python interpreter berfungsi.

```bash
ansible webservers -m ping
```

Contoh output:
```
[WARNING]: Host '192.168.1.103' is using the discovered Python interpreter at '/usr/bin/python3.13'...
192.168.1.103 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.13"
    },
    "changed": false,
    "ping": "pong"
}
```

- Respons `"ping": "pong"` menandakan koneksi berhasil.
- Peringatan tentang interpreter Python bersifat informatif; Ansible menemukan Python di jalur tersebut dan akan terus menggunakannya selama sesi ini.

## 7. Eksekusi Perintah Ad-hoc dengan Modul `command`

Uji eksekusi perintah sederhana pada semua host di grup `webservers`.

```bash
ansible webservers -m command -a "/bin/echo hello world"
```

Output:
```
[WARNING]: Host '192.168.1.103' is using the discovered Python interpreter...
192.168.1.103 | CHANGED | rc=0 >>
hello world
```

- `CHANGED` menunjukkan bahwa perintah berhasil dijalankan (perubahan selalu terjadi untuk modul `command`).
- `rc=0` menandakan return code sukses.
- `stdout` menampilkan `hello world`.

Langkah ini membuktikan Ansible dapat mengeksekusi perintah shell di node remote.

## 8. Playbook Pertama: `test_apache_playbook.yaml`

Playbook adalah file YAML yang mendeklarasikan serangkaian tugas (tasks) untuk dijalankan pada host tertentu.

Buat file:
```bash
nano test_apache_playbook.yaml
```

Isi:
```yaml
- hosts: webservers
  tasks:
    - name: run echo command
      command: /bin/echo hello world
```

Struktur:
- **`hosts`**: Menentukan grup target (`webservers`).
- **`tasks`**: Daftar tugas. Setiap tugas memiliki nama dan modul yang digunakan (di sini `command`).

Jalankan playbook dengan mode verbose:
```bash
ansible-playbook -v test_apache_playbook.yaml
```

Output (ringkas):
```
PLAY [webservers] ***************************************************
TASK [Gathering Facts] **********************************************
ok: [192.168.1.103]
TASK [run echo command] *********************************************
changed: [192.168.1.103] => {"cmd": ["/bin/echo", "hello", "world"], "stdout": "hello world", ...}
PLAY RECAP **********************************************************
192.168.1.103 : ok=2    changed=1    unreachable=0    failed=0 ...
```

- **Gathering Facts**: Ansible mengumpulkan informasi sistem target secara otomatis.
- **Play Recap**: Ringkasan eksekusi; semua host berhasil tanpa kegagalan.

## 9. Playbook Instalasi Apache dengan `mod_rewrite`

Buat file playbook baru:
```bash
nano install_apache_playbook.yaml
```

Isi:
```yaml
- hosts: webservers
  become: yes
  tasks:
    - name: INSTALL APACHE2
      apt: name=apache2 update_cache=yes state=latest

    - name: ENABLED MOD_REWRITE
      apache2_module: name=rewrite state=present
      notify:
        - RESTART APACHE2

  handlers:
    - name: RESTART APACHE2
      service: name=apache2 state=restarted
```

Penjelasan:
- **`become: yes`**: Eskalasi hak akses ke root (diperlukan untuk instalasi paket dan modifikasi konfigurasi).
- **Task pertama**: Modul `apt` menginstal `apache2` dengan `update_cache=yes` (setara `apt update`) dan `state=latest` (versi terbaru).
- **Task kedua**: Modul `apache2_module` memastikan modul `rewrite` aktif. Notify akan memicu handler.
- **Handler** `RESTART APACHE2`: Akan dijalankan hanya jika ada tugas yang memberikan notifikasi. Handler selalu dipanggil di akhir play, sekali saja meskipun banyak notifikasi.

Jalankan playbook:
```bash
ansible-playbook -v install_apache_playbook.yaml
```

Output (contoh):
```
TASK [INSTALL APACHE2] **************************************************
TASK [ENABLED MOD_REWRITE] *********************************************
changed: [192.168.1.103] => {"changed": true, "result": "Module rewrite enabled"}
RUNNING HANDLER [RESTART APACHE2] **************************************
changed: [192.168.1.103]
PLAY RECAP *************************************************************
192.168.1.103 : ok=4    changed=3    unreachable=0    failed=0 ...
```

Apache terinstal, `mod_rewrite` diaktifkan, dan layanan direstart.

> Jika muncul kesalahan terkait `sudo` password, jalankan dengan opsi `--ask-become-pass`:
```bash
ansible-playbook -v install_apache_playbook.yaml --ask-become-pass
```
Anda akan diminta memasukkan kata sandi sudo pengguna remote.
{: .prompt-tip}

Verifikasi layanan pada server target:
```bash
sudo systemctl status apache2
```
Output yang diharapkan menunjukkan `Active: active (running)`.

Buka browser dan akses `http://192.168.1.103`. Halaman default Apache akan terlihat, membuktikan web server berjalan pada port 80.

## 10. Mengganti Port Apache ke 8081

Untuk mendemonstrasikan perubahan konfigurasi, kita akan mengubah port listen dari 80 menjadi 8081 melalui playbook.

Buat playbook `install_apache_options_playbook.yaml`:
```bash
nano install_apache_options_playbook.yaml
```

Isi:
```yaml
- hosts: webservers
  become: yes
  tasks:
    - name: INSTALL APACHE2
      apt: name=apache2 update_cache=yes state=latest

    - name: ENABLED MOD_REWRITE
      apache2_module: name=rewrite state=present
      notify:
        - RESTART APACHE2

    - name: APACHE2 LISTEN ON PORT 8081
      lineinfile:
        dest: /etc/apache2/ports.conf
        regexp: "^Listen 80"
        line: "Listen 8081"
        state: present
      notify:
        - RESTART APACHE2

    - name: APACHE2 VIRTUALHOST ON PORT 8081
      lineinfile:
        dest: /etc/apache2/sites-available/000-default.conf
        regexp: "^<VirtualHost \*:80>"
        line: "<VirtualHost *:8081>"
        state: present
      notify:
        - RESTART APACHE2

  handlers:
    - name: RESTART APACHE2
      service: name=apache2 state=restarted
```

Penjelasan dua task baru:
- **`APACHE2 LISTEN ON PORT 8081`** : Menggunakan modul `lineinfile` untuk mencari baris yang dimulai `Listen 80` pada file `/etc/apache2/ports.conf`, lalu menggantinya dengan `Listen 8081`.
- **`APACHE2 VIRTUALHOST ON PORT 8081`** : Mengubah `<VirtualHost *:80>` menjadi `<VirtualHost *:8081>` di file konfigurasi situs default.

Kedua tugas ini memberitahu handler yang sama, sehingga Apache akan direstart setelah perubahan file konfigurasi.

Sebelum menjalankan playbook, kondisi awal dapat diperiksa langsung di server target:
```bash
cat /etc/apache2/ports.conf
# output: Listen 80

cat /etc/apache2/sites-available/000-default.conf
# output: <VirtualHost *:80>
```

Jalankan playbook:
```bash
ansible-playbook -v install_apache_options_playbook.yaml
```

Output (contoh):
```
TASK [APACHE2 LISTEN ON PORT 8081] *************************************
changed: [192.168.1.103]
TASK [APACHE2 VIRTUALHOST ON PORT 8081] ********************************
changed: [192.168.1.103]
RUNNING HANDLER [RESTART APACHE2] **************************************
changed: [192.168.1.103]
PLAY RECAP *************************************************************
192.168.1.103 : ok=6    changed=3    unreachable=0    failed=0 ...
```

Verifikasi perubahan pada target:
```bash
cat /etc/apache2/ports.conf
# output: Listen 8081

cat /etc/apache2/sites-available/000-default.conf
# output: <VirtualHost *:8081>
```

Sekarang Apache berjalan pada port 8081. Akses melalui browser dengan `http://192.168.1.103:8081`. Halaman default Apache akan muncul, menandakan perubahan port berhasil.

> Jika playbook gagal dengan masalah hak akses, gunakan `--ask-become-pass` seperti sebelumnya.
{: .prompt-tip}

## Penutup

Kita telah berhasil mengotomatiskan instalasi dan konfigurasi Apache2 menggunakan Ansible, mulai dari setup dasar, pengujian koneksi, hingga penyesuaian port mendengarkan. Pendekatan deklaratif Ansible memungkinkan konfigurasi server yang konsisten, mudah diulang, dan terdokumentasi dalam kode.

Untuk pengembangan lebih lanjut, pertimbangkan:
- Mengganti kata sandi plaintext dengan autentikasi kunci SSH.
- Menggunakan variabel Ansible untuk memisahkan data dari logika playbook.
- Menambahkan roles untuk struktur yang lebih modular.
- Menerapkan templates untuk file konfigurasi yang lebih kompleks.

Dengan fondasi ini, Anda siap mengelola infrastruktur server secara otomatis dan efisien.