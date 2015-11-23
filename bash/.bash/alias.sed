#! /bin/sed -rnf
# convert bash_aliasrc to bash_aliases

/^#/! s/^\s*(\S+)[ =]+(.+)$/alias \1='\2'/p
