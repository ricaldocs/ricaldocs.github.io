---
title: Konfigurasi Wazuh Agent untuk Keamanan Host — FIM, Rootcheck, dan SCA
description: Panduan lengkap konfigurasi Wazuh agent host untuk SOC, meliputi instalasi via dashboard, rsyslog, ossec.conf optimal (FIM, rootcheck, SCA, syscollector), plus verifikasi alert dan troubleshooting.
categories: [Digital Independence, Monitoring]
tags: [wazuh, soc, linux, forensics, incident response, podman]
author: rical
last_modified_at: 2026-09-20
---

> Panduan ini mengasumsikan Anda telah memiliki Wazuh single-node (manager, indexer, dashboard) yang berjalan. Jika belum, ikuti terlebih dahulu [Panduan Lengkap Instalasi dan Konfigurasi Wazuh](https://docs.ricalnet.my.id/posts/panduan-lengkap-instalasi-dan-konfigurasi-wazuh/).
{: .prompt-tip}

## Mengapa Fokus pada Keamanan Host?

Wazuh adalah platform SIEM/XDR open-source yang mampu memantau banyak lapisan: container, cloud workload, endpoint, dan host. Namun, memantau semuanya sekaligus pada satu agent sering menimbulkan noise, overhead, dan ambiguitas alert. Untuk infrastruktur yang menjalankan container rootless (Podman), praktik terbaiknya adalah memisahkan peran agent:

- Agent host — bertanggung jawab atas keamanan sistem operasi: integritas file, rootkit, konfigurasi keamanan, log sistem.
- Agent container — opsional, dijalankan sebagai sidecar atau via socket Podman, khusus untuk event runtime container.

Artikel ini membahas agent host secara menyeluruh. Tujuannya untuk menghasilkan telemetri keamanan yang bersih, dapat ditindaklanjuti, dan minim false positive — tanpa membebani CPU/RAM host secara berlebihan.

## 1. Instalasi Agent via Wazuh Dashboard

Cara paling andal untuk memasang agent adalah melalui Wazuh Dashboard, karena wizard-nya menghasilkan perintah instalasi yang sudah disesuaikan dengan versi manager Anda.

Langkah:

1. Buka Wazuh Dashboard → menu Agents management → Summary → Deploy new agent.
2. Pilih sistem operasi target (Debian/Ubuntu, RHEL/CentOS, Windows, macOS).
3. Isi konfigurasi yang diminta:
   ![alt text](<../assets/img/posts/2026-09-20-konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/Screenshot From 2026-09-20 10-10-55.png>)
   - Wazuh Server Address: `127.0.0.1` (atau IP manager Anda)
   - Agent Name: `my-wazuh-agent` (contoh: `ricalnet-os`)
   - Agent Group: `default` (atau grup kustom)

4. Salin perintah instalasi yang dihasilkan wizard.
5. Jalankan perintah tersebut pada terminal host target.

Contoh perintah yang dihasilkan (Debian/Ubuntu ARM64):

```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.7-1_arm64.deb && sudo WAZUH_MANAGER='127.0.0.1' WAZUH_AGENT_GROUP='default' WAZUH_AGENT_NAME='ricalnet-os' dpkg -i ./wazuh-agent_4.14.7-1_arm64.deb

sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

Mengapa via Dashboard? Karena wizard otomatis menyelaraskan versi agent dengan versi manager, mengurangi risiko mismatch protokol enrollment, dan menyertakan `authd.pass` yang benar untuk auto-enrollment.

Verifikasi agent sudah terdaftar di manager:

```bash
podman exec -it wazuh.manager /var/ossec/bin/agent_control -l
```

Cari nama agent Anda dengan status Active:

```
Wazuh agent_control. List of available agents:
   ID: 000, Name: wazuh.manager (server), IP: 127.0.0.1, Active/Local
   ID: 001, Name: ricalnet-os, IP: any, Active
```

## 2. Instalasi rsyslog

### Mengapa rsyslog?

Wazuh memiliki ruleset bawaan yang sangat kaya untuk file log klasik seperti `/var/log/auth.log` (SSH, sudo, su) dan `/var/log/syslog` (kernel, service, cron). Ruleset ini dirancang untuk format syslog tradisional.

Masalahnya, pada instalasi Debian 12+/13 minimal dan Raspberry Pi OS modern, rsyslog tidak lagi terpasang secara default — sistem hanya mengandalkan `systemd-journald`. Akibatnya:

- `/var/log/auth.log` dan `/var/log/syslog` tidak ada.
- Wazuh logcollector akan menampilkan error `Could not open file`.
- Banyak ruleset siap pakai menjadi tidak berguna.

`journald` memang bisa dibaca Wazuh, tetapi formatnya JSON terstruktur dan tidak selalu dipetakan ke ruleset yang sama. Solusi paling bersih adalah instal rsyslog agar kedua file log tersedia dalam format klasik.

### Instalasi

```bash
sudo apt update
sudo apt install -y rsyslog
sudo systemctl enable --now rsyslog
sudo systemctl status rsyslog --no-pager
```

Verifikasi file log sudah dibuat:

```bash
ls -l /var/log/auth.log /var/log/syslog
```

Output yang diharapkan:

```
-rw-r----- 1 root adm /var/log/auth.log
-rw-r----- 1 root adm /var/log/syslog
```

> File akan muncul setelah ada aktivitas log pertama (login, service restart). Jika belum ada, tunggu 30–60 detik atau trigger login SSH.
{: .prompt-info}

## 3. Menyusun Ulang `ossec.conf` untuk Keamanan Host

File `/var/ossec/etc/ossec.conf` adalah jantung konfigurasi agent. Konfigurasi default menyertakan banyak modul yang tidak relevan untuk host (docker-listener, monitoring log web server, dsb). Kita akan menulis ulang agar fokus dan bersih.

### 3.1 Ganti Isi File

```bash
sudo cp /var/ossec/etc/ossec.conf /var/ossec/etc/ossec.conf.bak
sudo nano /var/ossec/etc/ossec.conf
```

Hapus semua isi (Ctrl+K berulang), lalu paste konfigurasi berikut:

```xml
<!--
  Wazuh Agent - Host Security Focused Configuration
  Host: RICALNET OS (ARM64, Debian 13)
  Scope: FIM, Rootcheck, SCA, Syscollector, Host Logs, Active Response
-->

<ossec_config>
  <!-- ======================== CLIENT ======================== -->
  <client>
    <server>
      <address>127.0.0.1</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
    <config-profile>debian, debian13</config-profile>
    <notify_time>20</notify_time>
    <time-reconnect>60</time-reconnect>
    <auto_restart>yes</auto_restart>
    <crypto_method>aes</crypto_method>
    <enrollment>
      <enabled>yes</enabled>
      <agent_name>ricalnet-infra</agent_name>
      <groups>default</groups>
      <authorization_pass_path>etc/authd.pass</authorization_pass_path>
    </enrollment>
  </client>

  <client_buffer>
    <disabled>no</disabled>
    <queue_size>5000</queue_size>
    <events_per_second>500</events_per_second>
  </client_buffer>

  <!-- ====================== ROOTCHECK ======================= -->
  <rootcheck>
    <disabled>no</disabled>
    <check_files>yes</check_files>
    <check_trojans>yes</check_trojans>
    <check_dev>yes</check_dev>
    <check_sys>yes</check_sys>
    <check_pids>yes</check_pids>
    <check_ports>yes</check_ports>
    <check_if>yes</check_if>

    <frequency>43200</frequency>

    <rootkit_files>etc/shared/rootkit_files.txt</rootkit_files>
    <rootkit_trojans>etc/shared/rootkit_trojans.txt</rootkit_trojans>

    <skip_nfs>yes</skip_nfs>

    <ignore>/var/lib/containerd</ignore>
    <ignore>/var/lib/docker/overlay2</ignore>
    <ignore>/home/ricalnet/.local/share/containers</ignore>
  </rootcheck>

  <!-- ======================== CIS-CAT ======================= -->
  <wodle name="cis-cat">
    <disabled>yes</disabled>
    <timeout>1800</timeout>
    <interval>1d</interval>
    <scan-on-start>yes</scan-on-start>
    <java_path>wodles/java</java_path>
    <ciscat_path>wodles/ciscat</ciscat_path>
  </wodle>

  <!-- ======================= OSQUERY ========================= -->
  <wodle name="osquery">
    <disabled>yes</disabled>
    <run_daemon>yes</run_daemon>
    <log_path>/var/log/osquery/osqueryd.results.log</log_path>
    <config_path>/etc/osquery/osquery.conf</config_path>
    <add_labels>yes</add_labels>
  </wodle>

  <!-- ====================== SYSCOLLECTOR ==================== -->
  <wodle name="syscollector">
    <disabled>no</disabled>
    <interval>1h</interval>
    <scan_on_start>yes</scan_on_start>
    <hardware>yes</hardware>
    <os>yes</os>
    <network>yes</network>
    <packages>yes</packages>
    <ports all="yes">yes</ports>
    <processes>yes</processes>
    <users>yes</users>
    <groups>yes</groups>
    <services>yes</services>
    <browser_extensions>yes</browser_extensions>

    <synchronization>
      <max_eps>10</max_eps>
    </synchronization>
  </wodle>

  <!-- ========================= SCA ========================== -->
  <sca>
    <enabled>yes</enabled>
    <scan_on_start>yes</scan_on_start>
    <interval>12h</interval>
    <skip_nfs>yes</skip_nfs>
  </sca>

  <!-- =============== SYSCHECK / FILE INTEGRITY ============== -->
  <syscheck>
    <disabled>no</disabled>
    <frequency>43200</frequency>
    <scan_on_start>yes</scan_on_start>

    <!-- Direktori sistem kritis -->
    <directories check_all="yes" report_changes="yes" realtime="yes">/etc</directories>
    <directories check_all="yes" report_changes="yes">/usr/bin,/usr/sbin</directories>
    <directories check_all="yes" report_changes="yes">/bin,/sbin,/boot</directories>

    <!-- Direktori keamanan kritis -->
    <directories check_all="yes" realtime="yes">/root</directories>
    <directories check_all="yes" realtime="yes">/etc/ssh</directories>
    <directories check_all="yes" realtime="yes">/etc/pam.d</directories>
    <directories check_all="yes" realtime="yes">/etc/sudoers.d</directories>
    <directories check_all="yes" realtime="yes">/etc/systemd/system</directories>

    <!-- SSH key user -->
    <directories check_all="yes" realtime="yes">/home/ricalnet/.ssh</directories>

    <!-- Ignore file umum -->
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
    <ignore>/etc/mail/statistics</ignore>
    <ignore>/etc/random-seed</ignore>
    <ignore>/etc/random.seed</ignore>
    <ignore>/etc/adjtime</ignore>
    <ignore>/etc/httpd/logs</ignore>
    <ignore>/etc/utmpx</ignore>
    <ignore>/etc/wtmpx</ignore>
    <ignore>/etc/cups/certs</ignore>
    <ignore>/etc/dumpdates</ignore>
    <ignore>/etc/svc/volatile</ignore>

    <!-- Ignore socket & file volatile (penting untuk hindari error FIM) -->
    <ignore type="sregex">\.sock$</ignore>
    <ignore type="sregex">\.pid$</ignore>

    <!-- Ignore socket symlink di /etc/alternatives -->
    <ignore>/etc/alternatives/php-fpm.sock</ignore>
    <ignore type="sregex">^/etc/alternatives/.*\.sock$</ignore>

    <!-- Ignore log, swp, tmp -->
    <ignore type="sregex">.log$|.swp$|.tmp$</ignore>

    <!-- Jangan diff kunci privat -->
    <nodiff>/etc/ssl/private.key</nodiff>

    <skip_nfs>yes</skip_nfs>
    <skip_dev>yes</skip_dev>
    <skip_proc>yes</skip_proc>
    <skip_sys>yes</skip_sys>

    <process_priority>10</process_priority>
    <max_eps>50</max_eps>

    <synchronization>
      <enabled>yes</enabled>
      <interval>5m</interval>
      <max_eps>10</max_eps>
    </synchronization>
  </syscheck>

  <!-- =================== LOG ANALYSIS HOST ================== -->
  <localfile>
    <log_format>command</log_format>
    <command>df -P</command>
    <frequency>360</frequency>
  </localfile>

  <localfile>
    <log_format>full_command</log_format>
    <command>netstat -tulpn | sed 's/\([[:alnum:]]\+\)\ \+[[:digit:]]\+\ \+[[:digit:]]\+\ \+\(.*\):\([[:digit:]]*\)\ \+\([0-9\.\:\*]\+\).\+\ \([[:digit:]]*\/[[:alnum:]\-]*\).*/\1 \2 == \3 == \4 \5/' | sort -k 4 -g | sed 's/ == \(.*\) ==/:\1/' | sed 1,2d</command>
    <alias>netstat listening ports</alias>
    <frequency>360</frequency>
  </localfile>

  <localfile>
    <log_format>full_command</log_format>
    <command>last -n 20</command>
    <frequency>360</frequency>
  </localfile>

  <!-- =================== ACTIVE RESPONSE ==================== -->
  <active-response>
    <disabled>no</disabled>
    <ca_store>etc/wpk_root.pem</ca_store>
    <ca_verification>yes</ca_verification>
  </active-response>

  <!-- ======================= LOGGING ======================== -->
  <logging>
    <log_format>plain</log_format>
  </logging>
</ossec_config>

<!-- ==================== SUMBER LOG SISTEM ================== -->
<ossec_config>
  <!-- journald: semua log systemd (SSH, sudo, service, kernel) -->
  <localfile>
    <log_format>journald</log_format>
    <location>journald</location>
  </localfile>

  <!-- Autentikasi (SSH, sudo, su) -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>

  <!-- Log sistem umum -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/syslog</location>
  </localfile>

  <!-- Instalasi paket -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/dpkg.log</location>
  </localfile>

  <!-- Log Active Response Wazuh -->
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/ossec/logs/active-responses.log</location>
  </localfile>
</ossec_config>
```

Simpan: `Ctrl+X` → `Y` → Enter.

### 3.2 Mengapa Konfigurasi Ini Dirancang Seperti Ini?

Setiap blok punya alasan teknis yang jelas:

| Blok | Tujuan | Alasan Teknis |
|------|--------|---------------|
| `<client>` | Koneksi ke manager | Menentukan alamat, port, protokol, dan mekanisme enrollment |
| `<client_buffer>` | Buffer event | Mencegah kehilangan event saat manager down |
| `<rootcheck>` | Deteksi rootkit | Memindai file sistem terhadap signature rootkit & trojan yang diketahui |
| `<wodle name="cis-cat">` | Benchmark CIS | Nonaktif secara default karena butuh Java. Aktifkan bila ingin audit CIS |
| `<wodle name="osquery">` | Query OS | Nonaktif. Sangat berguna jika Anda ingin SQL-like query ke OS |
| `<wodle name="syscollector">` | Inventaris | Mengumpulkan HW, OS, paket, port, proses, user — penting untuk vulnerability assessment |
| `<sca>` | Konfigurasi keamanan | Menjalankan CIS Debian 13 benchmark setiap 12 jam |
| `<syscheck>` | FIM | Memantau integritas file kritis dengan realtime pada direktori sensitif |
| `<localfile>` | Analisis log | Mengumpulkan output command dan log sistem |
| `<active-response>` | Respon otomatis | Memungkinkan manager mengirim perintah balik (mis. block IP) |

### 3.3 Detail Penting pada `<syscheck>`

`realtime="yes"` menggunakan `inotify` di kernel, sehingga perubahan file terdeteksi dalam hitungan detik. Ini hanya diaktifkan pada direktori yang jarang berubah ( `/etc/ssh`, `/etc/pam.d`, `/root`, dll). Direktori besar seperti `/usr/bin` dan `/usr/sbin` menggunakan scan terjadwal (12 jam) untuk menghemat CPU.

`<ignore type="sregex">` menggunakan regex (bukan glob) untuk mengabaikan file. Pattern `\.sock$` mencegah Wazuh mencoba membaca Unix socket sebagai file biasa — yang akan menghasilkan error `w_compress_gzfile` dan menghabiskan I/O.

`<nodiff>` mencegah Wazuh menghitung diff konten file — penting untuk file besar atau file biner seperti kunci privat, agar tidak membocorkan isi ke manager.

### 3.4 Detail Penting pada Sumber Log

| Sumber | Cakupan | Mengapa |
|--------|---------|---------|
| `journald` | Semua log systemd | Menangkap service, kernel, SSH, sudo dalam format terstruktur |
| `/var/log/auth.log` | Autentikasi | Ruleset Wazuh sangat kaya untuk SSH brute force, sudo abuse, su |
| `/var/log/syslog` | Sistem umum | Kernel, cron, service messages |
| `/var/log/dpkg.log` | Instalasi paket | Deteksi instalasi tool berbahaya (netcat, nmap, dsb) |
| `active-responses.log` | Log AR Wazuh | Audit eksekusi active response |

## 4. Start & Verifikasi

### 4.1 Start Agent

```bash
sudo systemctl start wazuh-agent
sleep 10
sudo systemctl status wazuh-agent --no-pager
```

Status harus `Active: active (running)`:

```
● wazuh-agent.service - Wazuh agent
     Loaded: loaded (/usr/lib/systemd/system/wazuh-agent.service; enabled; preset: enabled)
     Active: active (running)
     CGroup: /system.slice/wazuh-agent.service
             ├─ /var/ossec/bin/wazuh-agentd
             ├─ /var/ossec/bin/wazuh-execd
             ├─ /var/ossec/bin/wazuh-syscheckd
             ├─ /var/ossec/bin/wazuh-logcollector
             └─ /var/ossec/bin/wazuh-modulesd

env[399231]: Killing wazuh-execd...
env[399231]: Wazuh v4.14.7 Stopped
env[399231]: Starting Wazuh v4.14.7...
env[399231]: Started wazuh-execd...
env[399231]: wazuh-agentd already running...
env[399231]: Started wazuh-syscheckd...
env[399231]: Started wazuh-logcollector...
env[399231]: Started wazuh-modulesd...
env[399231]: Completed.
systemd[1]: Reloaded wazuh-agent.service - Wazuh agent.
```

### 4.2 Cek Log Tidak Ada ERROR

```bash
sudo tail -50 /var/ossec/logs/ossec.log
```

### 4.3 Verifikasi Spesifik

```bash
# Pastikan tidak ada docker-listener
sudo grep -i "docker" /var/ossec/logs/ossec.log | tail -5

# Pastikan tidak ada error file log
sudo grep -i "Could not open file" /var/ossec/logs/ossec.log | tail -5

# Pastikan tidak ada error socket
sudo grep -i "w_compress_gzfile" /var/ossec/logs/ossec.log | tail -5

# Pastikan agent terhubung ke manager
sudo grep -iE "Connected|enrollment" /var/ossec/logs/ossec.log | tail -5
```

Semua perintah di atas seharusnya tidak menghasilkan output baru (kecuali baris `Connected`):

```
wazuh-agentd: Connected to the server ([127.0.0.1]:1514/tcp).
```

## 5. Verifikasi Alert Masuk ke Dashboard

### 5.1 Trigger Event Uji

#### Test 1 — Login SSH gagal

```bash
ssh invaliduser@127.0.0.1 -p 22
# Masukkan password salah 3-5 kali
```

#### Test 2 — Modifikasi file FIM

```bash
sudo touch /etc/wazuh-test-$(date +%s)
sudo rm /etc/wazuh-test-*
```

#### Test 3 — sudo command

```bash
sudo ls /root
```

### 5.2 Cek di Dashboard

Buka Wazuh Dashboard: `https://127.0.0.1:8443`

Menu: Threat Intelligence → Threat Hunting → Events

Filter query untuk SSH gagal:
```
agent.name: "ricalnet-os" AND rule.groups: "authentication_failed"
```

![alt text](<../assets/img/posts/2026-09-20-konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/Screenshot From 2026-09-20 11-16-33.png>)

![alt text](<../assets/img/posts/2026-09-20-konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/Screenshot From 2026-09-20 10-28-11.png>)

Filter query untuk test FIM:
```
agent.name: "ricalnet-os" AND rule.groups: "syscheck"
```

![alt text](<../assets/img/posts/2026-09-20-konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/Screenshot From 2026-09-20 11-17-29.png>)

Filter query untuk test sudo:
```
agent.name: "ricalnet-os" AND data.command: "/usr/bin/ls /root"
```

![alt text](<../assets/img/posts/2026-09-20-konfigurasi-wazuh-agent-untuk-keamanan-host-fim-rootcheck-dan-sca/Screenshot From 2026-09-20 11-17-37.png>)

Lalu ganti dengan filter berikut untuk melihat jenis event lain:

| Filter | Event yang muncul |
|--------|-------------------|
| `rule.groups: "syscheck"` | Perubahan file FIM |
| `rule.groups: "rootcheck"` | Deteksi rootkit |
| `rule.groups: "sca"` | CIS benchmark |
| `rule.groups: "authentication_failed"` | SSH login gagal |
| `rule.groups: "sudo"` | Penggunaan sudo |
| `rule.groups: "pam"` | Aktivitas PAM |
| `rule.groups: "dpkg"` | Install/uninstall paket |
| `agent.name: "ricalnet-os"` | Semua event dari agent ini |

## 6. Maintenance Rutin

### Harian

```bash
sudo systemctl status wazuh-agent rsyslog
```

### Mingguan

```bash
sudo tail -100 /var/ossec/logs/ossec.log | grep -iE "error|critical"
```

### Bulanan

```bash
# Cek disk usage log wazuh
sudo du -sh /var/ossec/logs/
# Rotasi jika perlu
sudo /var/ossec/bin/wazuh-control rotate
```

## 7. Troubleshooting

Jika ada langkah yang error, cek output dari:

```bash
sudo systemctl status wazuh-agent --no-pager
sudo tail -30 /var/ossec/logs/ossec.log
```

## Kesimpulan

Dengan konfigurasi di atas, Anda mendapatkan visibilitas keamanan host yang bersih dan dapat ditindaklanjuti tanpa noise dari monitoring container. Prinsip utamanya:

1. Pisahkan peran — agent host fokus pada keamanan OS, agent container fokus pada runtime.
2. Sediakan sumber log yang tepat — rsyslog memastikan ruleset Wazuh dapat bekerja maksimal.
3. Pilih direktori FIM dengan bijak — realtime hanya untuk area yang jarang berubah, scheduled untuk sisanya.
4. Abaikan yang tidak perlu — socket, PID, log, dan file volatile hanya menghasilkan noise dan error.
5. Verifikasi berlapis — dari service, log agent, hingga arsip manager.

Setelah semua langkah selesai, agent Anda siap menjadi sensor keamanan host yang andal dalam arsitektur SOC berbasis Wazuh.

Langkah Selanjutnya: [Integrasi Wazuh ke Grafana — Unified SOC Dashboard dengan Plugin Data Source](https://docs.ricalnet.my.id/posts/integrasi-wazuh-ke-grafana-unified-soc-dashboard-dengan-plugin-data-source/)

## Tabel Filter Lengkap Wazuh Dashboard untuk Agent `ricalnet-os`

Gunakan ini sebagai referensi harian SOC.

### 1. Filter Dasar (Esensial)

| Filter | Event yang muncul |
|--------|-------------------|
| `agent.name: "ricalnet-os"` | Semua event dari agent ini |
| `rule.groups: "syscheck"` | Perubahan file (FIM): added, modified, deleted |
| `rule.groups: "rootcheck"` | Deteksi rootkit, trojan, file mencurigakan |
| `rule.groups: "sca"` | Hasil CIS Debian 13 Benchmark |
| `rule.groups: "authentication_failed"` | SSH login gagal, brute force |
| `rule.groups: "authentication_success"` | SSH login berhasil |
| `rule.groups: "sudo"` | Penggunaan sudo (berhasil & gagal) |
| `rule.groups: "pam"` | Sesi PAM: login, logout, privilege change |
| `rule.groups: "dpkg"` | Install, uninstall, upgrade paket |
| `rule.groups: "syslog"` | Event syslog umum |
| `rule.groups: "journald"` | Event dari systemd-journald |

### 2. Filter Berdasarkan Rule ID Spesifik

| Filter | Event yang muncul |
|--------|-------------------|
| `rule.id: 550` | File integrity checksum changed |
| `rule.id: 551` | File integrity checksum changed (retry) |
| `rule.id: 552` | File size changed |
| `rule.id: 553` | File deleted (level 7, MITRE T1070.004, T1485) |
| `rule.id: 554` | File added (level 5) |
| `rule.id: 555` | File permissions changed |
| `rule.id: 556` | File owner changed |
| `rule.id: 557` | File group changed |
| `rule.id: 558` | File modification time changed |
| `rule.id: 5401` | Successful sudo to ROOT executed |
| `rule.id: 5402` | Successful sudo to ROOT executed (detail) |
| `rule.id: 5403` | Incorrect sudo password |
| `rule.id: 5501` | PAM: Login session opened |
| `rule.id: 5502` | PAM: Login session closed |
| `rule.id: 5710` | Attempt to login using non-existent user (SSH) |
| `rule.id: 5716` | SSHD message |
| `rule.id: 5760` | SSHD authentication success |
| `rule.id: 5763` | SSHD authentication failed |

### 3. Filter Berdasarkan Severity (Level)

| Filter | Event yang muncul |
|--------|-------------------|
| `rule.level: [12 TO *]` | Critical — butuh tindakan segera |
| `rule.level: [10 TO 11]` | High — investigasi dalam 24 jam |
| `rule.level: [7 TO 9]` | Medium — tinjau harian |
| `rule.level: [4 TO 6]` | Low — tinjau mingguan |
| `rule.level: [0 TO 3]` | Info — arsip saja |

### 4. Filter Berdasarkan MITRE ATT&CK

| Filter | Event yang muncul |
|--------|-------------------|
| `rule.mitre.tactic: "Privilege Escalation"` | Upaya eskalasi privilege |
| `rule.mitre.tactic: "Persistence"` | Mekanisme persistensi |
| `rule.mitre.tactic: "Defense Evasion"` | Upaya menghindari deteksi |
| `rule.mitre.tactic: "Credential Access"` | Akses kredensial |
| `rule.mitre.tactic: "Discovery"` | Reconnaissance sistem |
| `rule.mitre.tactic: "Lateral Movement"` | Pergerakan lateral |
| `rule.mitre.tactic: "Impact"` | Destruksi data / DoS |
| `rule.mitre.id: "T1070.004"` | Indicator Removal: File Deletion |
| `rule.mitre.id: "T1548.003"` | Abuse Elevation Control: Sudo |
| `rule.mitre.id: "T1110"` | Brute Force |
| `rule.mitre.id: "T1078"` | Valid Accounts |

### 5. Filter Berdasarkan Compliance Framework

| Filter | Event yang muncul |
|--------|-------------------|
| `rule.pci_dss: *` | Event terkait PCI-DSS |
| `rule.gdpr: *` | Event terkait GDPR |
| `rule.hipaa: *` | Event terkait HIPAA |
| `rule.nist_800_53: *` | Event terkait NIST 800-53 |
| `rule.tsc: *` | Event terkait TSC (SOC 2) |
| `rule.gpg13: *` | Event terkait GPG13 |

### 6. Filter Berdasarkan Sumber Log (Location)

| Filter | Event yang muncul |
|--------|-------------------|
| `location: "syscheck"` | Semua event FIM |
| `location: "/var/log/auth.log"` | Event autentikasi |
| `location: "/var/log/syslog"` | Event sistem umum |
| `location: "/var/log/dpkg.log"` | Event instalasi paket |
| `location: "journald"` | Event systemd-journald |
| `location: "/var/ossec/logs/active-responses.log"` | Event Active Response |

### 7. Filter Berdasarkan Decoder

| Filter | Event yang muncul |
|--------|-------------------|
| `decoder.name: "syscheck_new_entry"` | File baru terdeteksi FIM |
| `decoder.name: "syscheck_deleted"` | File terhapus terdeteksi FIM |
| `decoder.name: "sudo"` | Perintah sudo |
| `decoder.name: "pam"` | Sesi PAM |
| `decoder.name: "sshd"` | Aktivitas SSHD |
| `decoder.name: "dpkg"` | Aktivitas dpkg |

### 8. Filter Kombinasi untuk Skenario Umum

| Skenario | Query |
|----------|-------|
| Investigasi insiden | `agent.name: "ricalnet-os" AND rule.level: [10 TO *]` |
| Audit perubahan konfigurasi | `agent.name: "ricalnet-os" AND rule.groups: "syscheck" AND rule.id: (550 OR 551 OR 555 OR 556 OR 557)` |
| Deteksi brute force SSH | `agent.name: "ricalnet-os" AND rule.id: 5763 AND rule.level: [8 TO *]` |
| Monitoring eskalasi privilege | `agent.name: "ricalnet-os" AND rule.groups: ("sudo" OR "pam")` |
| Deteksi file berbahaya di /etc | `agent.name: "ricalnet-os" AND rule.id: 554 AND syscheck.path: /etc/*` |
| Deteksi penghapusan file kritis | `agent.name: "ricalnet-os" AND rule.id: 553 AND rule.level: [7 TO *]` |
| Aktivitas di luar jam kerja | `agent.name: "ricalnet-os" AND rule.level: [7 TO *] AND @timestamp: [now-8h/h TO now/h]` |
| Persistensi via systemd | `agent.name: "ricalnet-os" AND rule.groups: "syscheck" AND syscheck.path: /etc/systemd/system/*` |
| Modifikasi SSH config | `agent.name: "ricalnet-os" AND rule.groups: "syscheck" AND syscheck.path: /etc/ssh/*` |
| Aktivitas user root langsung | `agent.name: "ricalnet-os" AND data.srcuser: "root"` |
| Semua event compliance PCI-DSS | `agent.name: "ricalnet-os" AND rule.pci_dss: *` |
| Rootkit detection | `agent.name: "ricalnet-os" AND rule.groups: "rootcheck" AND rule.level: [7 TO *]` |

### 9. Filter Berdasarkan Field Khusus Syscheck

| Filter | Event yang muncul |
|--------|-------------------|
| `syscheck.event: "added"` | File ditambahkan |
| `syscheck.event: "modified"` | File dimodifikasi |
| `syscheck.event: "deleted"` | File dihapus |
| `syscheck.mode: "realtime"` | Deteksi via inotify |
| `syscheck.mode: "scheduled"` | Deteksi via scan berkala |
| `syscheck.path: /etc/ssh/*` | Perubahan di direktori SSH |
| `syscheck.path: /etc/pam.d/*` | Perubahan konfigurasi PAM |
| `syscheck.path: /etc/sudoers.d/*` | Perubahan konfigurasi sudoers |
| `syscheck.path: /root/*` | Perubahan di home root |
| `syscheck.uname_after: "root"` | File yang diubah oleh root |
| `syscheck.perm_after: "rwxr-xr-x"` | File dengan permission executable |

### 10. Filter Berdasarkan User dan Sesi

| Filter | Event yang muncul |
|--------|-------------------|
| `data.srcuser: "ricalnet"` | Aktivitas user ricalnet |
| `data.dstuser: "root"` | Aktivitas yang menjadi root |
| `data.srcuser: "invaliduser"` | Login dengan user tidak valid |
| `data.srcip: "127.0.0.1"` | Aktivitas dari localhost |
| `data.srcip: NOT "127.0.0.1"` | Aktivitas dari luar localhost |
| `data.command: *sudo*` | Perintah spesifik via sudo |

### 11. Filter Waktu untuk Deteksi Anomali

| Filter | Event yang muncul |
|--------|-------------------|
| `@timestamp: [now-15m TO now]` | 15 menit terakhir |
| `@timestamp: [now-1h TO now]` | 1 jam terakhir |
| `@timestamp: [now-24h TO now]` | 24 jam terakhir |
| `@timestamp: [now-7d TO now]` | 7 hari terakhir |
| `@timestamp: [now-30d TO now]` | 30 hari terakhir |

### 12. Filter untuk Alert Level Kritis (Prioritas SOC)

| Filter | Event yang muncul |
|--------|-------------------|
| `agent.name: "ricalnet-os" AND rule.level: [10 TO *] AND rule.groups: "syscheck"` | Perubahan file kritis (level tinggi) |
| `agent.name: "ricalnet-os" AND rule.level: [10 TO *] AND rule.groups: "authentication_failed"` | Brute force signifikan |
| `agent.name: "ricalnet-os" AND rule.level: [12 TO *]` | Critical alert — eskalasi segera |
| `agent.name: "ricalnet-os" AND rule.mitre.id: * AND rule.level: [10 TO *]` | Alert dengan MITRE mapping level tinggi |

### 13. Filter untuk Audit Keamanan Berkala

| Filter | Event yang muncul |
|--------|-------------------|
| `agent.name: "ricalnet-os" AND rule.groups: "sca" AND rule.id: 19007` | SCA check failed |
| `agent.name: "ricalnet-os" AND rule.groups: "sca" AND rule.id: 19008` | SCA check passed |
| `agent.name: "ricalnet-os" AND rule.groups: "rootcheck" AND rule.id: 510` | Rootcheck: file baru terdeteksi |
| `agent.name: "ricalnet-os" AND rule.groups: "rootcheck" AND rule.id: 514` | Rootcheck: anomali |
| `agent.name: "ricalnet-os" AND rule.groups: "vulnerability-detector"` | CVE terdeteksi (jika diaktifkan) |

### 14. Filter untuk Deteksi Persistensi

| Filter | Event yang muncul |
|--------|-------------------|
| `agent.name: "ricalnet-os" AND syscheck.path: /etc/systemd/system/*` | Service systemd baru/diubah |
| `agent.name: "ricalnet-os" AND syscheck.path: /etc/cron*` | Perubahan cron |
| `agent.name: "ricalnet-os" AND syscheck.path: /root/.ssh/*` | Perubahan authorized_keys root |
| `agent.name: "ricalnet-os" AND syscheck.path: /home/ricalnet/.ssh/*` | Perubahan SSH key user |
| `agent.name: "ricalnet-os" AND syscheck.path: /etc/rc*.d/*` | Perubahan init script |

### 15. Filter Discovery & Reconnaissance

| Filter | Event yang muncul |
|--------|-------------------|
| `agent.name: "ricalnet-os" AND rule.groups: "syslog" AND data.command: *netstat*` | Penggunaan netstat |
| `agent.name: "ricalnet-os" AND rule.groups: "syslog" AND data.command: *last*` | Penggunaan last |
| `agent.name: "ricalnet-os" AND rule.groups: "syslog" AND data.command: *df*` | Penggunaan df |