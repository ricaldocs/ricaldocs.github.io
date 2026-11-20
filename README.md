# Ricaldocs: Uncensored Tech Library

[![Ricaldocs](https://img.shields.io/badge/link-Ricaldocs-red.svg)](https://docs.ricalnet.my.id)

This is an open-source blog and documentation platform focused on digital independence, digital privacy, and giving you full control over your data and devices.

It’s built with [Jekyll](https://jekyllrb.com/) and the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme.

## Access & Usage

- **Site**: [https://docs.ricalnet.my.id/](https://docs.ricalnet.my.id/)
- **Basic guide**: [Chirpy Tutorial](https://chirpy.cotes.page/posts/getting-started/)

## Getting Started

### Installation (Local Development)

#### 1. Install Dependencies

```bash
sudo apt-get install -y ruby-full build-essential
```

#### 2. Configure Ruby Gems Environment

Add the following configuration to `~/.zshrc` (or `~/.bashrc` if you use bash):

```bash
echo '# Install Ruby Gems to ~/gems' >> ~/.zshrc
echo 'export GEM_HOME="$HOME/gems"' >> ~/.zshrc
echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### 3. Install Jekyll & Bundler

```bash
gem install jekyll bundler
```

#### 4. Clone the Repository

```bash
git clone https://git.ricalnet.my.id/rical/ricaldocs.git
cd ricaldocs
```

#### 5. Install Dependencies & Run the Server

```bash
bundle install
bundle exec jekyll s
```

Open your browser and go to `http://localhost:4000`.