# Source local env vars (outside git tree — survives checkout)
if [[ -f ~/.exports.sh ]]; then
  source ~/.exports.sh
fi

dotfiles() { git --git-dir="$HOME/dotfiles-linux" --work-tree="$HOME" "$@"; }

gitdot() {
  type -P gitui &>/dev/null || {
    echo "gitui not found" >&2
    return 1
  }
  export GIT_DIR="$HOME/dotfiles-linux"
  export GIT_WORK_TREE="$HOME"
  gitui
  unset GIT_DIR GIT_WORK_TREE
}

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

# --- Git branch in prompt (uses Fedora's built-in bash-color-prompt) ---
__git_branch_prompt() {
  local ref
  ref=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  PROMPT_GIT_BRANCH=${ref:+($ref)}
}

PROMPT_COMMAND="__git_branch_prompt; _update_title"
if command -v mise &>/dev/null; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi
if command -v atuin &>/dev/null; then
  eval "$(atuin init bash)"
fi
alias rpi='pi --resume'
alias cpi='pi --continue'
alias nspi='pi --no-session'
