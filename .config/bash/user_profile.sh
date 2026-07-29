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
  printf '\033]0;%s :: %s\007' "${PWD##*/}" "${0##*/}"
}

shopt -s histappend
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL=ignoredups:erasedups
PROMPT_COMMAND="_update_title; history -a; history -c; history -r"

export FZF_CTRL_R_OPTS="--bind 'alt-j:down' --bind 'alt-k:up' --height 10"
source /usr/share/fzf/shell/key-bindings.bash 2>/dev/null || source /usr/share/fzf/key-bindings.bash 2>/dev/null

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
