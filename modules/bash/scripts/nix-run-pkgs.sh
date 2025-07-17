nr() {
  local exec_prefix=""
  local exec_override=""
  local exec_background=""
  local pkg=""
  OPTIND=1

  show_help() {
    command cat <<EOF
Usage: nr [-s] [-d] [-e executable] <package-name> [-- args...]

Options:
  -s                Run with sudo
  -e <executable>   Override default executable (default: same as package name)
  -d                Run in background using 'hyprctl dispatch exec'
  -h                Show this help message

Arguments:
  <package-name>    The Nix package to run
  -- [args...]      Arguments passed to the executable

Examples:
  nr jq -- .foo.json
  nr -s e2fsprogs -- mke2fs /dev/sdX
  nr -d firefox
EOF
  }

  # Parse options
  while getopts ":se:dh" opt; do
    case $opt in
      s) exec_prefix="sudo" ;;
      e) exec_override="$OPTARG" ;;
      d) exec_background="hyprctl dispatch exec" ;;
      h) show_help; return 0 ;;
      \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
    esac
  done
  shift $((OPTIND -1))

  pkg="$1"
  if [[ -z "$pkg" ]]; then
    echo "Error: Missing <package-name>."
    show_help
    return 1
  fi

  local exec="${exec_override:-$pkg}"
  shift 1  # Remove package name from args
  local args=("$@")  # Remaining args passed to the executable

  if [[ -n "$exec_prefix" || -n "$exec_override" ]]; then
    $exec_background nix shell "nixpkgs#$pkg" --command $exec_prefix "$exec" "${args[@]}"
  else
    $exec_background nix run "nixpkgs#$pkg" -- "${args[@]}"
  fi
}

