sudo efibootmgr -c -d /dev/disk/by-label/nixboot -p 1 -L NixOS -l '\EFI\BOOT\BOOTX64.EFI'
