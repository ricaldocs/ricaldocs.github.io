# Ricaldocs: Blog & IT Documentation

[![Ricaldocs](https://img.shields.io/badge/link-RicalDocs-red.svg)](https://docs.ricalnet.my.id)

An open source blog and documentation platform focused on **digital independence**, **digital privacy**, and **full control** over your data and devices.

Built with [Jekyll](https://jekyllrb.com/) and the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme (customized by [NichtsHsu](https://github.com/NichtsHsu)).

## Access & Usage

- **Site**: [https://docs.ricalnet.my.id/](https://docs.ricalnet.my.id/)
- **Basic guide**: [Chirpy Tutorial](https://chirpy.cotes.page/posts/getting-started/)

### Run with Podman

```bash
podman-compose up -d
```

## Customizations Made

| Feature                 | Description                                                                     |
| ----------------------- | ------------------------------------------------------------------------------- |
| **Liquid glass theme**  | Consistent dark/light mode, improved visual experience                          |
| **Bulletin**            | Announcement feature on the homepage via `_data/bulletin.yml`                   |
| **Last updated**        | Latest update information in the footer                                         |
| **Public IP detection** | Displays real-time public IP via [ipify API](https://api.ipify.org?format=json) |