# Environment
##############

export EVC_DIR_ENVCMD="echo 'foo', echo 'bar'"
export EVC_ASYNC_BRA_MAIN="echo 'one', echo 'two'"

# Stop a single Ollama model instance. Only stops the top-most model listed.
function stoll() {
    # First row (excluding the title row), first column.
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

# $1: Text to be wrapped in delimiters.
function in_section() {
    local delim_col=242 section_col=248

    # Delimiter prefix & suffix. Coloured input text.
    echo "$(as_colour $delim_col "[")$(as_colour $section_col "$1")$(as_colour $delim_col "]")"
}

function branch_metadata() {
    [[ -z "$BRANCH" ]] && return

    # Get branch-specific detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep -c " M\| D\|??")
    local staging=$(git diff   --cached --numstat 2> /dev/null | grep -c "")
    local stashed=$(git stash  list               2> /dev/null | grep -c "")

    local working_col=005 staging_col=004 stashed_col=003 detail

    # Concatenate all existing details.
    (( working )) && detail+="$(as_colour $working_col "~$working")"
    (( staging )) && detail+="$(as_colour $staging_col "+$staging")"
    (( stashed )) && detail+="$(as_colour $stashed_col "!$stashed")"
    # Insert padding prefix if set.
    [[ -n "$detail" ]] && detail=" $detail"

    echo " $(in_section $BRANCH$detail)"
}

function update_hook() {
    BRANCH=$(git symbolic-ref --short HEAD 2> /dev/null)

    # Overwrite prompt. Trailing space for command input.
    PROMPT="$(in_section "%1d")$(branch_metadata) "
}

# Lazily load the hook function.
autoload -Uz add-zsh-hook && add-zsh-hook precmd update_hook

# Keybindings
##############

# Rotate through the suggested auto-fill commands by recency.
bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

function print_branch() {
    LBUFFER+="$BRANCH"
}

# Bind the function before assigning the shortcut.
zle -N print_branch && bindkey "^B" print_branch # ctrl+b

# Dependencies
##############

source $HOME/.cargo/env
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
