# Return if non-interactive
case $- in
    *i*) ;;
        *) return;;
esac

# Helpers
SCRIPT_PATH="${BASH_SOURCE}"
while [ -L "${SCRIPT_PATH}" ]; do
    SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
    SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
    [[ ${SCRIPT_PATH} != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
done
SCRIPT_PATH="$(readlink -f "${SCRIPT_PATH}")"
SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"

escape_space() {
    echo "$(sed 's! !\\ !g' $1)"
}

# Shortcuts
alias v=vi
alias r=ranger
alias e='explorer.exe .'
function p() {
    if [ $# -gt 0 ]; then
        pwsh.exe -nop -c $@
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

export PROMPT_COMMAND='history -a;history -r'

# Completion
source /etc/profile.d/bash_completion.sh

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

source ~/source/fzf-tab-completion/bash/fzf-bash-completion.sh
_fzf_bash_completion_loading_msg() { echo "${PS1@P}${READLINE_LINE}" | tail -n1; }
bind -x '"\t": fzf_bash_completion'

# Navigation
export WIN_HOME=$(wslpath $(p 'cd ~ && (pwd).Path') | choose -f $'\r' 0)

eval "$(zoxide init bash)"

alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'

function g() {
    # Zoxide by default
    if [[ $# != 1 ]]; then
        z $@
    elif [[ ${1::1} == '^' ]]; then
        # Matching Windows directory
        if [[ $PWD/ = /home/$USER/* ]]; then
            cd $(echo $PWD | sd "^\/home\/$USER" '/mnt/d')
        elif [[ $PWD/ = /mnt/d/* ]]; then
            cd $(echo $PWD | sd '^\/mnt\/d' "/home/$USER")
        fi
    elif [[ $# == 1 && $1 =~ ^-(-|[0-9]|\/.+)?$ ]]; then
        # Directory history
        TARGET=$(cdhist -am 10 $@)
        if [[ $TARGET ]]; then
            cd $TARGET
        fi
    else
        cd $@
    fi
}
alias gi=zi

_g_completions() {
    if [[ ${COMP_WORDS[1]::1} == '-' ]]; then 
        COMPREPLY=($(cat ~/.cd_history))
    else
        COMPREPLY=($(compgen -d ${COMP_WORDS[1]}))
        COMPREPLY+=($(zoxide query -l ${COMP_WORDS[1]}))
    fi
}

complete -F _g_completions g

# Listing
alias ls='exa'
alias la='ls -a'
alias ll='la -l'

# Editor
export VSCODE="$(which code | escape_space)"
export EDITOR=nvim
alias vim=$EDITOR
alias vi=vim

# Copy/paste
alias copy=clip.exe
alias paste=paste.exe

# BASH vi-mode fix
paste_from_clipboard () {
  local shift=$1

  local head=${READLINE_LINE:0:READLINE_POINT+shift}
  local tail=${READLINE_LINE:READLINE_POINT+shift}

  local paste=$(paste | tr '\r\n' '\n')
  local paste_len=${#paste}

  READLINE_LINE=${head}${paste}${tail}

  let READLINE_POINT+=$paste_len+$shift-1
}

yank_line_to_clipboard () {
  echo $READLINE_LINE | copy
}

kill_line_to_clipboard () {
  yank_line_to_clipboard
  READLINE_LINE=""
}

bind -m vi-command -x '"P": paste_from_clipboard 0'
bind -m vi-command -x '"p": paste_from_clipboard 1'
bind -m vi-command -x '"yy": yank_line_to_clipboard'
bind -m vi-command -x '"dd": kill_line_to_clipboard'

# Cargo binaries
export PATH=$PATH:/home/vrepetskyi/.cargo/bin

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Use all CPU cores for make
export MAKEFLAGS="-j $(nproc)"

# Color gcc output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Prompt
export STARSHIP_CONFIG="$SCRIPT_DIR/starship.toml"
eval "$(starship init bash)"
