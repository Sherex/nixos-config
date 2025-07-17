# Allow using {} in a git command to select which commit to reference
git() {
  local args=()
  local has_token=0
  for arg in "$@"; do
    while [[ $arg == *'{}'* ]]; do
      has_token=1
      token=$(gsc) || return 1
      arg=${arg/'{}'/$token}
    done
    args+=("$arg")
  done

  [ $has_token == 1 ] && echo "git" "${args[@]}"
  command git "${args[@]}"
}

