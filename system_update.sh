#!/bin/bash
# Full system update script for Fedora 44 KDE

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user!"
    exit 1
fi

# System packages
echo "==> Updating system packages..."
sudo dnf upgrade --refresh -y

# Flatpak
echo "==> Updating Flatpak apps..."
flatpak update -y

# Firmware
echo "==> Checking firmware updates..."
sudo fwupdmgr refresh --force
sudo fwupdmgr update -y

# Oh My Zsh
# echo "==> Updating Oh My Zsh..."
# ~/.oh-my-zsh/tools/upgrade.sh

# Oh My Zsh custom plugins
# echo "==> Updating Oh My Zsh plugins..."
# ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
# for plugin_dir in "$ZSH_CUSTOM/plugins"/*/; do
#     if [ -d "$plugin_dir/.git" ]; then
#         echo "Updating $(basename "$plugin_dir")..."
#         git -C "$plugin_dir" pull
#     fi
# done

# Starship
echo "==> Updating Starship..."
curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes

# tmux plugins
echo "==> Updating tmux plugins..."
for plugin_dir in ~/.tmux/plugins/*/; do
    if [ -d "$plugin_dir/.git" ]; then
        echo "Updating $(basename "$plugin_dir")..."
        git -C "$plugin_dir" pull
    fi
done

# Joplin
wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

echo ""
echo "All done."
