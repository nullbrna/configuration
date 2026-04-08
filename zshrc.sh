# Environment
##############

export EVC_DIR_ENVCMD="echo 'foo', echo 'bar'"
export EVC_ASYNC_BRA_MAIN="echo 'one', echo 'two'"

# Stop a single Ollama model instance. Only stops the top-most model listed.
function stoll() {
    # First row (excluding the title row), first column.
    local model=$(ollama ps | awk 'NR==2 {print $1}')

    [[ -z $model ]] && return
    ollama stop "$model" && echo "stopped: $model"
}

# Prompt
##############

DIR_COL=025 BRANCH_COL=229 MUTED_COL=240

function branch_metadata() {
    [[ -z $BRANCH ]] && return

    # Get branch-specific detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local detail
    # Concatenate all details if set.
    (( working )) && detail+="~$working"
    (( staging )) && detail+="+$staging"
    (( stashed )) && detail+="!$stashed"

    echo "%F{$BRANCH_COL}$BRANCH%f%F{$MUTED_COL}$detail%f "
}

function update_hook() {
    BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)
    PROMPT="%F{$DIR_COL}%1d%f $(branch_metadata)"
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
