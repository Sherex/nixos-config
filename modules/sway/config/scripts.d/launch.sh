#!/bin/bash

COMMAND=$1
EXEC_PATH=$2
EXEC_ARGS=${@:3}
NAME=$(basename $EXEC_PATH)
LOCK_PATH=/tmp/launch-$NAME.lock

killExec() {
  read launchpid < $LOCK_PATH
  kill $launchpid
  rm "$LOCK_PATH"
  echo "Killed $NAME with PID: $launchpid"
}

startExec() {
  $EXEC_PATH $EXEC_ARGS &
  launchpid=$!
  echo $launchpid > "$LOCK_PATH"
  echo "Started $NAME with PID: $launchpid"
}

if [ "$COMMAND" = "start" ]; then
  if [ ! -e "$LOCK_PATH" ]; then
    startExec
  fi
elif [ "$COMMAND" = "stop" ]; then
  if [ -e "$LOCK_PATH" ]; then
    killExec
  fi
else
  if [ -e "$LOCK_PATH" ]; then
    killExec
  else
    startExec
  fi
fi
