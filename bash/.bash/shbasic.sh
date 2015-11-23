#! /bin/bash
##
# filename: shbasic.sh
# descript: some helper functions for shcmd.sh
# create-t: 2012-01-03
# author-e: lymslive@sina.com
##

# Global varialbe, in half upercase form.
# global variable for get_fullpath
FULLPath=""
# Target dir, define index array and associative array
declare -a TARget
declare -A TAGdir
# global variable for findTarget
TARGETFound=""
TARGETDefault=~/tmp
# variable control whether auto-list or addto cdhistory when cd into a dir.
# only effect Goto(g) command. Value: "on" or "off"
AUTOList="on"
AUTOHist="off"
# Goto history, index array
declare -a GOTOHist
# The source files(folders) list, index array
declare -a YANKFile

# Function: shcmd_start {{{2
function shcmd_start()
{
    TARget[0]="$TARGETDefault"
}

# Function Listor {{{2
# list somethine or anything
# If no argument at all, it's as short for ls.
# option to specify what track array to list
# -t, -T: target, number indexed or string lebeled array
# -g: list DIRSTACK as dirs, since g(Goto) mainly use pushd
# -G: list GOTOHist, include pushd and normal cd track
# -v: list vertically, one element each line
function Listor()
{
    if (( $# == 0 )) ; then
	command l; return 0
    fi

    # array to be list
    local array
    # seperator between element, and within subscipt and value
    local elesep=":" subsep="="

    local opt optind_old=$OPTIND
    OPTIND=1
    while getopts ":tTgGyYv" opt; do
	case $opt in
             t ) array="$array TARget" ;;
             T ) array="$array TAGdir" ;;
             g ) array="$array DIRSTACK" ;;
             G ) array="$array GOTOHist" ;;
             y ) array="$array YANKFile" ;;
             Y ) array="$array YANKFile"; elesep="\n" ;;
             v ) elesep="\n" ;;
             \?) echo Invalid options: $FUNCNAME [-tThHgGyYv] 
		return 1 ;;
	esac
    done
    shift $(($OPTIND - 1))
    OPTIND=$optind_old

    # if still has any other than options, call the ls command.
    if (( $# >= 1 )); then
	command l $@; return 0
    fi

    local one
    array=${array#* } # delete the leading space
    for one in $array ; do
	echo "${one}>"
	array_display "$one" "$elesep" "$subsep"
    done
}

# Function viewAlias {{{2
# viewAlias [header-char]
# display ailases started with specific string
# if no input, display all alias in less
function viewAlias()
{
    if [ -n "$1" ]; then
	alias | grep "^alias $1"
    else
	alias | sort | less
    fi
}
#
