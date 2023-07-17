#!/bin/bash

# Create looking-glass SHM
touch /dev/shm/looking-glass
chmod 664 /dev/shm/looking-glass
sudo chown nobody:kvm /dev/shm/looking-glass

# Start Scream (vm audio)
~/.config/sway/scripts.d/launch.sh start /usr/bin/scream -i virbr0

sudo virsh start win10-uefi || sudo virsh resume win10-uefi
