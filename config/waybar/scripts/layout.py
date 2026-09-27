#!/usr/bin/env python3
"""Текущая раскладка для waybar (слушает события Hyprland)."""
import json, os, socket, subprocess

ICON = "\U000F030C"
NAMES = {"English": "EN", "Russian": "RU"}

def show(keymap):
    short = next((v for k, v in NAMES.items() if keymap.startswith(k)), keymap[:2].upper())
    print(json.dumps({"text": f"{ICON}  {short}", "tooltip": keymap}), flush=True)

devs = json.loads(subprocess.run(["hyprctl", "-j", "devices"], capture_output=True, text=True).stdout)
main = next((k for k in devs["keyboards"] if k.get("main")), devs["keyboards"][0])
show(main["active_keymap"])

path = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock"
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect(path)
buf = b""
while True:
    data = s.recv(4096)
    if not data:
        break
    buf += data
    *lines, buf = buf.split(b"\n")
    for line in lines:
        ev, _, arg = line.decode(errors="ignore").partition(">>")
        if ev == "activelayout":
            show(arg.split(",", 1)[1])
