#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

###############
### ALIASES ###
###############

# Color & Direct Upgrades
alias ls='ls --color=auto'
alias grep='rg'

# Misc.
alias nvim-soc='nvim --listen /tmp/nvimsocket'
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

#############################
### PROGRAMMING LANGUAGES ###
#############################

# Ruby
export PATH=$PATH:$HOME/.gem/ruby/3.0.0/bin/

# Perl
PATH="/home/$(whoami)/perl5/bin${PATH:+:${PATH}}"
export PATH
PERL5LIB="/home/$(whoami)/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"
export PERL5LIB
PERL_LOCAL_LIB_ROOT="/home/$(whoami)/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"
export PERL_LOCAL_LIB_ROOT
PERL_MB_OPT="--install_base \"/home/$(whoami)/perl5\""
export PERL_MB_OPT
PERL_MM_OPT="INSTALL_BASE=/home/$(whoami)/perl5"
export PERL_MM_OPT

################
### LANGUAGE ###
################

export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus



