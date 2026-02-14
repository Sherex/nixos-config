nr() {
  local exec_prefix=""
  local pkg_override=""
  local exec_background=""
  local exec=""
  OPTIND=1

  show_help() {
    command cat <<EOF
Usage: nr [-s] [-d] [-e executable] <package-name> [-- args...]

Options:
  -s                Run with sudo
  -p <package>      Override default package (default: same as executable name)
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
  while getopts ":sp:dh" opt; do
    case $opt in
      s) exec_prefix="sudo" ;;
      p) pkg_override="$OPTARG" ;;
      d) exec_background="hyprctl dispatch exec" ;;
      h) show_help; return 0 ;;
      \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
    esac
  done
  shift $((OPTIND -1))

  exec="$1"
  if [[ -n "$pkg_override" && -z "$exec" ]]; then
    echo "Error: Missing <executable-name>."
    show_help
    return 1
  elif [[ -z "$exec" ]]; then
    echo "Error: Missing <package-name>."
    show_help
    return 1
  fi

  local package="${pkg_override:-$exec}"
  shift 1  # Remove package name from args
  local args=("$@")  # Remaining args passed to the executable

  if [[ -n "$exec_prefix" || -n "$pkg_override" || -n "$exec_background" ]]; then
    nix shell "nixpkgs#$package" --command $exec_background $exec_prefix "$exec" "${args[@]}"
  else
    nix run "nixpkgs#$exec" -- "${args[@]}"
  fi
}

