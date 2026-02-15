# Prompt
##############

COL_DIR=025
COL_GIT=229
COL_MUT=240

function branch() {
    local detail

    # Get branch-specific detail. Count lines and trim leading whitespace.
    local working=$(git status --short            2> /dev/null | grep " M\| D\|??" | wc -l | tr -d " ")
    local staging=$(git diff   --cached --numstat 2> /dev/null                     | wc -l | tr -d " ")
    local stashed=$(git stash  list               2> /dev/null                     | wc -l | tr -d " ")

    # Concatenate all details if set.
    if [[ $working != "0" ]]; then detail+="~$working"; fi
    if [[ $staging != "0" ]]; then detail+="+$staging"; fi
    if [[ $stashed != "0" ]]; then detail+="!$stashed"; fi

    local name=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ ! -z $name ]]; then echo "%F{$COL_GIT}$name%f%F{$COL_MUT}$detail%f "; fi
}

function prompt() {
    local directory="%F{$COL_DIR}%1d%f"
    PROMPT="$directory $(branch)"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt

# Keybindings
##############

bindkey "^[f" history-beginning-search-forward  # opt+left
bindkey "^[b" history-beginning-search-backward # opt+right

# Dependencies
##############

source $HOME/.cargo/env
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
