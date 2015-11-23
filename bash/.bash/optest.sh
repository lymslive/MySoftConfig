#! /bin/bash
# getopts test

while getopts ":y:tTaAr" opt; do
    case $opt in
	 y ) echo y OPTARG=$OPTARG opt=$opt ;;
         t ) echo t ;;
         T ) echo T ;;
         \?) echo "Invalid options: OPTARG=$OPTARG opt=$opt"; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))
