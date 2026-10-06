function insert_branch() {
    # NOTE: Inserted at cursor position.
    LBUFFER+="$BRANCH"
}

zle -N insert_branch && bindkey "^B" insert_branch # [ctrl+b]
bindkey "^[f" history-beginning-search-forward     # [opt+left]
bindkey "^[b" history-beginning-search-backward    # [opt+right]

function git_section() {
    [[ -z "$BRANCH" ]] && return

    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local change_detail
    (( working )) && change_detail+="%F{003}~$working%f"
    (( staging )) && change_detail+="%F{004}+$staging%f"
    (( stashed )) && change_detail+="%F{005}!$stashed%f"
    # Prefix with whitespace to separate from the branch name.
    [[ -n "$change_detail" ]] && change_detail=" $change_detail"

    print " [%F{139}$BRANCH%f$change_detail]"
}

function before_command() {
    (( ! $? )) && local status_colour=002
    ((   $? )) && local status_colour=001

    BRANCH=$(git branch --show-current 2>/dev/null)
    PROMPT="[%F{117}%1d%f]$(git_section) %F{$status_colour}•%f "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd before_command

source $HOME/.cargo/env
source ~/.orbstack/shell/init.zsh 2>/dev/null
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
