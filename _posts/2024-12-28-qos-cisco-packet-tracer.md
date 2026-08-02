---
title: Konfigurasi QoS di Cisco Packet Tracer
description: Menjelaskan langkah-langkah konfigurasi Quality of Service (QoS) pada perangkat Cisco menggunakan Cisco Packet Tracer. Konfigurasi ini mencakup pengaturan router dan pengujian konektivitas.
categories: [Cisco Packet Tracer, Telco]
tags: [cisco packet tracer]
author: rical
last_modified_at: 2026-06-01
---

![QoS Configuration in Cisco Packet Tracer](/assets/img/posts/2024-12-28-qos-cisco-packet-tracer/qos-configuration.png)

## Topologi Jaringan
- **IP PC0**: 192.168.1.2, **Gateway**: 192.168.1.1
- **IP PC1**: 192.168.1.3, **Gateway**: 192.168.1.1
- **IP Server**: 172.16.0.254, **Gateway**: 172.16.0.1

## Konfigurasi Router R2
```plaintext
Router>en
Router#conf t
Router(config)#hostname rical
rical(config)#int g0/0
rical(config-if)#ip add 11.0.0.1 255.255.255.0
rical(config-if)#no sh
rical(config-if)#int g0/1
rical(config-if)#ip add 192.168.1.1 255.255.255.0
rical(config-if)#no sh
rical(config-if)#ex
rical(config)#router ospf 10
rical(config-router)#network 11.0.0.0 0.255.255.255 area 0
rical(config-router)#network 192.168.1.0 0.255.255.255 area 0
rical(config-router)#^Z
rical#write
Building configuration...
[OK]
```

## Konfigurasi Router R3
```plaintext
Router>en
Router#conf t
Router(config)#hostname pascal
pascal(config)#int g0/0
pascal(config-if)#ip add 11.0.0.2 255.255.255.0
pascal(config-if)#no sh
pascal(config-if)#int g0/1
pascal(config-if)#ip add 172.16.0.1 255.255.255.0
pascal(config-if)#no sh
pascal(config-if)#ex
pascal(config)#router ospf 10
pascal(config-router)#network 11.0.0.0 0.255.255.255 area 0
pascal(config-router)#network 172.16.0.0 0.0.0.255 area 0
pascal(config)#^Z
pascal#write
Building configuration...
[OK]
```

## Konfigurasi QoS di Router R2
```plaintext
rical#conf t
rical(config)#class-map voice
rical(config-cmap)#match protocol rtp
rical(config-cmap)#class
rical(config-cmap)#ex
rical(config)#class-map http
rical(config-cmap)#match protocol http
rical(config-cmap)#ex
rical(config)#class-map icmp
rical(config-cmap)#match protocol icmp
rical(config-cmap)#ex
rical(config)#policy-map mark
rical(config-pmap)#class voice
rical(config-pmap-c)#set ip dscp ef
rical(config-pmap-c)#priority 100
rical(config-pmap-c)#ex
rical(config-pmap)#ex
rical(config)#policy-map mark
rical(config-pmap)#class http
rical(config-pmap-c)#set ip dscp af31
rical(config-pmap-c)#bandwidth 50
rical(config-pmap-c)#ex
rical(config-pmap)#class icmp
rical(config-pmap-c)#set ip dscp af11
rical(config-pmap-c)#int g0/0
rical(config-if)#service-policy output mark
rical(config)#^Z
rical#write
Building configuration...
[OK]
```

## Konfigurasi QoS di Router R3
```plaintext
pascal>en
pascal#conf t
pascal(config)#class-map voice
pascal(config-cmap)#match ip dscp ef
pascal(config-cmap)#ex
pascal(config)#class-map http
pascal(config-cmap)#match ip dscp af31
pascal(config-cmap)#ex
pascal(config)#class-map icmp
pascal(config-cmap)#match ip dscp af11
pascal(config-cmap)#ex
pascal(config)#policy-map remark
pascal(config-pmap)#class voice
pascal(config-pmap-c)#set precedence critical
pascal(config-pmap-c)#ex
pascal(config-pmap)#class http
pascal(config-pmap-c)#set precedence 3
pascal(config-pmap-c)#class icmp
pascal(config-pmap-c)#set precedence routine
pascal(config-pmap-c)#int g0/0
pascal(config-if)#service-policy input remark
pascal(config-if)#^Z
pascal#write
Building configuration...
[OK]
```

## Pengujian Konektivitas
Setelah konfigurasi selesai, lakukan pengujian untuk memastikan bahwa QoS berfungsi dengan baik. Berikut adalah langkah-langkah pengujian:

1. **Akses Web Server**:
   - Pada PC1, buka web browser dan akses alamat IP server: `172.16.0.254`.

2. **Ping ke Server**:
   - Lakukan ping dari PC1 ke alamat IP server untuk memastikan konektivitas:
     ```plaintext
     ping 172.16.0.254
     ```
