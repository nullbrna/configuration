function insert_branch() {
    LBUFFER+="$BRANCH" # NOTE: Inserted at cursor position.
}

zle -N insert_branch && bindkey "^B" insert_branch # <ctrl+b>
bindkey "^[f" history-beginning-search-forward     # <opt+left>
bindkey "^[b" history-beginning-search-backward    # <opt+right>

function git_section() {
    [[ -z "$BRANCH" ]] && return

    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local branchmeta
    (( working )) && branchmeta+="%F{003}~$working%f"
    (( staging )) && branchmeta+="%F{004}+$staging%f"
    (( stashed )) && branchmeta+="%F{005}!$stashed%f"
    # Prefix with whitespace to separate from the branch name.
    [[ -n "$branchmeta" ]] && branchmeta=" $branchmeta"

    print " [%F{109}$BRANCH%f$branchmeta]"
}

function before_command() {
    (( ! $? )) && local statcode=002
    ((   $? )) && local statcode=001

    BRANCH=$(git branch --show-current 2>/dev/null)
    PROMPT="[%F{182}%1d%f]$(git_section) %F{$statcode}•%f "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd before_command

source ~/.cargo/env
source ~/.orbstack/shell/init.zsh 2>/dev/null
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
