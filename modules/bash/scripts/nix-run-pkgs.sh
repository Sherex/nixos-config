nr() {
  local exec_prefix=""
  local exec_override=""
  local exec_background=""
  local pkg=""
  OPTIND=1

  # Parse options
  while getopts ":se:d" opt; do
    case $opt in
      s) exec_prefix="sudo" ;;
      e) exec_override="$OPTARG" ;;
      d) exec_background="hyprctl dispatch exec" ;;
      \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
    esac
  done
  shift $((OPTIND -1))

  pkg="$1"

  if [[ -z "$pkg" ]]; then
    echo "Usage: nix_run_pkg [-s] [-e executable] <package-name> [-- args...]"
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

