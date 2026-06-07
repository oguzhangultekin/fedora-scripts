#!/bin/bash
# Post-install setup for Fedora 44 KDE

# Prevent running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user!"
    exit 1
fi

# System upgrade
sudo dnf upgrade -y

# DNF tweaks (only add if not already present)
grep -q "max_parallel_downloads" /etc/dnf/dnf.conf || echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
grep -q "fastestmirror"          /etc/dnf/dnf.conf || echo "fastestmirror=True"        | sudo tee -a /etc/dnf/dnf.conf > /dev/null
grep -q "defaultyes"             /etc/dnf/dnf.conf || echo "defaultyes=True"           | sudo tee -a /etc/dnf/dnf.conf > /dev/null

# Automatic updates
sudo dnf install -y dnf-automatic
sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

# Flathub
sudo dnf install -y flatpak
flatpak remote-delete fedora --force 2>/dev/null || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak repair
flatpak update -y

# Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates || true
sudo fwupdmgr update -y || true

# RPM Fusion
sudo dnf install -y \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf update -y @core

# Multimedia codecs
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf update -y @multimedia --setopt="install_weak_deps=False"
sudo dnf update -y @sound-and-video

# Intel VA-API driver
sudo dnf install -y intel-media-driver libva-utils

# Essentials
sudo dnf install -y vim fastfetch unzip unrar git ansible

# 1Password
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install -y 1password

# 1Password attachment fix
# https://www.1password.community/discussions/1password/1pw-linux-attach-file--choose-icon-dont-work-/128221
echo "kernel.yama.ptrace_scope=1" | sudo tee -a /etc/sysctl.d/99-ptrace-scope.conf
sudo sysctl --system

# Joplin
# flatpak install -y flathub net.cozic.joplin_desktop
wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash

# Zsh + Oh My Zsh
# sudo dnf install -y zsh
# curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | RUNZSH=no sh -s -- --unattended
# chsh -s "$(which zsh)"

# Oh My Zsh Plugins
# ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# git clone https://github.com/zsh-users/zsh-autosuggestions             "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git     "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
# git clone https://github.com/marlonrichert/zsh-autocomplete.git        "$ZSH_CUSTOM/plugins/zsh-autocomplete"
# git clone https://github.com/fdellwing/zsh-bat.git                     "$ZSH_CUSTOM/plugins/zsh-bat"
# git clone https://github.com/zsh-users/zsh-history-substring-search    "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
# sed -i 's/^plugins=(.*)/plugins=(git aliases zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete zsh-bat zsh-history-substring-search)/' "$HOME/.zshrc"
# sed -i 's/^ZSH_THEME=".*/ZSH_THEME=""/' "$HOME/.zshrc"

# Fish
sudo dnf install -y fish
chsh -s "$(which fish)"

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cat > ~/.tmux.conf << 'EOF'
set -g mouse on

bind-key h select-pane -L
bind-key j select-pane -D
bind-key k select-pane -U
bind-key l select-pane -R

set-option -g status-position top

set -g base-index 1

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'catppuccin/tmux'

set -g @catppuccin_lavour 'mocha'
set -g @catppuccin_window_status_style 'rounded'

run '~/.tmux/plugins/tpm/tpm'
EOF

# Starship
curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes
#echo 'eval "$(starship init zsh)"' >> ~/.zshrc
echo 'starship init fish | source' >> ~/.config/fish/config.fish

echo ""
echo "All done. Please reboot."

read -p "Reboot now? (y/n): " choice
[[ "$choice" == [yY] ]] && sudo reboot
