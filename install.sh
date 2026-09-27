#!/usr/bin/env bash
# Установка райса HyprLandRice на Arch Linux.
#   ./install.sh               — поставить пакеты и конфиги
#   ./install.sh --no-packages — только конфиги (пакеты уже стоят)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.rice-backup/$(date +%Y%m%d-%H%M%S)"
INSTALL_PACKAGES=1

for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=0 ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) echo "Неизвестный параметр: $arg"; exit 1 ;;
  esac
done

info() { printf '\033[1;37m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }

# Пакеты из официальных репозиториев
PACMAN_PKGS=(
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk polkit-gnome
  awww waybar swaync rofi rofi-emoji kitty nautilus
  hyprshot grim slurp wl-clipboard
  pipewire pipewire-pulse wireplumber pavucontrol playerctl brightnessctl
  networkmanager python jq git
  zsh fzf
  otf-comicshanns-nerd ttf-nerd-fonts-symbols papirus-icon-theme
)
# Пакеты из AUR (ставятся через yay или paru, если они есть)
AUR_PKGS=(wlogout google-chrome)

# Какие папки ~/.config заменяются
CONFIG_DIRS=(hypr waybar rofi kitty gtk-3.0)

if ! command -v pacman >/dev/null; then
  echo "Этот скрипт рассчитан на Arch Linux (нужен pacman)."; exit 1
fi

# ---- 1. Пакеты ----
if (( INSTALL_PACKAGES )); then
  info "Ставлю пакеты из репозиториев"
  sudo pacman -S --needed "${PACMAN_PKGS[@]}"

  AUR_HELPER=""
  for h in yay paru; do command -v "$h" >/dev/null && { AUR_HELPER=$h; break; }; done
  if [[ -n $AUR_HELPER ]]; then
    info "Ставлю пакеты из AUR через $AUR_HELPER"
    "$AUR_HELPER" -S --needed "${AUR_PKGS[@]}"
  else
    warn "yay/paru не найден — поставьте вручную из AUR: ${AUR_PKGS[*]}"
  fi
fi

# ---- 2. Резервная копия старых конфигов ----
info "Сохраняю текущие конфиги в $BACKUP"
mkdir -p "$BACKUP"
for d in "${CONFIG_DIRS[@]}"; do
  [[ -e $CONFIG/$d ]] && cp -a "$CONFIG/$d" "$BACKUP/"
done
[[ -e $HOME/.zshrc ]] && cp -a "$HOME/.zshrc" "$BACKUP/"

# ---- 3. Конфиги ----
info "Копирую конфиги в $CONFIG"
mkdir -p "$CONFIG"
for d in "${CONFIG_DIRS[@]}"; do
  mkdir -p "$CONFIG/$d"
  cp -a "$REPO/config/$d/." "$CONFIG/$d/"
done
chmod +x "$CONFIG/hypr/scripts/"*.sh "$CONFIG/waybar/scripts/"*.py
cp "$REPO/home/.zshrc" "$HOME/.zshrc"

# ---- 4. Обои ----
info "Копирую обои в ~/Documents/wallpaper"
mkdir -p "$HOME/Documents/wallpaper" "$HOME/Pictures"
cp "$REPO/wallpapers/"* "$HOME/Documents/wallpaper/"

# ---- 5. Плагины zsh ----
info "Ставлю плагины zsh в ~/.zsh"
mkdir -p "$HOME/.zsh"
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
  if [[ -d $HOME/.zsh/$plugin ]]; then
    git -C "$HOME/.zsh/$plugin" pull --quiet || true
  else
    git clone --depth 1 "https://github.com/zsh-users/$plugin" "$HOME/.zsh/$plugin"
  fi
done

# ---- 6. zsh как оболочка по умолчанию ----
if [[ $(getent passwd "$USER" | cut -d: -f7) != */zsh ]]; then
  read -rp "Сделать zsh оболочкой по умолчанию? [Y/n] " ans
  [[ ${ans:-y} =~ ^[YyДд] ]] && chsh -s "$(command -v zsh)"
fi

echo
info "Готово! Старые конфиги лежат в $BACKUP"
warn "Проверьте мониторы в ~/.config/hypr/hyprland.lua (раздел MONITORS) — там прописаны DP-1 и HDMI-A-1."
warn "Список своих мониторов: hyprctl monitors"
info "Перезайдите в Hyprland, чтобы всё применилось."
