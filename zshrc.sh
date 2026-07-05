# Environment
##############

function stoll() {
    # First row, excluding the title row, and first column.
    local model=$(ollama ps | awk 'NR==2 {print $1}')
    [[ -z "$model" ]] && return

    ollama stop "$model" && echo "stopped: $model"
}

# Prompt
##############

# $1: ANSI colour code.
# $2: Text to be coloured.
function as_colour() {
    echo "%F{$1}$2%f"
}

# $1: Text to be wrapped in a delimiter.
function wrap_in_section() {
    local delim_col=242 section_col=248
    echo "$(as_colour $delim_col "[")$(as_colour $section_col "$1")$(as_colour $delim_col "]")"
}

function branch_metadata() {
    [[ -z "$BRANCH" ]] && return

    # Get branch detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local working_col=003 staging_col=004 stashed_col=005 detail

    (( working )) && detail+="$(as_colour $working_col "~$working")"
    (( staging )) && detail+="$(as_colour $staging_col "+$staging")"
    (( stashed )) && detail+="$(as_colour $stashed_col "!$stashed")"
    [[ -n "$detail" ]] && detail=" $detail"

    echo " $(wrap_in_section $BRANCH$detail)"
}

function update_hook() {
    BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)
    PROMPT="$(wrap_in_section "%1d")$(branch_metadata) "
}

autoload -Uz add-zsh-hook && add-zsh-hook precmd update_hook

# Keybindings
##############

bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

function print_branch() {
    LBUFFER+="$BRANCH"
}

zle -N print_branch && bindkey "^B" print_branch # ctrl+b

# Dependencies
##############

source $HOME/.cargo/env

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# NOTE: Taken from a generated ".zprofile" file.
source ~/.orbstack/shell/init.zsh 2>/dev/null
