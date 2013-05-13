# ~/.bashrc: executed by bash(1) for non-login shells.

export GIT_PS1_SHOWDIRTYSTATE=1
source ~/.dotfiles/git-completion.sh

########################################################################
# Stuff from the standard debian/ubuntu .bashrc
########################################################################
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoreboth:erasedups

export HISTTIMEFORMAT='%F %T '

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# colorize ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto --exclude-dir=.svn'
    alias fgrep='fgrep --color=auto --exclude-dir=.svn'
    alias egrep='egrep --color=auto --exclude-dir=.svn'
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
PATH=~/bin:$PATH

# default file permission of -rw-r--r-- (drwxr--r--)
umask 022

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

# Colour hash for hostname.

declare -a COLOUR_ARRAY

COLOUR_ARRAY[1]=$RED
COLOUR_ARRAY[2]=$GRN
COLOUR_ARRAY[3]=$YLW
COLOUR_ARRAY[4]=$BLU
COLOUR_ARRAY[5]=$MAG
COLOUR_ARRAY[6]=$CYN
COLOUR_ARRAY[7]=$WHT
COLOUR_ARRAY[8]=$(tput setab 7) # non-bold white (grey)
COLOUR_ARRAY[9]=$(tput setaf 3)  # non-bold yellow (orange)
COLOUR_ARRAY[0]=$(tput setaf 2) # non-bold green

USER_HOST_COLOUR=${COLOUR_ARRAY[$(echo "${USER}@${HOSTNAME}" | md5sum | sed s/[abcdef]*// | head --bytes 1)]}

function seperator {
    if [ $? -eq 0 ]; then
        COLOR=$GRN
    else
        COLOR=$RED
    fi

    if [[ $timer_result > 60 ]]; then
        echo "${RED}>>> elapsed time ${timer_result}s"
    elif [[ $timer_result > 10 ]]; then
        echo "${YLW}>>> elapsed time ${timer_result}s"
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

    # FIXME: should probably append to a different file per $$ and merge the result,
    # or look at:
    # http://stackoverflow.com/questions/338285/prevent-duplicates-from-being-saved-in-bash-history
    # For now, I'm just obsessively versioning the whole thing, so that I don't lose data.
    # Will dedup later.
    # I guess what I want is some kind of incremental search-tree backed history format,
    # (mapping search string to list of (filename, offset), in order?)
    # that can be written to by multiple processes at the same time. Should probs look at sqlite?
    #
    # Actually, fuck it: let's just use the built-in append-on-close, and use backup files.
    # Note that this creates crufty 2000-line files in ~, but I can't find a better solution
    # right now.
    SHELL_LOCAL_HISTORY=".bash_history_$$"
    history -a ~/${SHELL_LOCAL_HISTORY}.tmp
    if [ -f ~/${SHELL_LOCAL_HISTORY}.tmp ]
    then
        mv ~/${SHELL_LOCAL_HISTORY}.tmp ~/${SHELL_LOCAL_HISTORY}
        if [ -d ~/src/misc/.git ]
        then
            cp ~/${SHELL_LOCAL_HISTORY} ~/.bash_history ~/src/misc/
            (cd ~/src/misc && git add ${SHELL_LOCAL_HISTORY} .bash_history && \
                git commit --allow-empty --quiet -m "history from ${SHELL_LOCAL_HISTORY}" )
        fi
    fi
}

function timer_start {
    timer=${timer:-$SECONDS}
}

function timer_stop {
    timer_result=$(($SECONDS - $timer))
    unset timer
}

function display_virtualenv {
    if [[ ! -z $VIRTUAL_ENV ]]; then
        short_name=$(basename $VIRTUAL_ENV)
        echo ${MAG}$short_name${RST}
    fi
}

trap 'timer_start' DEBUG
PROMPT_COMMAND=timer_stop

export VIRTUAL_ENV_DISABLE_PROMPT="yes"
export PS1='$(seperator)\n${USER_HOST_COLOUR}\u@\h${RST} in ${WHT}\w$(__git_ps1 "${YLW} on branch %s")${RST} $(display_virtualenv)\n\$ '

# bash completion extensions for tmux
source ~/.dotfiles/tmux-completion.sh

##### load host-local configurations
if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
