#! /bin/bash
##
# filename: ypmd.sh
# descript: file operation function for shcmd, yank, copy, move, delete
# create-t: 2012-01-03
# author-e: lymslive@sina.com
##

# Function: addYank {{{2
# addYank [-adxsDcf] [path1 path2 ...]
# Options:
# -a: add path to yank-list
# -d: delete path from yank-list
# -x: delete or add (xor) path to yank-list
# -s: replace the old yank-list, imply -a option
# -c: check the validation of path in yank-list (may slow)
# -f: add path from file(or stdin) that contain a filename each line
#     must in the last option, ignore other path in cmdline
#     can use addYank -f < filename, but command | addYank -f don't work.
# Note: 
# convert to fullpath simplly add $PWD/ if path not begin with /
# can use -c to check more if necessary.
function addYank()
{
    # options parsion
    local usage="[-adxsDcf] [path1 path2 ...]"
    local addmode="add" needcheck readfile

    local opt optind_old=$OPTIND
    OPTIND=1
    while getopts ":adxscf" opt; do
	case $opt in
             a ) addmode="add" ;;
             d ) addmode="del" ;;
             x ) addmode="xor" ;;
             s ) emptyYank; addmode="add" ;;
             c ) needcheck="on" ;;
             f ) readfile="on"; break ;;
             \?) echo "Invalid options: $FUNCNAME $usage"; return 1 ;;
	esac
    done
    shift $(($OPTIND - 1))
    OPTIND=$optind_old

    local -a Files
    # read file-list from extenal file or stdin, or from cmdline directlly
    if [ "$readfile" = 'on' ]; then
	if [ -z "$1" ] ; then
	    readarray -t Files 
	else
	    if [ -r "$1" ]; then
		readarray -t Files < "$1"
	    else
		echo "$FUNCNAME: the input file isn't readable: $1" 1>&2
		return 1
	    fi
	fi
    else
	Files=("$@")
    fi

    # add each file to YANKFile
    local file
    for file in "${Files[@]}"; do
	[ -z "$file" ] && echo "$FUNCNAME: ignore empty filename" 1>&2 && continue
	# remove flag at the end of filename from ls output
	file=${file%[/=@>|*]}
	! [ -e "$file" ] && echo "$FUNCNAME: ignore non-exist file($file)" 1>&2 && continue
	[ "${file:0:1}" = '/' ] || file="$PWD/$file" # simple fullpath
	case $addmode in
	    add) array_push YANKFile "$file" ;;
	    del) array_delete YANKFile "$file" ;;
	    xor) array_delete YANKFile "$file" || array_push YANKFile "$file" ;;
	esac
    done

    [ "$needcheck" = 'on' ] && checkYank
    printYank
}

# Function: delYank_idx {{{2
# delYank_idx [index] [first-last] ...
# delete YANKFile entry by number index, or index range
# index firstly from 1 as printed by printYank function
# either first- or -last can be omitted, default 1-end
function delYank_idx()
{
    local length_old=${#YANKFile[@]}

    local arg first last index real_index
    for arg in "$@"; do
	[ -z "$arg" ] && echo "$FUNCNAME: ignore empty argument" 1>&2 && continue
	[ -n "${arg//[-0-9]/}" ] && echo "$FUNCNAME: not numeric index, $arg" 1>&2 && continue
	first=${arg%%-*}; last=${arg##*-}
	first=${first:=1}; last=${last:=$length_old}
	for (( index = $first; index <= $last; index++ )); do
	    let real_index=$index-1
	    (( $real_index < 0 )) && echo "$FUNCNAME: invalid index" 1>&2 && continue
	    unset YANKFile[$real_index]
	done
    done

    local length_new=${#YANKFile[@]}
    [ "$length_new" != "$length_old" ] && YANKFile=("${YANKFile[@]}")
    printYank
}

# Function: delYank {{{2
# delYank [path | index]
# delete yank-list entry by path or by index, determined from the $1
# specail empty input or only-one-empty-string input is handled as yyyYank
function delYank()
{
    # specail case, as addYank
    if (( $# == 0 )); then
	emptyYank; printYank; return
    fi

    if [ -n "$1" ] && [ -z "${1//[-0-9]}" ]; then
	delYank_idx "$@"
    else
	addYank -d "$@"
    fi
}

# Function: yyyYank {{{2
# a wraper function for addYank, used for alias y yyyYank
# Special argument:
# yyyYank: <No Input> do nothing, only show the current yank-list
# yyyYank "": <A Empty String>, emtpy the old yank-list array
# yyyYank . : < A single dot>, really not special, yank $PWD
# yyyYank +filename: addYank -sf filename
# yyyYank ++filename: addYank -af filename
# no space between + and filename, and you filename shouldn't begin with +
# filename can ignore and read from stdin
function yyyYank()
{
    # specail case
    if (( $# == 0 )); then
	printYank; return
    elif (( $# == 1 )) ; then
	if [ -z "$1" ]; then
	    emptyYank; printYank; return
	elif [ "$1" = '.' ]; then
	    YANKFile=("$PWD/."); printYank; return
	elif [ "${1:0:1}" = '+' ]; then
	    if [ "${1:0:2}" = '++' ]; then
		addYank -af "${1:2}"; return
	    else
		addYank -sf "${1:1}"; return
	    fi
	fi
    fi
    addYank "$@"
}

# Function: checkYank {{{2
function checkYank()
{
    echo "$FUNCNAME: not available now" 1>&2
    # TODO:
}

# Function: emptyYank {{{2
function emptyYank()
{
    YANKFile=()
}

# Function: printYank {{{2
# Display the yanked file list
# 1st line: Yanked N files
# 2nd line: and later, one file each line, and left numbered using tab
# seperator.
function printYank()
{
    echo "Yanked: ${#YANKFile[@]} Files"
    local i j
    for (( i=0; $i<${#YANKFile[@]}; i++ )); do
	let j=$i+1
	printf "%d\t%s\n" $j ${YANKFile[$i]}
    done
    # array_display "YANKFile" "\n" "\t"
}

# Function: Copy {{{2
# Copy [target] [args...]
# copy a list of files(folders) to another directory(without renameing)
# If no input at all, copy yanked files to the latest marked target dir.
# A single argument is treat as the target dir.
# If more than 2 arguments, invoke the oringin cp command.
# reference: cp [OPTION]... -t DIRECTORY SOURCE...
# Copy use the option '-riv' in command cp
function Copy()
{
    local target
    if (( $# == 1 )); then
	target="$1"
    elif (( $# >= 2 )); then
	command cp "$@"
	return 0
    else
	target="${TARget[0]}"
    fi

    if [ -z "$target" ] || (( ${#YANKFile[@]} == 0 ))
    then
	echo "$FUNCNAME: Not enough source file or target dir"
	return 1
    fi
    command cp -riv -t "$target" "${YANKFile[@]}"
}

# Function: Link {{{2
# Similar as Copy but make symbol link
# ln [OPTION]... -t DIRECTORY TARGET...  (4th form)
# use -s option, Link only creat symbol link, not low-level hard link
# Note the "TARGET" term's meaning in `man ln` is converse as that in cp
function Link()
{
    local target
    if (( $# == 1 )); then
	target="$1"
    elif (( $# >= 2 )); then
	command ln "$@"
	return 0
    else
	target="${TARget[0]}"
    fi

    if [ -z "$target" ] || (( ${#YANKFile[@]} == 0 ))
    then
	echo "$FUNCNAME: Not enough source file or target dir"
	return 1
    fi
    command ln -siv -t $target "${YANKFile[@]}"
}

# Function: Move {{{2
# Similar as Copy, but delete the source file, move target without renaming
# mv [OPTION]... -t DIRECTORY SOURCE... ( use iv option)
function Move()
{
    local target
    if (( $# == 1 )); then
	target="$1"
    elif (( $# >= 2 )); then
	command mv "$@"
	return 0
    else
	target="${TARget[0]}"
    fi

    if [ -z "$target" ] || (( ${#YANKFile[@]} == 0 ))
    then
	echo "$FUNCNAME: Not enough source file or target dir"
	return 1
    fi
    command mv -iv -t $target "${YANKFile[@]}"
}

# Function: Delete {{{2
# Similar as rm, but default rm YANKFile if no arguments
# Option: -r, as rm needs.
# default use '-Iv' option, you may need add '-r' manaully to recursively
# remove non-empty directory item.
# Argement: if any, delete the input files, if none, delete files in yanked.
function Delete()
{
    local opt="Iv"
    if [ -n "$1" ] && [ "$1" = "-r" ]; then
	opt="rIv"
	shift
    fi

    local files
    if (( $# >= 1 )); then
	files="$@"
    else
	files="${YANKFile[@]}"
    fi
    command rm -$opt $files
}

# Function: Backup {{{2
function Backup()
{
    local files
    if (( $# >= 1 )); then
	files="$@"
    else
	files="${YANKFile[@]}"
    fi

    [ -d '.bak' ] || mkdir .bak || { echo "$FUNCNAME: can't creat .bak/" 1>&2; return; }
    command cp -riv -t .bak "${YANKFile[@]}"
}
