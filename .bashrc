# ~/.bashrc: executed by bash(1) for non-login shells.

export GIT_PS1_SHOWDIRTYSTATE=1
source ~/.dotfiles/git-completion.sh

set -o vi
bind -m vi-insert "\C-l":clear-screen

########################################################################
# Stuff from the standard debian/ubuntu .bashrc
########################################################################
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# colorize ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

########################################################################
# basic neil stuff
########################################################################
# use a private bin
PATH=~/.bin:$PATH

# default file permission of -rw-r----- (drwxr-----)
umask 027

# make the permissions more permissive when using sudo
function sudo() {
    local UMASK=$(umask);
    umask 022;
    sh -c "sudo $*";
    umask $UMASK
}

########################################################################
# colorized prompt stuff
########################################################################
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# We have color support; assume it's compliant with Ecma-48
# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# a case would tend to support setf rather than setaf.)
    color_prompt=yes
else
    color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    BLD=$(tput bold)
    RST=$(tput sgr0)
    RED=$BLD$(tput setaf 1)
    GRN=$BLD$(tput setaf 2)
    YLW=$BLD$(tput setaf 3)
    BLU=$BLD$(tput setaf 4)
    MAG=$(tput setaf 5)
    CYN=$(tput setaf 6)
    WHT=$BLD$(tput setaf 7)
else
    BLD=""
    RST=""
    RED=""
    GRN=""
    YLW=""
    BLU=""
    MAG=""
    CYN=""
    WHT=""
fi

function seperator {
    if [ $? -eq 0 ]; then
        COLOR=$GRN
    else
        COLOR=$RED
    fi
	if [[ $timer_result < 60 && $timer_result > 10 ]]; then
		echo "${GRN}>>> elapsed time ${timer_result}s"
	elif [[ $timer_result -ge 60 ]]; then
		let "timer_minutes = $timer_result / 60"
		let "timer_seconds = $timer_result % 60"
		
		if [[ $timer_minutes -ge 60 ]]; then
			let "timer_hours = $timer_minutes / 60"
			let "timer_minutes = $timer_minutes % 60"
			echo "${RED}>>> elapsed time ${timer_hours}h${timer_minutes}m${timer_seconds}s"
		else
			echo "${YLW}>>> elapsed time ${timer_minutes}m${timer_seconds}s"
		fi
    fi

    echo -n $COLOR
    case $OSTYPE in
        linux-gnu*)
            printf '_%.0s' `seq 1 $COLUMNS`
        ;;
        darwin*)
            jot -s "" -b "_" $COLUMNS -n
        ;;
    esac
    echo -n $RST
}

function timer_start {
    timer=${timer:-$SECONDS}
}

function timer_stop {
    timer_result=$(($SECONDS - $timer))
    unset timer
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop

export PS1='$(seperator)\n${MAG}\u${RST}@${BLU}\h${RST} in ${WHT}\w$(__git_ps1 "${YLW} on branch %s")${RST}\n\$ '

# bash completion extensions for tmux
source ~/.dotfiles/tmux-completion.sh

##### load host-local configurations
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi
