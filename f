#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

SEARCHDIR=""

ARGS=()
OPTS=()
inc=false

while [ $# -gt 0 ]; do
    a="$1"; shift
	case "$a" in
	-*) #echo "opt '$a'" >&2
        if [ -z "$SEARCHDIR" ]; then
            SEARCHDIR="."
        fi
        if [ $a == "-mk" ]; then
			OPTS+=("-iname" "[Mm]akefile")
        elif [ $a == "-img" ]; then
			OPTS+=("-iname" "*.jpg")
			OPTS+=("-o -iname" "*.png")
			OPTS+=("-o -iname" "*.gif")
		else
        	OPTS+=("${ARGS[@]}");
        	ARGS=();
        	OPTS+=("$a");
		fi
		;;
	*) #echo "arg '$a'" >&2
        if [ -z "$SEARCHDIR" -a -d "$a" ]; then
            SEARCHDIR="$a"
		else
		    ARGS+=("-iname" "$a")
        fi
		;;
	esac
done

if [ -z "$SEARCHDIR" ]; then
    SEARCHDIR="."
fi

OPTS+=("-not" "-path" "./GBS-ROOT/*" )
echo "find $SEARCHDIR" "${OPTS[@]}" "${ARGS[@]}" >&2
find "$SEARCHDIR" "${OPTS[@]}" "${ARGS[@]}" 2>/dev/null
