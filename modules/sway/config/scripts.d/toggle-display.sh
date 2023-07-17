#!/bin/sh

if [ "$1" = "on" ]; then
  swaymsg "output * dpms on"
  echo 1 > /tmp/lcd
elif [ "$1" = "off" ]; then
  swaymsg "output * dpms off"
  echo 0 > /tmp/lcd
else
  touch /tmp/lcd
  read lcd < /tmp/lcd
  if [ "$lcd" -eq "0" ]; then
    swaymsg "output * dpms on"
    echo 1 > /tmp/lcd
  else
    swaymsg "output * dpms off"
    echo 0 > /tmp/lcd
  fi
fi
