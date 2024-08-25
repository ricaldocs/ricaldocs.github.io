---
title: Python Virtual Environment
description: Membuat lingkungan virtual di Python untuk mempermudah proses developments.
categories: [Linux]
tags: [linux, python, open source]
author: rical
---

> Sebelum melanjutkan ke langkah-langkah konfigurasi, pastikan bahwa <a href="https://www.python.org/" target="_blank">Python</a> telah diinstal.
{: .prompt-info }

Masukkan perintah berikut ke terminal untuk melihat versi Python:
```bash
python3 --version
```

## Instalasi Virtual Environment
Gunakan perintah berikut untuk menginstall paket `venv`:

```bash
sudo apt install python3-venv
```

Buat folder, misalnya:

```bash
mkdir projects
```

Buat virtual environment dengan menjalankan perintah:

```bash
python3 -m venv projects/
```

### Mengaktifkan venv

```bash
source projects/bin/activate
```
Setelah diaktfikan, prompt terminal akan menunjukkan nama virtual environment yang menandakan bahwa virtual environment sudah siap digunakan.

### Mematikan venv

``` bash
deactivate
```


## Referensi
- <a href="https://risnandapascal.github.io/ricalwiki.html" target="_blank">ricalWiki</a>





