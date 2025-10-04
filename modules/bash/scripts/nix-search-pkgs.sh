ns() {
  local pkg=""
  OPTIND=1

  show_help() {
    command cat <<EOF
Usage: ns <search-string>

Options:
  -h                Show this help message

Arguments:
  <package-name>    The search string
EOF
  }

  # Parse options
  while getopts "h" opt; do
    case $opt in
      h) show_help; return 0 ;;
      \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
    esac
  done
  shift $((OPTIND -1))

  if [[ -z "$1" ]]; then
    echo "Error: Missing <search-string>."
    show_help
    return 1
  fi

  nix search nixpkgs $@
}


