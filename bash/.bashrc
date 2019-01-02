# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# nonlogin bash
# print before PS1, print right and \r return to left inline
# PROMPT_COMMAND='printf "%${COLUMNS}s\r" "$(date +%T)<<$SHLVL"'
# PS1='\[\033[01;32m\]!\!: \[\033[01;34m\]\w\[\033[00m\]\$ '
PS1='\[\033[01;32m\]bash $SHLVL:\[\033[01;34m\]\w\[\033[00m\]\$ '

unalias vi

alias psu='ps -fu `whoami`'

alias pd=pushd
alias pd2='pushd +2'
alias pd3='pushd +3'
alias pd4='pushd +4'
alias dir='dirs -v'
alias lrt='ls -lrt | tail'

export ALYM=47.106.142.119
# more alias
. ~/.bash_alias

alias xsql='mysql -u gctest -pgctest -h 192.168.0.40 -A --default-character-set=utf8 trade'
alias tsql='mysql -u txjg -ptxjg001 -h 192.168.1.174 -A --default-character-set=utf8 trade '

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export  PYTHONSTARTUP=$HOME/.python_startup

function d
{
	if [[ $# == 0 ]]; then
		pushd
	elif [[ $# == 1 ]]; then
		local new_path="$(autojump $@)"
		if [[ -n "$new_path" ]]; then
			pushd "$new_path"
		else
			echo "not found path: $@"
		fi
	else
		echo "d expect at most one argument, uesed as pushd + autojump"
	fi
}
