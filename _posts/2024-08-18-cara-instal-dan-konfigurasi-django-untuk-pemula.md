---
title: Cara Instal dan Konfigurasi Django untuk Pemula
description: Pelajari cara instal Django dan buat aplikasi web pertama Anda dengan mudah. Panduan langkah demi langkah untuk pemula mulai dari setup proyek hingga menjalankan server development.
categories: [no categories]
tags: [python, python django]
author: rical
last_modified_at: 2026-06-01
---

## Instalasi Django
Instal Django dengan menggunakan `pip`:
```bash
pip install django
```

Jalankan perintah berikut untuk membuat proyek bernama `myproject`:
```bash
django-admin startproject myproject
```

Masuk ke direktori proyek:
```bash
cd myproject
```

Jalankan server pengembangan, gunakan perintah berikut:
```bash
python3 manage.py runserver
```

> Secara default, server akan berjalan di [http://127.0.0.1:8000/](http://127.0.0.1:8000/). buka browser dan kunjungi URL tersebut untuk melihat halaman awal Django.
{: .prompt-info}

## Membuat aplikasi Django
Buat aplikasi di dalam proyek. Misalnya, untuk membuat aplikasi bernama `myapp`, jalankan:
```bash
python3 manage.py startapp myapp
```

Buka file `settings.py` yang terletak di dalam folder `myproject`{: .filepath} dan tambahkan `myapp` ke dalam daftar `INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    ...
    'myapp',
]
```

Buka file `views.py` di dalam folder `myapp`{: .filepath} dan tambahkan kode berikut:

```python
from django.http import HttpResponse

def home(request):
    return HttpResponse("Hello Friends! This is my first Django app.")
```

Buat file baru bernama `urls.py` di dalam folder `myapp`{: .filepath} dan tambahkan kode berikut:
```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
]
```

Kemudian, buka file `urls.py` di dalam folder `myproject`{: .filepath} dan tambahkan rute untuk aplikasi Anda:
```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('myapp.urls')),
]
```

Setelah semua pengaturan selesai, jalankan kembali server pengembangan:
```bash
python3 manage.py runserver
```

Sekarang, kunjungi [http://127.0.0.1:8000/](http://127.0.0.1:8000/), pesan **"Hello Friends! This is my first Django app."** akan muncul.






