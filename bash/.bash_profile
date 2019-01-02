# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi
echo ".bash_profile sourced!"

# longin shell prompt
# PS1='\[\033[01;32m\]\u@\h: \[\033[01;34m\]\w\n\[\033[01;32m\]!\!:\[\033[00m\]\$ '
PS1='\[\033[01;32m\]tansl@tfb: \[\033[01;34m\]\w\[\033[00m\]\$ '

# User specific environment and startup programs

# 'cd var' will try 'cd $var'
shopt -s cdable_vars
CDPATH=:$HOME:$HOME/server
export CDPATH

PATH=$HOME/bin:$PATH
PATH=$PATH:$HOME/.vim/perlx
export PATH

# /etc/man.config -- will be overwrite if $MANPATH exported
MANPATH=$HOME/share/man:/usr/man:/usr/share/man:/usr/local/man:/usr/local/share/man
export MANPATH

export PAGER=less
export EDITOR=vim

# 严格按 ASCII 排序
# export LC_ALL=C

# perl @INC .pm search path
export PERL5LIB=$HOME/perl5/mylib:$HOME/perl5/lib/perl5

# go
# export GOROOT=$HOME/share/go
# export GOPATH=$HOME/go
# PATH=$HOME/share/go/bin:$GOPATH/bin:$PATH
