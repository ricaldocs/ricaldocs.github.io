---
title: Implementasi OpenTelemetry pada Aplikasi Go
description: Pelajari cara mengimplementasikan OpenTelemetry pada aplikasi Go untuk tracing, metrics, dan logging.
categories: [Cloud & On-Premise]
tags: [opentelemetry, golang]
author: rical
last_modified_at: 2026-06-01
---

## Prasyarat

- Go versi 1.21 atau lebih baru
- Pemahaman dasar pemrograman Go dan konsep HTTP server
- Terminal/command line untuk menjalankan perintah

## Struktur Proyek

```
dice/
├── main.go
├── rolldice.go
├── otel.go
└── go.mod
```

## Langkah 1: Inisialisasi Aplikasi Dasar

### 1.1 Setup Environment

```bash
sudo apt install -y golang-go
```

Buat direktori baru dan inisialisasi modul Go:
```bash
mkdir dice
cd dice
go mod init dice
```

### 1.2 Implementasi HTTP Server Dasar

**File: `main.go` (versi awal)**

```go
package main

import (
    "context"
    "log"
    "net"
    "net/http"
    "os"
    "os/signal"
    "time"
)

func main() {
    if err := run(); err != nil {
        log.Fatalln(err)
    }
}

func run() (err error) {
    // Handle SIGINT (CTRL+C) secara graceful
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
    defer stop()

    // Inisialisasi HTTP server
    srv := &http.Server{
        Addr:         ":8080",
        BaseContext:  func(net.Listener) context.Context { return ctx },
        ReadTimeout:  time.Second,
        WriteTimeout: 10 * time.Second,
        Handler:      newHTTPHandler(),
    }
    
    srvErr := make(chan error, 1)
    go func() {
        log.Println("HTTP server berjalan...")
        srvErr <- srv.ListenAndServe()
    }()

    // Tunggu hingga ada interupsi
    select {
    case err = <-srvErr:
        // Error saat memulai HTTP server
        return err
    case <-ctx.Done():
        // Terima sinyal CTRL+C pertama
        stop()
    }

    // Shutdown server
    err = srv.Shutdown(context.Background())
    return err
}

func newHTTPHandler() http.Handler {
    mux := http.NewServeMux()
    mux.HandleFunc("/rolldice/", rolldice)
    mux.HandleFunc("/rolldice/{player}", rolldice)
    return mux
}
```

**File: `rolldice.go` (versi awal)**

```go
package main

import (
    "io"
    "log"
    "math/rand"
    "net/http"
    "strconv"
)

func rolldice(w http.ResponseWriter, r *http.Request) {
    roll := 1 + rand.Intn(6)

    var msg string
    if player := r.PathValue("player"); player != "" {
        msg = player + " sedang melempar dadu"
    } else {
        msg = "Pemain anonim sedang melempar dadu"
    }
    
    log.Printf("%s, hasil: %d", msg, roll)
    resp := strconv.Itoa(roll) + "\n"
    
    if _, err := io.WriteString(w, resp); err != nil {
        log.Printf("Write gagal: %v", err)
    }
}
```

### 1.3 Verifikasi Aplikasi Dasar

Build dan jalankan aplikasi:
```bash
go run .
```

Uji endpoint di browser atau dengan curl
- `http://localhost:8080/rolldice`
- `http://localhost:8080/rolldice/Alice`

Output:
```
2026/02/11 16:10:53 HTTP server berjalan...
2026/02/11 16:11:31 Pemain anonim sedang melempar dadu, hasil: 2
2026/02/11 16:11:54 Alice sedang melempar dadu, hasil: 2
```

## Langkah 2: Implementasi OpenTelemetry SDK

### 2.1 Setup Otel.go

**File: `otel.go`**

```go
package main

import (
    "context"
    "errors"
    "time"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/stdout/stdoutlog"
    "go.opentelemetry.io/otel/exporters/stdout/stdoutmetric"
    "go.opentelemetry.io/otel/exporters/stdout/stdouttrace"
    "go.opentelemetry.io/otel/log/global"
    "go.opentelemetry.io/otel/propagation"
    "go.opentelemetry.io/otel/sdk/log"
    "go.opentelemetry.io/otel/sdk/metric"
    "go.opentelemetry.io/otel/sdk/trace"
)

// setupOTelSDK melakukan bootstrap pipeline OpenTelemetry
// Fungsi ini mengembalikan shutdown function untuk cleanup
func setupOTelSDK(ctx context.Context) (func(context.Context) error, error) {
    var shutdownFuncs []func(context.Context) error
    var err error

    // shutdown function untuk cleanup
    shutdown := func(ctx context.Context) error {
        var err error
        for _, fn := range shutdownFuncs {
            err = errors.Join(err, fn(ctx))
        }
        shutdownFuncs = nil
        return err
    }

    handleErr := func(inErr error) {
        err = errors.Join(inErr, shutdown(ctx))
    }

    // Setup propagator
    prop := newPropagator()
    otel.SetTextMapPropagator(prop)

    // Setup trace provider
    tracerProvider, err := newTracerProvider()
    if err != nil {
        handleErr(err)
        return shutdown, err
    }
    shutdownFuncs = append(shutdownFuncs, tracerProvider.Shutdown)
    otel.SetTracerProvider(tracerProvider)

    // Setup meter provider
    meterProvider, err := newMeterProvider()
    if err != nil {
        handleErr(err)
        return shutdown, err
    }
    shutdownFuncs = append(shutdownFuncs, meterProvider.Shutdown)
    otel.SetMeterProvider(meterProvider)

    // Setup logger provider
    loggerProvider, err := newLoggerProvider()
    if err != nil {
        handleErr(err)
        return shutdown, err
    }
    shutdownFuncs = append(shutdownFuncs, loggerProvider.Shutdown)
    global.SetLoggerProvider(loggerProvider)

    return shutdown, err
}

func newPropagator() propagation.TextMapPropagator {
    return propagation.NewCompositeTextMapPropagator(
        propagation.TraceContext{},
        propagation.Baggage{},
    )
}

func newTracerProvider() (*trace.TracerProvider, error) {
    traceExporter, err := stdouttrace.New(stdouttrace.WithPrettyPrint())
    if err != nil {
        return nil, err
    }

    tracerProvider := trace.NewTracerProvider(
        trace.WithBatcher(traceExporter,
            trace.WithBatchTimeout(time.Second)),
    )
    return tracerProvider, nil
}

func newMeterProvider() (*metric.MeterProvider, error) {
    metricExporter, err := stdoutmetric.New(stdoutmetric.WithPrettyPrint())
    if err != nil {
        return nil, err
    }

    meterProvider := metric.NewMeterProvider(
        metric.WithReader(metric.NewPeriodicReader(metricExporter,
            metric.WithInterval(3*time.Second))),
    )
    return meterProvider, nil
}

func newLoggerProvider() (*log.LoggerProvider, error) {
    logExporter, err := stdoutlog.New(stdoutlog.WithPrettyPrint())
    if err != nil {
        return nil, err
    }

    loggerProvider := log.NewLoggerProvider(
        log.WithProcessor(log.NewBatchProcessor(logExporter)),
    )
    return loggerProvider, nil
}
```

## Langkah 3: Instrumentasi HTTP Server

### 3.1 Update Main.go dengan Instrumentasi

**File: `main.go` (versi terinstrumentasi)**

```go
package main

import (
    "context"
    "errors"
    "log"
    "net"
    "net/http"
    "os"
    "os/signal"
    "time"

    "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

func main() {
    if err := run(); err != nil {
        log.Fatalln(err)
    }
}

func run() error {
    // Handle SIGINT (CTRL+C) secara graceful
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
    defer stop()

    // Setup OpenTelemetry
    otelShutdown, err := setupOTelSDK(ctx)
    if err != nil {
        return err
    }
    
    // Handle shutdown dengan benar
    defer func() {
        err = errors.Join(err, otelShutdown(context.Background()))
    }()

    // Start HTTP server
    srv := &http.Server{
        Addr:         ":8080",
        BaseContext:  func(net.Listener) context.Context { return ctx },
        ReadTimeout:  time.Second,
        WriteTimeout: 10 * time.Second,
        Handler:      newHTTPHandler(),
    }
    
    srvErr := make(chan error, 1)
    go func() {
        srvErr <- srv.ListenAndServe()
    }()

    // Tunggu hingga ada interupsi
    select {
    case err = <-srvErr:
        return err
    case <-ctx.Done():
        stop()
    }

    err = srv.Shutdown(context.Background())
    return err
}

func newHTTPHandler() http.Handler {
    mux := http.NewServeMux()
    mux.Handle("/rolldice", http.HandlerFunc(rolldice))
    mux.Handle("/rolldice/{player}", http.HandlerFunc(rolldice))
    
    // Tambahkan instrumentasi HTTP untuk seluruh server
    handler := otelhttp.NewHandler(mux, "/")
    return handler
}
```

## Langkah 4: Instrumentasi Kustom untuk Business Logic

### 4.1 Update Rolldice.go dengan Instrumentasi

**File: `rolldice.go` (versi terinstrumentasi)**

```go
package main

import (
    "io"
    "math/rand"
    "net/http"
    "strconv"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/metric"
    "go.opentelemetry.io/contrib/bridges/otelslog"
)

const name = "go.opentelemetry.io/contrib/examples/dice"

var (
    tracer  = otel.Tracer(name)
    meter   = otel.Meter(name)
    logger  = otelslog.NewLogger(name)
    rollCnt metric.Int64Counter
)

func init() {
    var err error
    rollCnt, err = meter.Int64Counter("dice.rolls",
        metric.WithDescription("Jumlah lemparan dadu berdasarkan nilai"),
        metric.WithUnit("{roll}"))
    if err != nil {
        panic(err)
    }
}

func rolldice(w http.ResponseWriter, r *http.Request) {
    // Buat span untuk tracing
    ctx, span := tracer.Start(r.Context(), "roll")
    defer span.End()

    roll := 1 + rand.Intn(6)

    // Logging terinstrumentasi
    var msg string
    if player := r.PathValue("player"); player != "" {
        msg = player + " sedang melempar dadu"
    } else {
        msg = "Pemain anonim sedang melempar dadu"
    }
    
    logger.InfoContext(ctx, msg, "result", roll)

    // Tambahkan attribute ke span
    rollValueAttr := attribute.Int("roll.value", roll)
    span.SetAttributes(rollValueAttr)
    
    // Rekam metric
    rollCnt.Add(ctx, 1, metric.WithAttributes(rollValueAttr))

    // Kirim response
    resp := strconv.Itoa(roll) + "\n"
    if _, err := io.WriteString(w, resp); err != nil {
        logger.ErrorContext(ctx, "Write gagal", "error", err)
    }
}
```

## Langkah 5: Menjalankan Aplikasi Terinstrumentasi

### 5.1 Setup Dependencies dan Environment

```bash
# Download dependencies
go mod tidy

# Set environment variables untuk resource attributes
export OTEL_RESOURCE_ATTRIBUTES="service.name=dice,service.version=0.1.0"

# Jalankan aplikasi
go run .
```

### 5.2 Testing Endpoint

Test endpoint dengan curl:
```bash
curl http://localhost:8080/rolldice
curl http://localhost:8080/rolldice/Alice
```

Atau buka di browser:
`http://localhost:8080/rolldice/Alice`

### 5.3 Output Telemetri

Saat aplikasi berjalan, Anda akan melihat output telemetri di console:

Contoh trace output:
```
{
  "Name": "roll",
  "SpanContext": {
    "TraceID": "7b2b8b3c8b7b2b8b3c8b7b2b8b3c8b7b2b",
    "SpanID": "3c8b7b2b8b3c8b7b",
    "TraceFlags": "01",
    "TraceState": "",
    "Remote": false
  },
  "ParentSpanID": "2b8b3c8b7b2b8b3c",
  "Attributes": [
    {
      "Key": "roll.value",
      "Value": 4
    }
  ]
}
```

Contoh metric output:
```
{
  "name": "dice.rolls",
  "unit": "{roll}",
  "data": {
    "dataPoints": [
      {
        "attributes": [
          {
            "Key": "roll.value",
            "Value": 4
          }
        ],
        "value": 1
      }
    ]
  }
}
```

## Referensi

1. [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
2. [Go OpenTelemetry SDK](https://github.com/open-telemetry/opentelemetry-go)
4. [Instrumentation Libraries](https://github.com/open-telemetry/opentelemetry-go-contrib)