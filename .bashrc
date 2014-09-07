# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# a place to put my own binaries!
export PATH=~/bin:$PATH

# use vi editing mode instead of default emacs
set -o vi
# but don't lose C-l as the "clear the screen" key
bind -m vi-insert "\C-l":clear-screen

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export TERM='xterm-256color' # pretty pretty colors
export HISTCONTROL=ignoreboth # don't save commands that start with space characters and don't save dupes
export HISTSIZE=1000 # keep the history file from growing gigantic
export HISTFILESIZE=2000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color output
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# advanced tab-completion for various commands in bash
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# define some color variables that make things pretty if possible
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    BLD=$(tput bold)
    RST=$(tput sgr0)
    RED=$BLD$(tput setaf 1)
    GRN=$BLD$(tput setaf 2)
    YLW=$BLD$(tput setaf 3)
    BLU=$BLD$(tput setaf 4)
    MAG=$(tput setaf 5)
    CYN=$(tput setaf 6)
    WHT=$BLD$(tput setaf 7)
fi

export GIT_PS1_SHOWDIRTYSTATE=1 # show * and + when repository is dirty
export PS1='\n${MAG}\u${RST}@${BLU}\h${RST} in ${WHT}\w$(__git_ps1 "${YLW} on branch %s")${RST}\n\$ '

# load host-local configurations
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
