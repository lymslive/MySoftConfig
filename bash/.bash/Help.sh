#! /bin/bash
##
# search help man info in order, if the previous command fails
##

{
    help $@ || man $@ || infor $@
} 2>/dev/null
