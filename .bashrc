case $- in
  *i*) ;;
    *) return;;
esac

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=10000

SCRIPT_PATH="${BASH_SOURCE}"
while [ -L "${SCRIPT_PATH}" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"
  SCRIPT_PATH="$(readlink "${SCRIPT_PATH}")"
  [[ ${SCRIPT_PATH} != /* ]] && SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT_PATH}"
done
SCRIPT_PATH="$(readlink -f "${SCRIPT_PATH}")"
SCRIPT_DIR="$(cd -P "$(dirname -- "${SCRIPT_PATH}")" >/dev/null 2>&1 && pwd)"

export STARSHIP_CONFIG="$SCRIPT_DIR/starship.toml"
eval "$(starship init bash)"

escape_space() {
  echo "$(sed 's! !\\ !g' $1)"
}

alias ls='exa'
alias la='exa -a'

function p() {
  if [ $# -gt 0 ]; then
    pwsh.exe -nop -c "$@"
  else
    pwsh.exe -nol -NoProfileLoadTime
  fi
}

export WIN_HOME=$(wslpath $(p 'cd ~ && (pwd).Path') | cut -d $'\r' -f 1)
alias wh="cd $WIN_HOME"

export VSCODE="$(which code | escape_space)"
export EDITOR=nvim
alias vim=$EDITOR
alias vi=vim
alias v=vi

shopt -s autocd
. /usr/share/autojump/autojump.sh
alias r=ranger
alias e='explorer.exe .'
function jo() {
  j $1
  if [[ $1 != -* ]]; then
    e
    cd - > /dev/null
  fi
}
function jco() {
  jc $1
  if [[ $1 != -* ]]; then
    e
    cd - > /dev/null
  fi
}

alias s='source ~/.bashrc'

bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export MAKEFLAGS="-j $(nproc)"
export PATH=$PATH:/home/vrepetskyi/.cargo/bin