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

function working_branch() {
    local branch_colour=229 muted_colour=240 detail

    # Get branch-specific detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep " M\| D\|??" | wc -l | tr -d " ")
    local staging=$(git diff   --cached --numstat 2> /dev/null                     | wc -l | tr -d " ")
    local stashed=$(git stash  list               2> /dev/null                     | wc -l | tr -d " ")

    # Concatenate all details if set.
    if [[ $working != "0" ]]; then detail+="~$working"; fi
    if [[ $staging != "0" ]]; then detail+="+$staging"; fi
    if [[ $stashed != "0" ]]; then detail+="!$stashed"; fi

    local name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ ! -z $name ]]; then echo "%F{$branch_colour}$name%f%F{$muted_colour}$detail%f "; fi
}

function current_directory() {
    local directory_colour=025
    echo "%F{$directory_colour}%1d%f"
}

function update_hook() {
    PROMPT="$(current_directory) $(working_branch)"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd update_hook

# Keybindings
##############

bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

# Dependencies
##############

source $HOME/.cargo/env
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
