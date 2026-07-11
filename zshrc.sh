# Environment - Symbols used in-shell.
##########################################

function stoll() {
    # First row, excluding the title row, and first column.
    local model=$(ollama ps | awk 'NR==2 {print $1}')
    [[ -z "$model" ]] && return

    # NOTE: Explicit prompt expansion for formatting codes. Not needed elsewhere
    # as the global prompt does this automatically.
    ollama stop "$model" && print -P "$(highlight 2 "Stopped") $model"
}

# Prompt - Configuring the prompt.
##########################################

# $1: ANSI colour code.
# $2: Text to be coloured.
function highlight() {
    print -r "%B%F{$1}$2%f%b"
}

# $1: Text to be wrapped in a delimiter.
function section() {
    print -r "%F{242}[%f$(highlight 248 "$1")%F{242}]%f"
}

function branch_metadata() {
    [[ -z "$BRANCH" ]] && return

    # Get branch detail. Count lines and trim leading whitespace.
    local working=$(git status --porcelain        2>/dev/null | wc -l | tr -d ' ')
    local staging=$(git diff   --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    local stashed=$(git stash  list               2>/dev/null | wc -l | tr -d ' ')

    local detail
    (( working )) && detail+="$(highlight 3 "~$working")"
    (( staging )) && detail+="$(highlight 4 "+$staging")"
    (( stashed )) && detail+="$(highlight 5 "!$stashed")"
    [[ -n "$detail" ]] && detail=" $detail"

    print " $(section "$BRANCH$detail")"
}

function update_hook() {
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
    PROMPT="$(section "%1d")$(branch_metadata) "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd update_hook

# Keybindings - Shortcuts used in-shell.
##########################################

bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

function print_branch() {
    LBUFFER+="$BRANCH"
}

zle -N print_branch && bindkey "^B" print_branch # ctrl+b

# Dependencies - External sourcing.
##########################################

source $HOME/.cargo/env

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NOTE: Taken from a generated ".zprofile" file.
source ~/.orbstack/shell/init.zsh 2>/dev/null
