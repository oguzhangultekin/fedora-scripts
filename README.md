# fedora-scripts

## Usage

```bash
./system_initialize.sh   # once, post-install
./system_update.sh       # periodically
./system_cleanup.sh      # periodically
```

Personal scripts for Fedora 44 KDE setup and maintenance. All scripts block execution as root.

## Scripts

### `system_initialize.sh`

Post-install setup. Run once after a fresh Fedora install.

- Full system upgrade
- DNF tweaks: parallel downloads (10), fastest mirror, defaultyes
- Enables `dnf-automatic` for unattended updates
- Flathub setup (replaces Fedora remote)
- Firmware updates via `fwupdmgr`
- RPM Fusion (free + nonfree)
- Multimedia codecs (`ffmpeg`, `@multimedia`, `@sound-and-video`)
- Intel VA-API driver (`intel-media-driver`)
- Essentials: `vim`, `fastfetch`, `unzip`, `unrar`, `git`, `ansible`
- 1Password (repo + ptrace scope fix)
- Joplin (upstream install script)
- Fish shell (set as default)
- tmux + TPM + Catppuccin Mocha config
- Starship prompt (Fish integration)
- Prompts for reboot on completion

> Zsh/Oh My Zsh setup is commented out (superseded by Fish).

### `system_update.sh`

Full system update. Run periodically.

- `dnf upgrade --refresh`
- `flatpak update`
- Firmware via `fwupdmgr`
- Starship (latest via install script)
- tmux plugins (`git pull` per plugin dir)
- Joplin (upstream install/update script)

> Zsh/Oh My Zsh update steps are commented out.

### `system_cleanup.sh`

Disk and cache cleanup. Safe to run anytime.

- Removes old kernels (keeps latest 2)
- `dnf clean all`
- `dnf autoremove`
- Flatpak unused runtime removal
- Clears `~/.cache`
- Vacuum systemd journal (7-day retention)
- Clears `/tmp`
- Runs `dnf upgrade --refresh` at the end
