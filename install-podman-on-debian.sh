#!/bin/bash

# Podman installation script for Debian
# Executes commands in the specified order

echo "=========================================="
echo "Starting Podman installation on Debian"
echo "=========================================="

# 1. Update and upgrade system
echo "Step 1: Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

# 2. Install Podman
echo "Step 2: Installing Podman..."
sudo apt install -y podman

# 3. Install supporting packages
echo "Step 3: Installing supporting packages..."
sudo apt install -y uidmap slirp4netns dbus-user-session fuse-overlayfs

# 4. Enable linger for user
echo "Step 4: Enabling linger for user $USER..."
sudo loginctl enable-linger $USER

# 5. Check linger status
echo "Step 5: Checking linger status..."
loginctl show-user $USER | grep Linger

# 6. Install podman-compose
echo "Step 6: Installing podman-compose..."
sudo apt install -y podman-compose

# 7. Check podman-compose version
echo "Step 7: Checking podman-compose version..."
podman-compose --version

# 8. Test with hello-world
echo "Step 8: Running hello-world test..."
podman run hello-world

# 9. Edit registry configuration
echo "Step 9: Editing registry configuration..."
echo "Opening /etc/containers/registries.conf with nano"
echo "Add the following line:"
echo "unqualified-search-registries = [\"docker.io\", \"ghcr.io\"]"
echo ""
sudo nano /etc/containers/registries.conf

# 10. Enable podman socket
echo "Step 10: Enabling podman.socket..."
systemctl --user enable --now podman.socket

echo "=========================================="
echo "Podman installation completed successfully!"
echo "=========================================="