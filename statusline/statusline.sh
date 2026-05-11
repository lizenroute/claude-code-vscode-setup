#!/bin/bash
# Claude Code statusline — Mac/Linux bash fallback (minimal mode)
# Used when Node.js is not available. For the full version, see statusline.js

input=$(cat)

epoch=$(date +%s 2>/dev/null || python3 -c "import time; print(int(time.time()))" 2>/dev/null || echo 0)
offset_sec=$(date +%z 2>/dev/null | awk '{h=substr($0,1,3); m=substr($0,4); print h*3600 + (h>=0?1:-1)*m*60}')
local_epoch=$((epoch + offset_sec))
hour=$(( (local_epoch / 3600) % 24 ))
min=$(( (local_epoch / 60) % 60 ))
time_str=$(printf "%02d:%02d" "$hour" "$min")

offset_h=$((offset_sec / 3600))
if [ "$offset_h" -ge 8 ]; then tz="TPE"
elif [ "$offset_h" -ge 7 ]; then tz="BKK"
else tz="GMT$([ $offset_h -ge 0 ] && echo "+")${offset_h}"; fi

used=$(echo "$input" | grep -o '"used_percentage":[0-9.]*' | head -1 | grep -o '[0-9.]*$')

out="$tz $time_str"
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  out="${out}  ctx ${used_int}%"
fi

printf "%s" "$out"
