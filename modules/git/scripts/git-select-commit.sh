# Selects a commit using fzf
# Can be used like "git diff `gsc`..`gsc`"
gsc() {
  local selected
  selected=$(git log --oneline --decorate=short --color=always --date=relative --pretty=format:'%C(auto)%h %C(blue)%ad%Creset %s %d' |
             fzf --ansi --no-sort --reverse --tiebreak=index --height=40% --prompt="Select commit: ")

  [[ -z "$selected" ]] && return 1

  echo "$selected" | awk '{print $1}'
}
