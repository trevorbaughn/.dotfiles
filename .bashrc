#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias nvim-soc='nvim --listen /tmp/nvimsocket'
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

PS1='[\u@\h \W]\$ '

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

# QT Themes
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_STYLE_OVERRIDE="kvantum"

# Scripts directory
export PATH=$PATH:~/bin/
