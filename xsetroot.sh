#!/bin/bash

print_alsa(){
  echo "Vol:$(amixer get Master | tail -n1 | sed -r "s/.*\[(.*)%\].*/\1/")%"
}

print_date(){
  echo $(date "+%Y-%m-%d %T")
}

print_wifi(){
  echo $(iwctl <<< "station wlan0 show" | grep "Connected network" | awk '{print $3}')
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
  echo "D:$(printf "%.2f" $(bc <<< "scale=2; ($rxcurrent-$rxprev) / 10^6"))M" "U:$(printf "%.2f" $(bc <<< "scale=2; ($txcurrent-$txprev) / 10^6"))M"
	echo "${rxcurrent} ${txcurrent}" > "$logfile"
}

while true
do
  xsetroot -name "$(print_alsa) $(print_wifi) $(print_network) $(print_mem) $(print_date)"
  sleep 1
done
