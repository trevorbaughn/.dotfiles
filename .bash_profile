#
# ~/.bash_profile
#

############
### MISC ###
############

# Bash prompt format
PS1='[\u@\h \W]\$ '

# Scripts directory
export PATH=$PATH:$HOME/bin/

# Fsync support (necessary for yabridge)
export WINEFSYNC=1

# Source .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc
