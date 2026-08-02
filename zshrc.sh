# Environment
############################################################

function stoll() {
    local model=$(ollama ps | awk 'NR==2 {print $1}')
    [[ -z "$model" ]] && return

    # -P: Interpret prompt expansion sequences.
    ollama stop "$model" && print -P "$(highlight 2 "Stopped") \"$model\""
}

function printbranch() {
    LBUFFER+="$BRANCH"
}

zle -N printbranch && bindkey "^B" printbranch   # ctrl+b
bindkey "^[f" history-beginning-search-forward   # opt+left
bindkey "^[b" history-beginning-search-backward  # opt+right

# Prompt
############################################################

# $1: ANSI colour code.
# $2: Text to be coloured.
function highlight() {
    print "%B%F{$1}$2%f%b"
}

# $1: Text to be wrapped in a delimiter.
function section() {
    print "%F{242}[%f$(highlight 248 "$1")%F{242}]%f"
}

function gitsection() {
    [[ -z "$BRANCH" ]] && return

    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local detail
    (( working )) && detail+="$(highlight 3 "~$working")"
    (( staging )) && detail+="$(highlight 4 "+$staging")"
    (( stashed )) && detail+="$(highlight 5 "!$stashed")"
    [[ -n "$detail" ]] && detail=" $detail"

    print " $(section "$BRANCH$detail")"
}

function customhook() {
    BRANCH=$(git branch --show-current 2>/dev/null)
    PROMPT="$(section "%1d")$(gitsection) "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd customhook

# Dependencies
############################################################

source $HOME/.cargo/env
source ~/.orbstack/shell/init.zsh 2>/dev/null

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
