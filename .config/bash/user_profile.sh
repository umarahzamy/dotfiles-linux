# Source local env vars (outside git tree — survives checkout)
if [[ -f ~/.exports.sh ]]; then
  source ~/.exports.sh
fi

dotfiles() { git --git-dir="$HOME/dotfiles-linux" --work-tree="$HOME" "$@"; }

yazi() {
  type -P yazi &>/dev/null || {
    echo "yazi not found" >&2
    return 1
  }
  if (( $# == 0 )); then
    command yazi "$PWD"
  else
    command yazi "$@"
  fi
}

ssh() {
  local host="$1"
  [[ -n $host ]] && printf '\033]0;ssh :: %s\007' "$host"
  command ssh "$@"
  local ret=$?
  printf '\033]0;%s\007' "$PWD"
  return $ret
}

_update_title() {
  local title="${PWD##*/} :: ${0##*/}"
  printf '\033]0;%s\007' "$title"
}

shopt -s histappend
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL=ignoredups:erasedups
# --- Git branch in prompt (uses Fedora's built-in bash-color-prompt) ---
__git_branch_prompt() {
  local ref
  ref=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  PROMPT_GIT_BRANCH=${ref:+($ref)}
}

PROMPT_COMMAND="__git_branch_prompt; _update_title; history -a; history -c; history -r"

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

BASE=~/containers/$(whoami)
DEST=~/.config/containers/systemd
systemctl --user daemon-reload

mkdir -p "$DEST"
find "$DEST" -xtype l -delete

# Process substitution avoids subshell issues from piping to while
while IFS= read -r -d '' file; do
  ext="${file##*/}"
  ext="${ext#.}"
  [[ "$ext" != @(container|network|volume|build|pod|kube|artifact|env) ]] && continue

  dir=$(dirname "$file")
  rel="${dir#"$BASE"/}"

  name="${rel//\//-}.$ext"
  ln -sf "$file" "$DEST/$name"
done < <(find "$BASE" -name ".*" -not -path "*/.*/*" -print0)

alias rpi='pi --resume'
alias cpi='pi --continue'
alias nspi='pi --no-session'
