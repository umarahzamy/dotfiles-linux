# Source local env vars (outside git tree — survives checkout)
if [[ -f ~/.exports ]]; then
  source ~/.exports
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

# pi -- smart session launcher for the pi coding agent
pi() {
  # Fast pass-through for simple queries (skip session scan)
  for arg do
    if [[ $arg == "--help" ]] || [[ $arg == "-h" ]] || [[ $arg == "--version" ]]; then
      command pi "$@"
      return $?
    fi
  done

  local encoded session_dir
  # Encode $PWD into the same hash pi uses for its session folder
  #   /home/user/foo  ->  --home-user-foo--
  local dir="${PWD#/}"
  encoded="--${dir//\//-}--"
  session_dir="${PI_CODING_AGENT_SESSION_DIR:-$HOME/.pi/agent/sessions}/$encoded"

  local -a sessions=()
  if [[ -d "$session_dir" ]]; then
    local backup_nullglob
    backup_nullglob=$(shopt -p nullglob 2>/dev/null || true)
    shopt -s nullglob
    sessions=( "$session_dir"/*.jsonl )
    eval "$backup_nullglob"
  fi

  local n=${#sessions[@]}
  case "$n" in
    0) command pi "$@"; return $? ;;
    1) command pi --continue "$@"; return $? ;;
    *) command pi --resume "$@"; return $? ;;
  esac
}
