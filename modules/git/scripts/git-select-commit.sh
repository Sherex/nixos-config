# Selects a commit using fzf
# Can be used like "git diff `gsc`..`gsc`"
gsc() {
  if ! git rev-parse --is-inside-work-tree 1>/dev/null; then
    echo "Not inside a git repository" >&2
    return 1
  fi

  local selected
  selected=$(git log --oneline --decorate=short --color=always --date=relative \
              --pretty=format:'%C(auto)%h %C(blue)%ad%Creset %s %d' |
    fzf --ansi --no-sort --reverse --tiebreak=index --height=95% \
        --prompt="Type hash or message to filter: " \
        --nth=3.. \
        --preview='
          commit=$(echo {} | awk "{print \$1}")
          git show --color=always "$commit"
        ' \
        --preview-window=down:70%:wrap:follow \
        --bind 'ctrl-o:execute-silent(git checkout $(echo {} | awk "{print \$1}"))+abort' \
        --bind 'ctrl-y:execute-silent(echo {} | awk "{print \$1}" | wl-copy -n)' \
        --header='Keybinds: ctrl-o=checkout, ctrl-y=copy hash')

  [[ -z "$selected" ]] && return 1

  echo "$selected" | awk '{print $1}'
}
