#! /bin/bash

SNAP_ID_PATH=~/.config/snapper/last_snapshot_id

if [ ! -e "$SNAP_ID_PATH" ]; then
  SNAP_ID=$(snapper create -t pre -c timeline -p -d "Before $1")
  echo "$SNAP_ID,$1" > $SNAP_ID_PATH
  echo "Created PRE-snapshot with id $SNAP_ID"
else
  IFS=, read SNAP_ID SNAP_DESC < $SNAP_ID_PATH
  SNAP_ID_POST=$(snapper create -t post --pre-number $SNAP_ID -p -c timeline -d "After $SNAP_DESC")
  echo "Created POST-snapshot with id $SNAP_ID_POST from id $SNAP_ID"
  rm $SNAP_ID_PATH
fi
