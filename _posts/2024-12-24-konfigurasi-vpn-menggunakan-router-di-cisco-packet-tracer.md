---
title: Konfigurasi VPN Menggunakan Router di Cisco Packet Tracer
description: Membahas cara mengonfigurasi dan menggunakan Virtual Private Network (VPN) pada router serta membuat tunnel VPN antara router untuk komunikasi yang aman.
categories: [Cisco Packet Tracer, VPN]
tags: [cisco packet tracer, vpn]
author: rical
last_modified_at: 2026-06-01
---

Dokumentasi ini menunjukkan konfigurasi VPN menggunakan tiga *router* dalam Cisco Packet Tracer. Ini adalah contoh lab yang menunjukkan cara mengonfigurasi VPN *tunnel*.

![VPN Configuration in Cisco Packet Tracer](/assets/img/posts/2024-12-24-konfigurasi-vpn-menggunakan-router-di-cisco-packet-tracer/vpn-configuration.png)

### Jaringan yang Digunakan
> Total ada empat jaringan yang digunakan dalam konfigurasi ini:
- Jaringan 192.168.1.0/24
- Jaringan 192.168.2.0/24
- Jaringan 1.0.0.0/8
- Jaringan 2.0.0.0/8
{: .prompt-info}

## Konfigurasi Router
Langkah pertama yang akan dilakukan adalah memberikan alamat IP pada setiap antarmuka *router* dan juga memberikan alamat IP pada komputer yang digunakan di sini.

### Konfigurasi Router R1
```
Router>enable
Router#config t
Router(config)#host r1
r1(config)#int fa0/0
r1(config-if)#ip add 192.168.1.1 255.255.255.0 
r1(config-if)#no shut
r1(config-if)#exit
r1(config)#int fa0/1
r1(config-if)#ip address 1.0.0.1 255.0.0.0
r1(config-if)#no shut
```

### Konfigurasi Router R2
```
Router>enable
Router#config t
Router(config)#host r2
r2(config)#int fa0/0
r2(config-if)#ip add 1.0.0.2 255.0.0.0
r2(config-if)#no shut
r2(config-if)#exit
r2(config)#int fa0/1
r2(config-if)#ip add 2.0.0.1 255.0.0.0
r2(config-if)#no shut
```

### Konfigurasi Router R3
```
Router>enable
Router#config t
Router(config)#host r3
r3(config)#int fa0/0
r3(config-if)#ip add 2.0.0.2 255.0.0.0
r3(config-if)#no shut
r3(config-if)#exit
r3(config)#int fa0/1
r3(config-if)#ip add 192.168.2.1 255.255.255.0
r3(config-if)#no shut
```

## Konfigurasi Routing Default
### Router R1
```
r1>enable
r1#config t
r1(config)#ip route 0.0.0.0 0.0.0.0 1.0.0.2
r1(config)#
```

### Router R3
```
r3>enable
r3#config t
r3(config)#ip route 0.0.0.0 0.0.0.0 2.0.0.1
r3(config)#
```

## Pengujian Koneksi
Sekarang, mari kita periksa koneksi dengan melakukan `ping` satu sama lain. Untuk memeriksa koneksi, lakukan `ping` antara *router*.

### Ping dari R1 ke R3
```
r1#ping 2.0.0.2
```

**Output:**
```
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 2.0.0.2, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 26/28/33 ms
```

### Ping dari R3 ke R1
```
r3#ping 1.0.0.1
```

**Output:**
```
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 1.0.0.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 25/28/32 ms
```

## Pembuatan VPN Tunnel antara R1 dan R3
### Membuat VPN Tunnel di Router R1
```
r1#config t
r1(config)#interface tunnel 10
r1(config-if)#ip address 172.16.1.1 255.255.0.0
r1(config-if)#tunnel source fa0/1
r1(config-if)#tunnel destination 2.0.0.2
r1(config-if)#no shut
```

### Membuat VPN Tunnel di Router R3
```plaintext
r3#config t
r3(config)#interface tunnel 100
r3(config-if)#ip address 172.16.1.2 255.255.0.0
r3(config-if)#tunnel source fa0/0
r3(config-if)#tunnel destination 1.0.0.1
r3(config-if)#no shut
```

### Pengujian VPN Tunnel
#### Ping dari R1 ke R3 melalui Tunnel
```
r1#ping 172.16.1.2
```
**Output:**
```
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 172.16.1.2, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 30/32/36 ms
r1#
```

#### Ping dari R3 ke R1 melalui Tunnel
```
r3#ping 172.16.1.1
```
**Output:**
```
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 172.16.1.1, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 33/45/83 ms
```

## Konfigurasi Routing untuk VPN Tunnel
Setelah *tunnel* VPN berhasil dibuat, lakukan konfigurasi *routing* untuk memastikan kedua *router* dapat saling berkomunikasi melalui *tunnel*.

### Routing pada Router R1
```
r1(config)#ip route 192.168.2.0 255.255.255.0 172.16.1.2
```

### Routing pada Router R3
```
r3(config)#ip route 192.168.1.0 255.255.255.0 172.16.1.1
```

## Uji Konfigurasi VPN Tunnel
Untuk memastikan bahwa *tunnel* VPN telah berhasil dibuat, lakukan pemeriksaan pada masing-masing *router*.

### Pemeriksaan pada Router R1
```
r1#show interfaces Tunnel 10
```
**Output:**
```
Tunnel10 is up, line protocol is up (connected)
Hardware is Tunnel
Internet address is 172.16.1.1/16
MTU 17916 bytes, BW 100 Kbit/sec, DLY 50000 usec,
reliability 255/255, txload 1/255, rxload 1/255
Encapsulation TUNNEL, loopback not set
Keepalive not set
Tunnel source 1.0.0.1 (FastEthernet0/1), destination 2.0.0.2
Tunnel protocol/transport GRE/IP
Key disabled, sequencing disabled
Checksumming of packets disabled
Tunnel TTL 255
Fast tunneling enabled
Tunnel transport MTU 1476 bytes
Tunnel transmit bandwidth 8000 (kbps)
Tunnel receive bandwidth 8000 (kbps)
Last input never, output never, output hang never
Last clearing of "show interface" counters never
Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 1
Queueing strategy: fifo
Output queue: 0/0 (size/max)
5 minute input rate 32 bits/sec, 0 packets/sec
5 minute output rate 32 bits/sec, 0 packets/sec
52 packets input, 3508 bytes, 0 no buffer
Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
0 input packets with dribble condition detected
52 packets output, 3424 bytes, 0 underruns
0 output errors, 0 collisions, 0 interface resets
0 unknown protocol drops
0 output buffer failures, 0 output buffers swapped out
```

### Pemeriksaan pada Router R3
```
r3#show interface Tunnel 100
```
**Output:**
```
Tunnel100 is up, line protocol is up (connected)
Hardware is Tunnel
Internet address is 172.16.1.2/16
MTU 17916 bytes, BW 100 Kbit/sec, DLY 50000 usec,
reliability 255/255, txload 1/255, rxload 1/255
Encapsulation TUNNEL, loopback not set
Keepalive not set
Tunnel source 2.0.0.2 (FastEthernet0/0), destination 1.0.0.1
Tunnel protocol/transport GRE/IP
Key disabled, sequencing disabled
Checksumming of packets disabled
Tunnel TTL 255
Fast tunneling enabled
Tunnel transport MTU 1476 bytes
Tunnel transmit bandwidth 8000 (kbps)
Tunnel receive bandwidth 8000 (kbps)
Last input never, output never, output hang never
Last clearing of "show interface" counters never
Input queue: 0/75/0/0 (size/max/drops/flushes); Total output drops: 1
Queueing strategy: fifo
Output queue: 0/0 (size/max)
5 minute input rate 32 bits/sec, 0 packets/sec
5 minute output rate 32 bits/sec, 0 packets/sec
52 packets input, 3424 bytes, 0 no buffer
Received 0 broadcasts, 0 runts, 0 giants, 0 throttles
0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored, 0 abort
0 input packets with dribble condition detected
53 packets output, 3536 bytes, 0 underruns
0 output errors, 0 collisions, 0 interface resets
0 unknown protocol drops
```

## Melacak Jalur VPN Tunnel
Untuk memeriksa jalur yang digunakan oleh VPN *tunnel*, gunakan perintah `tracert` dari salah satu komputer yang terhubung ke jaringan. Berikut adalah langkah-langkahnya:

### Mengonfigurasi IP pada PC
Pertama, pastikan PC terhubung ke jaringan dan memiliki alamat IP yang benar. Gunakan perintah berikut untuk memeriksa konfigurasi IP:

```
PC1>ipconfig
```

**Output:**
```
FastEthernet0 Connection:(default port)
Link-local IPv6 Address.........: FE80::2E0:8FFF:FE0B:AEB2
IP Address......................: 192.168.2.2
Subnet Mask.....................: 255.255.255.0
Default Gateway.................: 192.168.2.1
```

### Melakukan Ping ke R1
Setelah memastikan konfigurasi IP, lakukan `ping` ke *router* R1 untuk menguji konektivitas:

```
PC1>ping 192.168.1.2
```

**Output:**
```
Pinging 192.168.1.2 with 32 bytes of data:
Reply from 192.168.1.2: bytes=32 time=61ms TTL=126
Reply from 192.168.1.2: bytes=32 time=55ms TTL=126
Reply from 192.168.1.2: bytes=32 time=55ms TTL=126
Reply from 192.168.1.2: bytes=32 time=57ms TTL=126
Ping statistics for 192.168.1.2:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 55ms, Maximum = 61ms, Average = 57ms
```

### Melacak Jalur ke Router R1
Setelah ping berhasil, gunakan perintah `tracert` untuk melacak jalur ke *router* R1:

```
PC1>tracert 192.168.1.2
```

**Output:**
```
Tracing route to 192.168.1.2 over a maximum of 30 hops:
1 3 ms 0 ms 18 ms 192.168.2.1
2 35 ms 30 ms 30 ms 172.16.1.1
3 65 ms 59 ms 60 ms 192.168.1.2
Trace complete.
PC1>
```

## Unduh File Konfigurasi
Untuk memudahkan, file konfigurasi dapat diunduh [di sini](/assets/posts/vpn-configuration.pkt).

