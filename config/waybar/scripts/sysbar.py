#!/usr/bin/env python3
"""Полоска загрузки для waybar: sysbar.py cpu|mem|gpu|temp|disk"""
import json, os, sys, time, glob, subprocess

KIND = sys.argv[1] if len(sys.argv) > 1 else "cpu"
SEGMENTS = 8
DIM = "#454545"
CONF = {  # подпись, цвет, период обновления (сек)
    "cpu":  ("CPU", "#8fa8c8", 2),
    "mem":  ("RAM", "#9ab89a", 3),
    "gpu":  ("GPU", "#8ab8b8", 2),
    "temp": ("TMP", "#d8b88a", 3),
    "disk": ("SSD", "#b8a0c8", 60),
}
label, color, period = CONF[KIND]

def cpu_times():
    with open("/proc/stat") as f:
        v = list(map(int, f.readline().split()[1:]))
    idle = v[3] + v[4]
    return idle, sum(v)

def mem():
    m = {}
    with open("/proc/meminfo") as f:
        for line in f:
            k, val = line.split(":")
            m[k] = int(val.split()[0])
    used = m["MemTotal"] - m["MemAvailable"]
    return used / m["MemTotal"] * 100, f"ОЗУ: {used/1048576:.1f} / {m['MemTotal']/1048576:.1f} ГБ"

def temp_path():
    for d in glob.glob("/sys/devices/platform/coretemp.0/hwmon/hwmon*"):
        return os.path.join(d, "temp1_input")
    for d in glob.glob("/sys/class/hwmon/hwmon*"):
        p = os.path.join(d, "temp1_input")
        if os.path.exists(p):
            return p

def disk():
    s = os.statvfs("/")
    total = s.f_blocks * s.f_frsize
    used = total - s.f_bavail * s.f_frsize
    return used / total * 100, f"Диск /: {used/1e9:.0f} / {total/1e9:.0f} ГБ"

def bar(pct, shown):
    filled = round(min(max(pct, 0), 100) / 100 * SEGMENTS)
    c = color
    if pct >= 90 or (KIND == "temp" and pct >= 85):
        c = "#d08a8a"
    body = f"<span color='{c}'>{'━' * filled}</span><span color='{DIM}'>{'━' * (SEGMENTS - filled)}</span>"
    return f"<span color='#bdbdbd' weight='bold'>{label}</span>  {body}  <span color='#e8e8e8'>{shown}</span>"

if KIND == "gpu":
    # nvidia-smi сам отдаёт строку раз в period секунд
    q = "utilization.gpu,memory.used,memory.total,temperature.gpu,name"
    proc = subprocess.Popen(["nvidia-smi", f"--query-gpu={q}", "--format=csv,noheader,nounits",
                             "-l", str(period)], stdout=subprocess.PIPE, text=True)
    for line in proc.stdout:
        util, used, total, temp, name = [x.strip() for x in line.split(",", 4)]
        pct = float(util)
        tip = f"{name}\nЗагрузка: {pct:.0f}%\nВидеопамять: {int(used)/1024:.1f} / {int(total)/1024:.1f} ГБ\nТемпература: {temp}°C"
        print(json.dumps({"text": bar(pct, f"{pct:3.0f}%"), "tooltip": tip}), flush=True)
    sys.exit(1)

prev = cpu_times()
tpath = temp_path()
first = True
while True:
    if not first:
        time.sleep(period)
    elif KIND == "cpu":
        time.sleep(0.5)
    first = False
    if KIND == "cpu":
        cur = cpu_times()
        di, dt = cur[0] - prev[0], cur[1] - prev[1]
        prev = cur
        pct = 100 * (1 - di / dt) if dt else 0
        text, tip = bar(pct, f"{pct:3.0f}%"), f"CPU: {pct:.0f}%"
    elif KIND == "mem":
        pct, tip = mem()
        text = bar(pct, f"{pct:3.0f}%")
    elif KIND == "temp":
        t = int(open(tpath).read()) / 1000 if tpath else 0
        pct, tip = t, f"CPU: {t:.0f}°C"
        text = bar(pct, f"{t:3.0f}°")
    else:
        pct, tip = disk()
        text = bar(pct, f"{pct:3.0f}%")
    print(json.dumps({"text": text, "tooltip": tip}), flush=True)
