---
title: Mosquitto on Debian-based Linux
description: Panduan instalasi, konfigurasi, dan implementasi broker MQTT Mosquitto pada sistem operasi berbasis Debian, dilengkapi dengan contoh integrasi platform simulasi Wokwi untuk pengembangan solusi Internet of Things (IoT).
categories: [Digital Independence, Telecommunications]
tags: [internet of things, mqtt]
author: rical
last_modified_at: 2026-06-01
---

## Pendahuluan
Mosquitto merupakan implementasi broker MQTT (Message Queuing Telemetry Transport) sumber-terbuka yang dirancang ringan. Protokol MQTT secara khusus dikembangkan untuk mendukung komunikasi mesin-ke-mesin (M2M) dan implementasi Internet of Things (IoT).

## Proses Instalasi
Eksekusi perintah berikut melalui terminal untuk melakukan instalasi paket Mosquitto:
```bash
sudo apt update && sudo apt install -y mosquitto mosquitto-clients
```

## Konfigurasi Server Mosquitto
Setelah proses instalasi berhasil, server Mosquitto dapat dijalankan dengan perintah berikut:
```bash
mosquitto_sub -h test.mosquitto.org -t ricalnet
```

Perintah di atas akan melakukan proses subskripsi ke topik `ricalnet` pada broker Mosquitto yang terhosting di `test.mosquitto.org`. Server akan secara kontinu menunggu dan menampilkan pesan yang diterima pada topik tersebut.

## Publikasi Pesan
Untuk mempublikasikan pesan ke topik yang sama, gunakan sintaks berikut:
```bash
mosquitto_pub -h test.mosquitto.org -t ricalnet -m "Hello Friend"
```

Perintah tersebut akan mengirimkan payload "Hello Friend" ke topik `ricalnet` pada broker yang ditentukan.

## Output yang Diharapkan
Setelah menjalankan proses subskripsi dan publikasi, output terminal akan menampilkan hasil sebagai berikut:
```
┌──(titor㉿system)-[~]
└─$ mosquitto_sub -h test.mosquitto.org -t ricalnet

Hello Friend
Hello Friend
Hello Friend
```

Output mengkonfirmasi bahwa pesan "Hello Friend" berhasil terkirim dan diterima beberapa kali, menunjukkan keberhasilan koneksi dan komunikasi MQTT pada topik `ricalnet`.

## Integrasi dengan Platform Wokwi
[Wokwi](https://wokwi.com) merupakan platform simulasi perangkat keras yang memungkinkan pengembangan dan pengujian proyek mikrokontroler secara online. Platform ini menyediakan kemampuan simulasi komponen elektronik dan integrasi pustaka perangkat lunak untuk mendukung pengembangan solusi IoT.

![Hasil Pengujian](assets/img/posts/2025-04-28-mosquitto-on-kali-linux/wokwi-mqtt-test.png)
*Gambar 1. Hasil Pengujian Integrasi MQTT pada Platform Wokwi*

### Implementasi Kode Sumber
Berikut merupakan contoh implementasi kode untuk menghubungkan perangkat ESP32 ke broker MQTT menggunakan pustaka `WiFi` dan `PubSubClient`:

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// Konfigurasi jaringan dan MQTT
const char* ssid = "Wokwi-GUEST";
const char* password = "";
const char* mqtt_server = "test.mosquitto.org";
const char* mqtt_topic = "ricalnet";

WiFiClient espClient;
PubSubClient client(espClient);

const int MSG_BUFFER_SIZE = 50;
char msg[MSG_BUFFER_SIZE];
int sequence_number = 1;

void setup() {
    Serial.begin(115200);
    WiFi.begin(ssid, password);
    
    // Inisialisasi koneksi WiFi
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Menghubungkan ke WiFi...");
    }
    Serial.println("Terhubung ke WiFi");

    client.setServer(mqtt_server, 1883);
}

void loop() {
    if (!client.connected()) {
        // Implementasi logika reconnection MQTT
        // Contoh: client.connect("clientID");
    }
    client.loop();

    // Format dan publikasi pesan
    snprintf(msg, MSG_BUFFER_SIZE, "Nomor Absen #%1d", sequence_number);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish(mqtt_topic, msg);
    
    delay(2000);
}
```

### Spesifikasi Konfigurasi Perangkat
Berikut representasi konfigurasi perangkat dalam format JSON untuk simulasi Wokwi:
```json
{
  "version": 1,
  "author": "Anonymous maker",
  "editor": "wokwi",
  "parts": [
    {
      "id": "esp",
      "type": "board-esp32-devkit-c-v4"
    }
  ],
  "connections": [
    ["esp:TX", "$serialMonitor:RX", ""],
    ["esp:RX", "$serialMonitor:TX", ""]
  ]
}
```

### Manajemen Pustaka
Wokwi mendukung berbagai pustaka pengembangan melalui sistem manajemen pustaka. Berikut daftar pustaka yang umum digunakan:
```
# Daftar Pustaka Wokwi
# Dokumentasi lengkap: https://docs.wokwi.com/guides/libraries

PubSubClient
DHT sensor library for ESPx
WiFi
```