#! /bin/bash
##
# filename: gtcd.sh
# descript: g (Goto) t (Target) command, as but more for cd and pushd
# create-t: 2012-01-03
# author-e: lymsive@sina.com
#
# Don't change the builtin cd and pushd, only custom g command.
##

# Function: Goto {{{2
# Goto: [option -[lLaA]] [path | label | index]
# Goto or change to another directory as cd, but use pushd.
# Accept an explicity path argument, and if the path is invalid, try to treat
# it as the index/subcript of target array. see detail inputof findTarget().
# and further try shortdir abbrevation path. see Gotodir later
#
# Special Argument:
# Goto  <NONE INPUT>, show the DIRSTACK as dirs
# Goto . <A DOT>, pushd current dir into DIRSTACK
# Goto "" <A EMPTY STRING> reset the DIRSTACK, popd enough times
#
# After Goto command, may auto list the content of pwd
# Option:
# -l: ls when cd into dir; -L: not ls. set/reset AUTOList value
# -a: add to cd history; -A: not add to history, set/reset AUTOHist value
#
# if Goto do change pwd, .exit.sh and .enter.sh will auto sourced if they
# exist in the old and new pwd
function Goto()
{
    local target
    local usage="[option -[lLaA]] [path | label | index]"

    local opt optind_old=$OPTIND
    OPTIND=1
    while getopts ":lLaA" opt; do
	case $opt in
             l ) AUTOList="on" ;;
             L ) AUTOList="off" ;;
             a ) AUTOHist="on" ;;
             A ) AUTOHist="off" ;;
	    \? ) echo Invalid option: $FUNCNAME [-l -L -a -A] path
		 return 1 ;;
	esac
    done
    shift $(($OPTIND - 1)); OPTIND=$optind_old

    if (( $# > 1 )); then
	echo "Too many argument: $FUNCNAME $usage"
	return 1
    elif (( $# == 1 )); then
	if [ "$1" = '.' ]; then
	    pushd .
	elif [ -z "$1" ]; then
	    reset_dirstack
	else
	    Gotodir "$1"
	fi
    else # $# == 0
	dirs
    fi

    [ "$PWD" != "$OLDPWD" ] && [ -r "$OLDPWD/.exit.sh" ] && source "$OLDPWD/.exit.sh"
    postCDList
    [ -r ".enter.sh" ] && source ".enter.sh"
}

# Function: Gotodir {{{2
# Another normal Gotodir functionality. Require a argument.
# Try cd in the following order:
# cd $1, the cdvar and cdpath set may effect it's behavior
# search $1 in TARget or TAGdir array
# treat $1 as shortdir name(eg .a.b.c)
function Gotodir()
{
    if (( $# != 1 )) || [ -z "$1" ]; then
	echo "Invalid or empty argument: $FUNCNAME"
    fi

    if cd "$1" > /dev/null 2>&1 ; then
	pwd; return 0
    elif findTarget "$1" > /dev/null 2>&1 ; then
	pushd $TARGETFound
    else
	local dir="$(shortdir "$1")"
	if [ -n "$dir" ] && [ -d "$dir" ]; then
	    cd "$dir"; pwd
	else
	    echo "Invalid dir argument: $FUNCNAME"
	    return 1
	fi
    fi
}

# Function: reset_dirstack {{{2
function reset_dirstack()
{
    # popd until DIRSTACK only have $PWD left
    while (( ${#DIRSTACK[@]} > 1 )); do
	popd -n > /dev/null 2>&1
    done
    dirs
}

# Function: postCDList {{{2
# auto list $PWD, can also accept another path as input argument
function postCDList()
{
    local dir=${1:-"$PWD"}
    if [ $AUTOList = "on" ] ; then
	command ls -BhF --color=auto --group-directories-first "$dir"
	# ls "$dir"
    fi
    if [ $AUTOHist = "on" ] ; then
	array_push CDHistory "$dir"
    fi
}

# Function: addTarget {{{2
# addTarget [label=dir label=dir ...]
# If no argument at all, display the front (current or default) target. 
# Otherwise, every label=dir pairs are saved in the associative array of
# Tagets, named TAGdir. But if there is no label or "=", the dir is
# inserted in the front of TARget array. dir can be a real path or
# previous saved target name or index, whitch will be found by findTarget.
# The target from TAGdir array will insert directly. While a target from
# a mid-index of TARget array will rotate to the front. And if the
# inserted dir is the same as the current front target, it won't perform.
# No space around "=", otherwise it's seem as multiple words.
# The $PWD can short as a dot, and if "dir" is omited, use $PWD.
#
# So, these are the application of this function:
# Show the current front target;
# Define named target in accociative array;
# Push a dir into target index array;
# Select a saved target as the front target.
# 
# Special Case:
# a empty string "" argument will reset TARget array.
function addTarget()
{
    local label path arg
    for arg in "$@" ; do
	# empty argument
	if [ -z "$arg" ] ; then 
	    array_empty TARget
	    continue
	fi

	# parse label=dir pairs
	label=${arg%%=*}; path=${arg#*=}
	# no =? it's path only
	if [ "$label" = "$path" ]; then label=""; fi
	if [ "$label" != "${label#*/}" ]; then
	    echo "$FUNCNAME: label can't contain /. ignore $arg"
	    continue
	fi
	if [ -z "$path" ] ; then path="$PWD"; fi
	if [ "$path" = '.' ]; then path="$PWD"; fi

	findTarget "$path"
	if [ -z "$TARGETFound" ]; then continue; fi

	if [ -n "$label" ] ; then
	    TAGdir[$label]=$TARGETFound
	else
	    if [ "$TARGETFound" != "${TARget[0]}" ]; then
		array_delete TARget $TARGETFound
		array_unshift TARget $TARGETFound
	    fi
	fi
    done

    updateTarget
}

# Function: delTarget {{{2
# delTarget [label1 label2 ...]
# shift the TARget array if no argument or 
# delete the labeled element in TAGdir array.
function delTarget()
{
    if (( $# == 0 )); then
	array_shift TARget
	updateTarget
	return 0
    fi

    local label
    for label
    do
	unset TAGdir[$label]
    done
}

# Function: swapTarget {{{2
# swap the first two target dir, no input needed.
function swapTarget()
{
    if (( ${#TARget[@]} >= 2 )); then
	array_swap_front TARget
	updateTarget
    else
	echo "Target dirs less than 2: $FUNCNAME"
	return 1
    fi
}
# Actually "addTarget +1" do the same work, but that routine is complex.

# Function: swapTarPWD {{{2
# sawp the PWD and top of (indexed) target array, and cd to that target.
function swapTarPWD()
{
    local tmp=${TARget[0]}
    if [ -n "$tmp" ] && [ -d "$tmp" ]; then
	cd "$tmp"
	TARget[0]="$OLDPWD"
	updateTarget
	return 0
    else
	echo "Target dir not defined: $FUNCNAME"
	return 1
    fi
}

# Function: updateTarget {{{2
# update the current target dir if $AUTOMirror is set.
function updateTarget()
{
    printTarget
    local target=${TARget[0]}
    if [ -n "$target" ] && [ -d "$target" ]; then
	postCDList "$target"
    fi
}

# Function: printTarget {{{2
# Display the current front target
# TODO: more information of target array
function printTarget()
{
    echo "Target: ${TARget[0]}"
}

# Function: findTarget {{{2
# findTarget dir | +Number | -Number | subscript (just one input)
# Find a target path for the input, the result is saved in $TARGETFound, or
# null if fails. The input can be in the either form below: 
# dir: if input is a dir slef, then $TARGETFound is it's full path
# str: a non-dir string is treat as subscript of TAGdir
# Num: a number is treat as the index of TARget
# +N : index from the left(front), 0 based, and is the default way
# -N : index from the right(end), -1, -2, ...
# +0, -0 is the same meaning, but TARget[0] is the default target in
# most case, there is no need to "findTarget 0"
# Note: the +N/-N/index label can be use as base path, followed by /subdir
function findTarget()
{
    local usage="dir | +Number | -Number | subcript"
    if (( $# != 1 )); then
	echo "Require one argument: $FUNCNAME $usage"
	return 1
    fi
    if [ -z "$1" ] ; then 
	echo "Empty Input argument: $FUNCNAME $usage"
	return 1
    fi

    # reset TARGETFound
    TARGETFound=""
    # try $1 as a literal path
    if [ -n "$1" ] && [ -d "$1" ]; then
	TARGETFound="$(fullpath "$1")" && return
    fi

    # try $1 as a subscript of TAGdir array, fully or header part.
    local dir="" base=${1%%/*} subs=${1#*/}
    # no /? it's base only
    if [ "$subs" = "$base" ]; then subs=""; fi
    # no base before /, absolute path
    if [ -z "$base" ]; then return 1; fi

    if [ -n "${TAGdir[$base]}" ] && [ -d "${TAGdir[$base]}" ]; then
	dir="${TAGdir[$base]}"
	# try $1 as a number index of TARget array
    elif [ -z "${base//[-+0-9]/}" ]; then
	# $1 is -Number or +Number, parse prefix and number
	local prefix=${base//[0-9]}
	if [ -z "$prefix" ]; then prefix='+'; fi
	local number=${base#$prefix}
	if [ -n "${number//[0-9]/}" ]; then
	    # after +/- still has string other than digit
	    echo "Invalid Argument: $FUNCNAME $usage"
	    return 1
	fi

	# calculate true index of TARget array
	local index=""
	if (( $number == 0 )); then
	    let index=0
	elif [ "$prefix" = '+' ]; then
	    let index=$number
	elif [ "$prefix" = '-' ]; then
	    let index=${#TARget[@]}-$number
	else
	    echo "Invalid Argument: $FUNCNAME $usage"
	fi

	dir="${TARget[$index]}"
	if [ -n "$dir" ] && [ -d "$dir" ]; then
	    dir="$dir"
	else
	    echo "Target Not Found: $FUNCNAME $usage"
	    return 1
	fi
    else
	echo "Invalid argument: $FUNCNAME $usage"
	return 1
    fi

    # asign to global 
    if [ -n "$subs" ]; then
	TARGETFound="$dir/$subs"
    else
	TARGETFound="$dir"
    fi
    
    return 0
}

