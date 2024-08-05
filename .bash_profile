#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Bash prompt format
PS1='[\u@\h \W]\$ '

###############
### ALIASES ###
###############

# Color & Direct Upgrades
alias ls='ls --color=auto'
alias grep='rg'

# Misc.
alias nvim-soc='nvim --listen /tmp/nvimsocket'
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

############
### MISC ###
############

# Scripts directory
export PATH='$PATH:$HOME/bin/'
