#! /bin/bash
##
# filename: shcmd.sh
# descript: file management utilities for bash
# create-t: 2012-01-03
# main script port, please source this file in .bashrc
# this file itself only source other components.
##

SHCMDDir=~/.bash

source $SHCMDDir/sharray.sh
source $SHCMDDir/shbasic.sh
source $SHCMDDir/gtcd.sh
source $SHCMDDir/ypmd.sh

shcmd_start
