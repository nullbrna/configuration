# Environment
##############

export EVC_DIR_ENVCMD="echo 'foo', echo 'bar'"
export EVC_ASYNC_BRA_MAIN="echo 'one', echo 'two'"

# Stop a single Ollama model instance. Only stops the top-most model listed.
stoll() {
    # First row (excluding the title row), first column.
    local name=$(ollama ps | awk 'NR==2 {print $1}')

    if [[ -n "$name" ]]; then
        ollama stop "$name"
        echo "stopped: $name"
    fi
}

# Prompt
##############

local dir_colour=025 branch_colour=229 muted_colour=240

function branch_metadata() {
    [[ -z $BRANCH ]] && return

    # Get branch-specific detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    # Concatenate all details if set.
    (( working )) && detail+="~$working"
    (( staging )) && detail+="+$staging"
    (( stashed )) && detail+="!$stashed"

    echo "%F{$branch_colour}$BRANCH%f%F{$muted_colour}$detail%f "
}

function update_hook() {
    BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)
    PROMPT="%F{$dir_colour}%1d%f $(branch_metadata)"
}

# Lazily load the hook function.
autoload -Uz add-zsh-hook && add-zsh-hook precmd update_hook

# Keybindings
##############

# Rotate through the suggested auto-fill commands by recency.
bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

function print_branch() {
    LBUFFER+=$BRANCH
}

# Bind the function before assigning the shortcut.
zle -N print_branch && bindkey "^B" print_branch # ctrl+b

# Dependencies
##############

source $HOME/.cargo/env
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
