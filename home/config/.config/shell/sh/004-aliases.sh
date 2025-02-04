# directories
alias ..='cd ..'
alias cd..='cd ..'

# quick shortcuts
alias c=cargo
alias e=$EDITOR
alias g=git
alias j=just
alias m=make
alias n=nix
alias t=tux
alias v=nvim
alias vim=nvim


# default command flags
[[ -n "$(command -v bat)" ]] && alias cat=bat
alias df="df -Tha --total"
alias egrep='egrep --color=auto'
alias grep='grep --color=auto'
alias pgrep='pgrep -l'

# git shortcuts
alias ga="git add"
alias gc="git commit --verbose"
alias gs="git status -s"
alias ls="eza -alG"
alias clr="clear"s
alias ip="curl -4 icanhazip.com #public IP address"
alias ll="ls -alG"
alias ldir="ls -al | grep ^d"
alias o=o"pen ."
alias ut="uptime"
alias lip="ifconfig | grep \inet \ | grep -Fv 127.0.0.1 | awk '{print $2}'"
alias k="kubectl"
alias kap="kubectl apply -f"
alias kad="kubectl delete -f" 
alias vi="nvim"
alias tf="terraform"