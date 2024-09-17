#!/bin/bash

backlight_path="/sys/class/backlight/intel_backlight/"
max_brightness=$(cat $backlight_path"max_brightness")
current_brightness=$(cat $backlight_path"brightness")
val_sub_ten_percent=$(expr $current_brightness - 750)
brightness_sub_ten_percent=$(echo $val_sub_ten_percent)
if ((brightness_sub_ten_percent>=750))
then
  echo $brightness_sub_ten_percent > $backlight_path"brightness"
fi
