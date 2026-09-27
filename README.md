# HyprLandRice

Серо-белый райс для Hyprland на Arch Linux: толстые обводки, жёсткие тени, шрифт Comic Shanns, переливающаяся рамка активного окна.

| Что | Чем |
|---|---|
| Композитор | Hyprland (конфиг на Lua, проверено на 0.56) |
| Панель | waybar + свои скрипты (раскладка, загрузка системы) |
| Меню запуска | rofi (тема `cartoon`) |
| Уведомления | swaync |
| Обои | awww |
| Терминал | kitty (прозрачность 0.8) |
| Оболочка | zsh + autosuggestions, syntax-highlighting, fzf |
| Файлы | nautilus |
| Скриншоты | hyprshot |
| Выход | wlogout |

## Установка

```bash
git clone https://github.com/maxim65o/HyprLandRice.git
cd HyprLandRice
./install.sh
```

Скрипт:
1. ставит нужные пакеты (`pacman`, а `wlogout` и `google-chrome` — через `yay`/`paru` из AUR);
2. сохраняет ваши текущие конфиги в `~/.rice-backup/<дата>/`;
3. копирует конфиги в `~/.config` и `.zshrc` в домашнюю папку;
4. кладёт обои в `~/Documents/wallpaper/`;
5. ставит плагины zsh в `~/.zsh/`;
6. предлагает сделать zsh оболочкой по умолчанию.

Если пакеты уже стоят — `./install.sh --no-packages`.

После установки перезайдите в Hyprland.

### Обязательно поправьте мониторы

В `~/.config/hypr/hyprland.lua` (раздел **MONITORS**) прописаны мои мониторы: `DP-1` 1920×1080@165 и `HDMI-A-1` 1920×1080@60. Посмотрите свои командой `hyprctl monitors` и замените.

## Горячие клавиши

`SUPER` — клавиша Windows.

| Клавиши | Действие |
|---|---|
| `SUPER + Enter` | Терминал (kitty) |
| `SUPER + R` | Меню приложений (rofi) |
| `SUPER + E` | Файловый менеджер |
| `SUPER + B` | Браузер (Chrome) |
| `SUPER + Q` | Закрыть окно |
| `SUPER + F` | Плавающее окно вкл/выкл |
| `SUPER + S` | Скриншот области → `~/Pictures` |
| `SUPER + M` | Выйти из Hyprland |
| `SUPER + 1…0` | Рабочий стол 1…10 |
| `SUPER + SHIFT + 1…0` | Перенести окно на рабочий стол |
| `SUPER + SHIFT + S` | Убрать окно в скрытый стол |
| `SUPER + колесо` | Листать рабочие столы |
| `SUPER + ЛКМ / ПКМ` | Двигать / менять размер окна |
| `Alt + Shift` | Сменить раскладку (EN/RU) |

## Структура

```
config/
  hypr/        hyprland.lua, scripts/gradient-border.sh (анимация рамки)
  waybar/      config.jsonc, style.css, scripts/ (раскладка, sysbar)
  rofi/        config.rasi, cartoon.rasi
  kitty/       kitty.conf
  gtk-3.0/     тёмная тема GTK
home/.zshrc    промпт, история, плагины
wallpapers/    обои
install.sh     установщик
```

## Примечания

- В конфиге есть строки для голосового ассистента «Джарвис» (`~/jarvis/jarvis.sh`, `SUPER + J`). Он в репозиторий не входит — без него эти строки просто ничего не делают, их можно удалить.
- Скрипт `waybar/scripts/sysbar.py` умеет показывать CPU/RAM/GPU/температуру/диск (`sysbar.py cpu|mem|gpu|temp|disk`); GPU — только NVIDIA (`nvidia-smi`).
