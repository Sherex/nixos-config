LOCK_PATH="/run/user/$UID/lockscreen-disabled.lock"

flash_led () {
  brightnessctl -d "input*::scrolllock" set 1
  sleep 0.1s
  brightnessctl -d "input*::scrolllock" set 0
}
lock_create () {
  echo "disabled" > "$LOCK_PATH"
  flash_led
  sleep 0.05s
  flash_led
}
lock_remove () {
  rm -f $LOCK_PATH
  flash_led
}
lock_state () {
  if [ ! -e "$LOCK_PATH" ]; then
    echo enabled
  else
    echo disabled
  fi
}

if [ "$1" = "disable" ]; then
  lock_create
elif [ "$1" = "enable" ]; then
  lock_remove
elif [ "$1" = "status" ]; then
  if [ "$(lock_state)" = "enabled" ]; then
    echo enabled
    exit 0
  else
    exit 2
  fi
elif [ "$1" = "toggle" ]; then
  if [ "$(lock_state)" = "enabled" ]; then
    lock_create
  else
    lock_remove
  fi
fi

