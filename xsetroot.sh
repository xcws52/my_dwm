#!/bin/bash

print_alsa(){
  headphone_pluged=$(pacmd list-sinks | grep headphones | grep -oP "(?<=available: )\w+")
  is_muted=$(pacmd list-sinks | grep muted | grep -oP "(?<=muted: )\w+")
  if [ $headphone_pluged == "unknown" ]
  then
    if [ $is_muted == "no" ]
    then
      echo "H Vol:$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")%"
    else
      echo "H Vol:$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")%(M)"
    fi
  else
    if [ $is_muted == "no" ]
    then
      echo "I Vol:$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")%"
    else
      echo "I Vol:$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")%(M)"
    fi
  fi
}

print_date(){
  echo $(date "+%Y-%m-%d %T")
}

print_wifi(){
  echo $(nmcli connection show | grep wlan0 | awk '{print $1}')
}

print_mem(){
  mem_available=$(($(grep -m 1 "MemAvailable:" /proc/meminfo | awk '{print $2}') / 1024))
  mem_total=$(($(grep -m 1 "MemTotal:" /proc/meminfo | awk '{print $2}') / 1024))
  mem_used=$((${mem_total}-${mem_available}))
  echo "Mem:${mem_used}M/${mem_total}M"
}

print_network(){
	logfile=/dev/shm/netlog
	[ -f "$logfile" ] || echo "0 0" > "$logfile"
	read -r rxprev txprev < "$logfile"
	rxcurrent="$(($(paste -d '+' /sys/class/net/[ew]*/statistics/rx_bytes)))"
	txcurrent="$(($(paste -d '+' /sys/class/net/[ew]*/statistics/tx_bytes)))"
  echo "D:$(printf "%.1f" $(bc <<< "scale=3; ($rxcurrent-$rxprev) / 10^3"))KB" "U:$(printf "%.1f" $(bc <<< "scale=3; ($txcurrent-$txprev) / 10^3"))KB"
	echo "${rxcurrent} ${txcurrent}" > "$logfile"
}

print_backlight(){
  backlight_path="/sys/class/backlight/intel_backlight/"
  max_brightness=$(cat $backlight_path"max_brightness")
  current_brightness=$(cat $backlight_path"brightness")
  val_brightness_percent_scale_two=$(echo "scale=2;$current_brightness/$max_brightness*100"|bc)
  val_brightness_percent=$(echo $val_brightness_percent_scale_two | awk '{print int($1)}')
  echo "BL:"$val_brightness_percent"%"
}

print_battery(){
  battery_path="/sys/class/power_supply/BAT0/"
  battery_percentage=$(cat $battery_path"capacity")
  battery_status=$(cat $battery_path"status")
  echo "$battery_status BT:$battery_percentage%"
}

print_cpu_utilization(){
  cpu_util=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
  echo "CPU:$cpu_util%"
}

print_thermal(){
  thermal=$(acpi -t | grep -oP "(?<=ok, )\w+")
  echo "TM:$thermal°C"
}

while true
do
  xsetroot -name "$(print_battery) | $(print_cpu_utilization) | $(print_thermal) | $(print_alsa) | $(print_backlight) | $(print_network) | $(print_wifi) | $(print_mem) | $(print_date)"
  sleep 1
done
