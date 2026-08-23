{ pkgs, lib }: let
  kdeconnect = pkgs.kdePackages.kdeconnect-kde + "/bin/kdeconnect-cli";
  fzf = lib.getExe pkgs.fzf;
in ''
  if [[ -z "$1" ]]; then
      echo "Usage: kdeshare <file-path>"
      exit 1
  fi

  if [[ ! -f "$1" ]]; then
      echo "Error: File '$1' does not exist."
      exit 1
  fi

  device=$(${kdeconnect} -a --name-only | ${fzf} --prompt="Select KDE Connect device: ")

  if [[ -z "$device" ]]; then
      echo "No device selected. Cancelled."
      exit 0
  fi

  ${kdeconnect} --share "$1" -n "$device"

  if [[ $? -eq 0 ]]; then
      echo "Sending '$1' to '$device'..."
  else
      echo "Failed to send file."
      exit 1
  fi
''
