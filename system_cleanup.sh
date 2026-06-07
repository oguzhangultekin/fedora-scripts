#!/bin/bash
# System Cleanup Script for Fedora

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user!"
    exit 1
fi

remove_old_kernels() {
    local kernels_to_remove
    kernels_to_remove=$(dnf repoquery --installonly --latest-limit=-2 -q 2>/dev/null)
    if [ -z "$kernels_to_remove" ]; then
        echo "Nothing to remove."
        return 0
    fi
    echo "$kernels_to_remove"
    sudo dnf remove -y $kernels_to_remove
}

echo "==> Removing old kernels..."
remove_old_kernels

echo "==> Clearing DNF cache..."
sudo dnf clean all

echo "==> Removing orphaned packages..."
sudo dnf autoremove -y

echo "==> Removing unused flatpak packages..."
flatpak uninstall --unused

echo "==> Clearing user cache..."
if [ -d "$HOME/.cache" ]; then
    find "$HOME/.cache" -type f -delete
    find "$HOME/.cache" -type d -empty -delete
fi

echo "==> Clearing systemd journal logs..."
sudo journalctl --vacuum-time=7d

echo "==> Clearing temporary files..."
sudo rm -rf /tmp/*

echo "==> Updating system packages..."
sudo dnf upgrade --refresh -y
