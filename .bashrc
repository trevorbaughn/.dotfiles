#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias nvims='nvim --listen /tmp/nvimsocket'
alias dotfiles='git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

PS1='[\u@\h \W]\$ '

PATH="/home/thego/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/thego/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/thego/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/thego/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/thego/perl5"; export PERL_MM_OPT;
