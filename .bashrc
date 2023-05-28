#!/bin/bash

# Return if non-interactive
[ -z "$PS1" ] && return

# Cargo binaries
export PATH="$PATH:/home/vrepetskyi/.cargo/bin"

# Helpers
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "${SCRIPT_PATH}" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
    SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
    [[ "${SCRIPT_PATH}" != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
done
SCRIPT_PATH="$(readlink -f "${SCRIPT_PATH}")"
SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"

# Shortcuts
alias v=vi
alias r=ranger
alias e='explorer.exe . || true'
p() {
    if [ $# -gt 0 ]; then
        pwsh.exe -nop -c "$@"
    else
        pwsh.exe -nol -NoProfileLoadTime
    fi
}
alias s='source ~/.bashrc'

# Terminal size update
shopt -s checkwinsize

# Match '**' pattern
shopt -s globstar

# History
shopt -s histappend

HISTCONTROL=ignoreboth
HISTSIZE=99999
HISTFILESIZE=99999

export PROMPT_COMMAND='history -a; history -r'

# Completion
source /etc/profile.d/bash_completion.sh

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source ~/source/fzf-tab-completion/bash/fzf-bash-completion.sh
bind -x '"\t": fzf_bash_completion'

export FZF_DEFAULT_OPTS='--height 40% --layout reverse'

# Navigation
export WIN_HOME="$(wslpath "$(p '$env:USERPROFILE')" | sd '\r' '')"

_escape_path() {
    echo "$1" | sd '/' '\/'
}

_shorten_home() {
    echo "$1" | sd "^$HOME" '~'
}

_g_rel() {
    # Expand dots to a relative path
    # g ... -> g ../../
    local target
    for _ in $(seq 2 ${#1}); do
        target="$target../"
    done
    echo "$target"
}

_g_match() {
    # g ^ -> g <path to a matching Windows/Linux directory>
    local target
    # Go to a matching...
    if [[ "$PWD" =~ ^/home/$USER/?.*$ ]]; then
        # ...Windows directory
        local escaped_home="$(_escape_path "$HOME")"
        target="$(echo "$PWD" | sd "^$escaped_home" "$WIN_HOME")"
    elif [[ "$PWD" =~ ^$WIN_HOME/?.*$ ]]; then
        # ...Linux directory
        local escaped_win_home="$(_escape_path "$WIN_HOME")"
        target="$(echo "$PWD" | sd "^$escaped_win_home" "$HOME")"
    fi
    if [[ -d "$target" ]]; then
        echo "$target"
    fi
}

_g_hist() {
    # Use a history record
    # g -[{-|<number>|/<path>}]
    cdhist -am 10 "$1"
}

_g_exact() {
    # Check for an exact match
    if [[ -d "$1" ]]; then
        echo "$1"
    fi
}

_g_zoxide() {
    # If no target was found, use Zoxide to resolve the query;
    zoxide query -l "$@"
}

g() {
    local target

    if [[ $# == 1 ]]; then
        target="$(_g_exact "$1")"
        if [[ ! "$target" ]]; then
            if [[ "$1" =~ ^\.{3,}$ ]]; then
                target="$(_g_rel "$1")"
            elif [[ "$1" == '^' ]]; then
                target="$(_g_match)"
                if [[ ! "$target" ]]; then
                    echo "No matching directory" >&2
                    return 1
                fi
            elif [[ "$1" =~ ^-(-|[0-9]|\/.+)?$ ]]; then
                target="$(_g_hist "$1")"
                if [[ ! "$target" ]]; then
                    return
                fi
            fi
        fi
    fi

    if [[ ! "$target" ]]; then
        # Select from multiple results using fzf
        target="$(_g_zoxide "$@" | fzf -0 -1)"
    fi

    if [[ "$target" ]]; then
        # Proceed to the target directory,
        # append it to the history,
        # and print its contents
        cd "$target" || exit
        zoxide add .
        echo
        _shorten_home "$(cdhist .)"
        ls
    else
        echo "No directory selected" >&2
        return 1
    fi
}

_g_comp() {
    mapfile -t -O "${#COMPREPLY[@]}" COMPREPLY < <(_shorten_home "$1" | sd '([^/])[\n ]' '$1/\n')
}

_g() {
    if [[ "${#COMP_WORDS[@]}" -gt 2 ]]; then
        # Only complete for <= 1 arguments
        return
    fi

    if [[ "${COMP_WORDS[1]}" =~ ^\.{3,}$ ]]; then
        # Expand dots
        _g_comp "$(_g_rel "${COMP_WORDS[1]}")"
    elif [[ "${COMP_WORDS[1]::1}" == '^' ]]; then
        # Expand matching
        _g_comp "$(_g_match)"
    elif [[ "${COMP_WORDS[1]::1}" != '-' ]]; then
        # Don't expand history

        # Reuse bash_completion cd functionality
        _cd

        if [[ "${COMP_WORDS[1]}" && ! "${COMP_WORDS[1]}" =~ \.\. ]]; then
            # Add Zoxide suggestions for non-relative paths
            # (also excluding the current path and its direct descendants)
            _g_comp "$(_g_zoxide "${COMP_WORDS[@]:1}" | rg -v "^$PWD/?[^/]*/?$")"
        fi
    fi
}

complete -F _g -o nospace g

# Listing
alias ls='exa'
alias la='ls -a'
alias ll='la -l'

# Editor
export VSCODE="$(which code | sd ' ' '\ ')"
export EDITOR=nvim
alias vim=\$EDITOR
alias vi=vim

# Copy/paste
alias copy=clip.exe
alias paste=paste.exe

# BASH vi-mode fix
yank_line_to_clipboard() {
    echo "$READLINE_LINE" | copy
}

kill_line_to_clipboard() {
    yank_line_to_clipboard
    READLINE_LINE=""
}

paste_from_clipboard() {
    local shift="$1"

    local head="${READLINE_LINE:0:READLINE_POINT+shift}"
    local tail="${READLINE_LINE:READLINE_POINT+shift}"

    local clip="$(paste | sd '\r\n' '\n')"
    local paste_len="${#clip}"

    READLINE_LINE="${head}${clip}${tail}"

    ((READLINE_POINT += "$paste_len+$shift-1"))
}

replace_line_with_clipboard() {
    READLINE_LINE=""
    paste_from_clipboard 0
}

bind -m vi-command -x '"yy": yank_line_to_clipboard'
bind -m vi-command -x '"dd": kill_line_to_clipboard'
bind -m vi-command -x '"P": paste_from_clipboard 0'
bind -m vi-command -x '"p": paste_from_clipboard 1'
bind -m vi-command -x '"Vp": replace_line_with_clipboard'

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Use all CPU cores for Make
export MAKEFLAGS="-j $(nproc)"

# Color GCC output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Prompt
export STARSHIP_CONFIG="$SCRIPT_DIR/starship.toml"
eval "$(starship init bash)"
