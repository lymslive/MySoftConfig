#! /bin/bash
##
# filename: findcmd.sh
# descript: find all command in search path $PATH
# create-t: 2012-01-05
# author-e: lymslive@sina.com
#
# accept one argument, use dot(.) as star(*) for match pattern
# cmd. => cmd* : match prefix
# .cmd => *cmd : match postfix
# .cmd. => *cmd* : math any cmd
# cmd : match exactly cmd
#
# Note: you can't directlly use * in cmdline, shell will expand it
# quoted star ('*') works, but it's inconvenient for input.
##

script="${0##*/}"
[ -z "$1" ] && echo "$script: Empty Input" && exit 1
cmd="${1//./*}"

path="$PATH"
while [ -n "$path" ]; do
    thispath="${path%%:*}"
    if cd "$thispath"; then
	ls $cmd | sed "s@^@$PWD/@"
    fi
    path="${path#*:}"
    [ "$path" != "$thispath" ] || break
done 2>/dev/null
