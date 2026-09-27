#!/usr/bin/env bash
# Переливающаяся бело-серая рамка активного окна (вращение градиента)
STEP=3        # на сколько градусов поворачивать за шаг
DELAY=0.04    # пауза между шагами, сек

# не запускать второй экземпляр
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/gradient-border.lock"
flock -n 9 || exit 0

angle=0
while hyprctl eval "hl.config({ general = { col = { active_border = { colors = {
    \"rgba(ffffffee)\", \"rgba(9a9a9aee)\", \"rgba(4a4a4aee)\", \"rgba(c8c8c8ee)\", \"rgba(ffffffee)\"
  }, angle = $angle } } } })" >/dev/null 2>&1; do
  angle=$(( (angle + STEP) % 360 ))
  sleep "$DELAY"
done
