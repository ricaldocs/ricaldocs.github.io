---
title: Linux Incident Response and Forensics
description: Proses sistematis untuk mendeteksi, menganalisis, dan mengurangi insiden keamanan pada sistem Linux sambil mempertahankan dan memeriksa bukti digital.
categories: [Cybersecurity]
tags: [linux, forensics, incident response]
author: rical
last_modified_at: 2026-06-01
---

## Perintah dan Alat Penting
Bagian ini menjelaskan perintah dan alat penting untuk menyelidiki aktivitas pengguna, sumber daya sistem, pengaturan jaringan, proses, layanan, entri log, dan file.

### Akun Pengguna
```bash
$ echo $USER
$ passwd -S <USER>
$ grep :0: /etc/passwd
$ cat /etc/passwd
$ cat /etc/shadow
$ cat /etc/group
$ cat /etc/sudoers
```

### Informasi Umum
```bash
$ date
$ cat /etc/timezone
$ uname -a
$ uname -m
$ cat /etc/*-release
$ hostname
$ cat /etc/hostname
```

### Sumber Daya Sistem
```bash
$ uptime
$ free
$ df
$ cat /proc/meminfo
$ cat /proc/mounts
```

### Pengaturan Jaringan
```bash
$ ifconfig
$ lsof -i
$ netstat -ano
$ netstat -nap
$ netstat -antp
$ netstat -antp | grep "ESTAB"
$ netstat -rn
$ route
$ cat /etc/hosts
$ arp -a
$ echo $PATH
```

### Proses
```bash
$ ps -aux
$ ps aux --sort=-%mem | head -n 10
$ top
$ htop
$ vmstat -s
$ lsof -p <PID>
$ pstree
```

### Layanan
```bash
$ service --status-all
$ more /etc/hosts
$ more /etc/resolv.conf
$ cat /etc/crontab
$ crontab -u <USER> -l
$ tail -f /etc/cron.*/*
$ cat /etc/cron.daily
$ cat /etc/cron.hourly
$ cat /etc/cron.monthly
$ cat /etc/cron.weekly
```

### Entri Log
```bash
$ lastlog
$ last
$ cat /var/log/lastlog
$ grep -v cron /var/log/auth.log* | grep -v sudo | grep -i user
$ grep -v cron /var/log/auth.log* | grep -v sudo | grep -i Accepted
$ grep -v cron /var/log/auth.log* | grep -v sudo | grep -i failed
$ grep -v cron /var/log/auth.log* | grep -i "login:session"
```

### File
```bash
$ find /home/ -type f -size +512k -exec ls -lh {} \;
$ find /etc/ -readable -type f 2>/dev/null
$ find / –perm -4000 -user root -type f
$ find / -mtime -0 -ctime -7
$ find / -atime 2 -ls 2>/dev/null
$ find / -mtime -2 -ls 2>/dev/null
```

### Tinjauan Aktivitas
```bash
$ history
$ cat /home/$USER/.*_history
$ cat /home/$USER/.bash_history
$ cat /root/.bash_history
$ cat /root/.mysql_history
$ cat /home/$USER/.ftp_history
```

### Persistence areas
#### Direktori
- `/etc/cron*/`{: .filepath}
- `/etc/incron.d/*`{: .filepath}
- `/etc/init.d/*`{: .filepath}
- `/etc/rc*.d/*`{: .filepath}
- `/etc/systemd/system/*`{: .filepath}
- `/etc/update.d/*`{: .filepath}
- `/var/spool/cron/*`{: .filepath}
- `/var/spool/incron/*`{: .filepath}
- `/var/run/motd.d/*`{: .filepath}

#### File
- `/etc/passwd`{: .filepath}
- `/etc/sudoers`{: .filepath}
- `/home/<user>/.ssh/authorized_keys`{: .filepath}
- `/home/<user>/.bashrc`{: .filepath}

## Alat untuk Incident Response dan Forensik Linux
- **Pemantauan Jaringan**: [tcpdump](https://www.tcpdump.org/), [Wireshark](https://www.wireshark.org/), [Zeek](https://zeek.org/)
- **Analisis Log**: logwatch, Splunk, ELK stack
- **Filesystem Analysis**: [Sleuthkit](https://sleuthkit.org/), [Autopsy](https://www.autopsy.com/), extundelete
- **Analisis Memori**: Volatility, Lime
- **Disk Imaging**: dd, dcfldd
- **Pemantauan Sistem**: top, htop, ps, sar

## Praktik Terbaik untuk Incident Response
Untuk mengelola insiden secara efektif pada sistem Linux, penting untuk mengikuti praktik terbaik yang meningkatkan proses respons insiden. Praktik-praktik ini meliputi:

### Persiapan
- Buat rencana *incident response* yang jelas dan komprehensif yang menguraikan peran, tanggung jawab, dan prosedur untuk merespons insiden.
- Lakukan sesi pelatihan secara berkala untuk tim *incident response* agar mereka familiar dengan alat, teknik, dan prosedur.
- Simpan dokumentasi yang rinci tentang konfigurasi sistem, diagram jaringan, dan prosedur *incident response* untuk memfasilitasi respons yang cepat selama insiden.

### Deteksi dan Analisis
- Gunakan alat pemantauan untuk mendeteksi anomali dan potensi insiden keamanan secara *real-time*.
- Pastikan bahwa *logging* diaktifkan pada semua sistem kritis dan bahwa log dikumpulkan dan dianalisis secara teratur.
- Tetap terinformasi tentang ancaman dan kerentanan terbaru yang mungkin mempengaruhi sistem Anda.

### Penahanan, Penghapusan, dan Pemulihan
- Kembangkan strategi untuk menahan insiden dengan cepat untuk mencegah kerusakan lebih lanjut. Ini mungkin termasuk mengisolasi sistem yang terpengaruh atau menonaktifkan akun yang terkompromi.
- Identifikasi dan hilangkan penyebab utama insiden, memastikan bahwa *malware* atau titik akses yang tidak sah dihapus.
- Tetapkan rencana pemulihan untuk mengembalikan sistem ke operasi normal, termasuk pemulihan data dan penguatan sistem.

### Kegiatan Pasca-Insiden
- Setelah insiden, lakukan tinjauan menyeluruh untuk menganalisis apa yang terjadi, bagaimana insiden ditangani, dan perbaikan apa yang dapat dilakukan.
- Revisi rencana respons insiden dan dokumentasi berdasarkan pelajaran yang dipetik dari insiden.
- Terapkan proses peningkatan berkelanjutan untuk meningkatkan kemampuan *incident response* seiring waktu.

## Kesimpulan
Linux Incident Response and Forensics adalah aspek kritis dalam menjaga keamanan dan integritas sistem Linux. Dengan memanfaatkan perintah dan alat yang telah dijelaskan, serta mematuhi praktik terbaik, organisasi dapat secara efektif mendeteksi, menganalisis, dan merespons insiden keamanan sambil mempertahankan bukti digital yang berharga.

## Pranala Luar
- [NIST Special Publication 800-61 - Panduan Penanganan Insiden Keamanan Komputer](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [The Art of Memory Forensics](https://www.memoryanalysis.net/)
- [DFIR Community](https://www.dfir.science/)
- [Forensic Focus](https://www.forensicfocus.com/)

