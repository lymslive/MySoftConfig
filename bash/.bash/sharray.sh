#! /bin/bash
##
# filename: array_operate.sh
# descript: basic array operation for stack an queue, such as pop, push, (un)shift
#           which can accept an array nema as the first argument
# reference: http://www.tech-recipes.com/rx/911/queue-and-stack-using-array/
# author: lymslive@sina.com
# creat: 2011-12-25
#
# All of these function requre an array_name string as the first argument.
# The array variable represent by the array_name should avilable (shared) both
# whithin the function and the caller, such as global variables.
# The second argument (if requred) is the element or index to be operated on,
# only one with each calling function. In case of multiple elements, for
# example pushing more elements from another array, you may need write a loop
# in the caller function.
#
# Function Summary:
# array_push array_name new_element
# array_pop array_name
# array_shift array_name
# array_unshift array_name new_element
# array_delete array_name del_element
# array_delby_index array_name del_index
# array_empty array_name [first_index]
##

# Push {{{2
# array=(”${array[@]}” $new_element)
# requre two args: array_name and new_element, which insert in the end
function array_push()
{
    if [ $# -ne 2 ]; then
        echo Argument number error: $0 array_name new_element
        return 1
    fi
    local array=$1
    local new_element=$2
    # eval "$array=(\"\${$array[@]}\" \$new_element)"
    eval "$array[\${#$array[@]}]=\$new_element"
}

# Pop {{{2
# array=(${array[@]:0:$((${#array[@]}-1))})
# requre one args: array_name, the last element is removed
function array_pop()
{
    if [ $# -ne 1 ]; then
        echo Argument number error: $0 array_name
        return 1
    fi
    local array=$1
    # eval "$array=(\${$array[@]:0:\$((\${#$array[@]}-1))})"
    eval "unset $array[\$((\${#$array[@]}-1))]"
}

# Shift {{{2
# array=(${array[@]:1})
# requre one args: array_name, the first element is removed
# Note: unset array[0] won't work, only set array[0] null, but others'
# position don't changed.
function array_shift()
{
    if [ $# -ne 1 ]; then
        echo Argument number error: $0 array_name
        return 1
    fi
    local array=$1
    eval "$array=(\${$array[@]:1})"
}

# Unshift {{{2
# array=($new_element “${array[@]}”)
# requre two args: array_name and new_element, which insert in the begin.
function array_unshift()
{
    if [ $# -ne 2 ]; then
        echo Argument number error: $0 array_name new_element
        return 1
    fi
    local array=$1
    local new_element=$2
    eval "$array=(\$new_element \"\${$array[@]}\")"
}
# SwapFront {{{2
# Swap the Front tow elements in array
# requre one arg: array_name
function array_swap_front()
{
    if [ $# -ne 1 ]; then
	echo Argument number error: $0 array_name
	return 1
    fi
    local array=$1
    local length
    eval "length=\${#$array[@]}"
    if (( $length < 2 )) ; then
	echo $array has element less than 2
	return 1
    fi

    local tmp
    eval "tmp=\${$array[0]}"
    eval "$array[0]=\${$array[1]}"
    eval "$array[1]=\$tmp"
}

# Delete by element {{{2
# requre two args: array_name element, what to be deleted 
# note: only delete the first element found
function array_delete()
{
    if [ $# -ne 2 ]; then
        echo Argument number error: $0 array_name del_element
        return 1
    fi

    local array=$1
    local del_element=$2
    local i
    local the_element
    local array_length

    eval "array_length=\${#$array[@]}"
    for (( i = 0 ; i < $array_length ; i++ ))
    do
        eval "the_element=\${$array[$i]}"
        if [ "$del_element" = "$the_element" ]; then
            break
        fi
    done
    
    if (( i < $array_length )); then
        array_delby_index $array $i
    else
	return 1
    fi
}

# Delete by index {{{2
# requre two args: array_name index, where to be deleted
function array_delby_index()
{
    if [ $# -ne 2 ]; then
        echo Argument number error: $0 array_name del_index
        return 1
    fi

    local array=$1
    local index=$2
    # array=(${array[@]:0:$1} ${array[@]:$(($1 + 1))})
    eval "$array=(\${$array[@]:0:$index} \${$array[@]:$(($index + 1))})"
}

# Empty {{{2
# requre two args: array_name first_index(default 0)
# from the first_index to the end will be deleted
function array_empty()
{
    if [ $# -lt 1 ]; then
        echo Argument number error: $0 array_name [first_index]
        return 1
    fi

    local array=$1
    local first_index=${2:-0}
    local array_length
    local i

    eval "array_length=\${#$array[@]}"
    for (( i = $first_index ; i < $array_length ; i++ ))
    do
        eval "unset $array[$i]"
    done
}

# TODO: {{{2
# array_empty() and array_delby_index maybe rewrite to one function
# array_clear arrayname first_index del_number
# which default clear from index 0 to the end
# set del_number to 1 is working as array_delby_index above
# what about the effective between "for unset" and "partial array
# reassignment"?

# Display {{{2
# array_display array_name [elesep subsep]
# print the content in array (index array or accociative array)
# $2 elesep : the seprator of element, default a space.
# $3 subsep : the seprator of index and value, default null(don't print index)
# use "\n" as $2 input, to print every element line by line
function array_display()
{
    if [ $# -lt 1 ]; then
	echo Argument number error: $0 array_name [elesep subsep]
	return 1
    fi

    local array=$1 elesep=${2:-" "}  subsep=$3
    local index index_list element
    eval "index_list=\${!$array[@]}"
    if (( ${#index_list[@]} == 0 )); then return 1; fi

    for index in $index_list ; do
	eval "element=\${$array[$index]}"
	if [ -n $subsep ] ; then
	    element="${index}${subsep}${element}"
	fi
	echo -ne "${element}${elesep}"
    done
    # add a newline at the end of diaplay
    echo ""
}
