export EVC_DIR_WEBSRV="docker compose down --remove-orphans --rmi local ||| docker compose up --build"

function stoll() {
    local model=$(ollama ps | awk 'NR==2 {print $1}')
    [[ -z "$model" ]] && return

    ollama stop "$model" && print -P "%F{002}Stopped%f $model"
}

function show_branch() {
    LBUFFER+="$BRANCH"
}

zle -N show_branch && bindkey "^B" show_branch   # ctrl+b
bindkey "^[f" history-beginning-search-forward   # opt+left
bindkey "^[b" history-beginning-search-backward  # opt+right

function git_section() {
    [[ -z "$BRANCH" ]] && return

    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local detail
    (( working )) && detail+="%F{003}~$working%f"
    (( staging )) && detail+="%F{004}+$staging%f"
    (( stashed )) && detail+="%F{005}!$stashed%f"
    [[ -n "$detail" ]] && detail=" $detail"

    print " [%F{139}$BRANCH%f$detail]"
}

function before_command() {
    BRANCH=$(git branch --show-current 2>/dev/null)
    PROMPT="[%F{117}%1d%f]$(git_section) "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd before_command

source $HOME/.cargo/env
source ~/.orbstack/shell/init.zsh 2>/dev/null

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
