#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc


export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Better defaults
alias ls='ls -a --color=auto'
#alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias mount='mount |column -t'
alias rm='rm --preserve-root'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias wget='wget -c'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Better versions
alias grep='rg'
alias yay='paru'
alias diff='colordiff'
alias vi='vim'
alias top='atop'

# Super specific
alias start-ssh='eval "$(ssh-agent -s)"'
alias ssh-git='eval "$(ssh-agent -s)" && ssh-add ~/.ssh/git'
alias update='paru & flatpak update && flatpak upgrade'
gdflint() { gdlint "$1" && gdformat "$1"; }

# Hardware polling

alias meminfo='free -m -l -t'
## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

alias cpuinfo='lscpu'
## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'
 


