# some options that came from setup. tweak later?
unsetopt autocd  # don't interpret unknown commands as cd to directory
unsetopt beep # don't beep on error while editing
unsetopt extendedglob # don't "Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation"
unsetopt nomatch # don't "print an error" "If a pattern for filename generation has no matches"
unsetopt notify  # don't alert about background jobs immediately, wait til next prompt

# Vim mode
bindkey -v

# Completion
autoload -Uz compinit
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax Highlighting
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=1000
SAVEHIST=1000
# note: must come after autosuggestions and syntax highlighting
# https://github.com/zsh-users/zsh-history-substring-search?tab=readme-ov-file#usage
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Set XTerm title
# https://wiki.archlinux.org/title/Zsh#xterm_title
autoload -Uz add-zsh-hook

function xterm_title_precmd () {
    print -Pn -- '\e]2;%~\a'
}

function xterm_title_preexec () {
    print -Pn -- '\e]2;%~ %# ' && print -n -- "${(q)1}\a"
}

add-zsh-hook -Uz precmd xterm_title_precmd
add-zsh-hook -Uz preexec xterm_title_preexec

# Aliases
alias cat='bat'
alias diff='batdiff'
alias grep='batgrep'
alias grep='grep --color=auto'
alias ls='lsd'
alias man='batman'
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'

# Make SSH use GPG agent
SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export SSH_AUTH_SOCK

# Prompt configuration (see ~/.config/starship.toml)
eval "$(starship init zsh)"
