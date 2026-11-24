function insert_branch() {
  # NOTE: Inserted at cursor position.
  LBUFFER+="$BRANCH"
}

function git_section() {
  [[ -z "$BRANCH" ]] && return

  # 1. Get Git-related metadata. Ignore any errors and count any lines
  # containing the given pattern - empty pattern is a line count.
  local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
  local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
  local stashed=$(git stash  list               2> /dev/null | grep -c "")

  # 2. Check if any counts are non-zero. If so, they can be coloured and
  # prefixed with an identifier.
  local branchmeta
  (( working )) && branchmeta+="%F{003}~$working%f"
  (( staging )) && branchmeta+="%F{004}+$staging%f"
  (( stashed )) && branchmeta+="%F{005}!$stashed%f"

  # 3. If there's branch metadata, insert padding from the branch name.
  [[ -n "$branchmeta" ]] && branchmeta=" $branchmeta"
  print " [%F{139}$BRANCH%f$branchmeta]"
}

function before_command() {
  (( ! $? )) && local statcode=002
  ((   $? )) && local statcode=001

  BRANCH=$(git branch --show-current 2>/dev/null)
  PROMPT="[%F{117}%1d%f]$(git_section) %F{$statcode}•%f "
}

# <N> Register as a ZLE widget. Required for keybinding.
zle -N insert_branch && bindkey "^B" insert_branch # <ctrl+b>
bindkey "^[f" history-beginning-search-forward     # <opt+left>
bindkey "^[b" history-beginning-search-backward    # <opt+right>
autoload add-zsh-hook && add-zsh-hook precmd before_command

source ~/.cargo/env
source ~/.orbstack/shell/init.zsh 2>/dev/null
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
