#!/bin/bash
if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

ARGS=()

if [ $# -gt 0 -a -d "$1" ]; then
   DIR+=( "$1" ); shift
else
   DIR+=( "." )
fi

lastop=
function addcond() {
   local op=$1; shift
   if [ -z "$lastop" ]; then
      ARGS+=("$@")
      lastop=$op
      return
   fi
   if [ "$op" == "$lastop" ]; then
      ARGS+=("$op" "$@")
   else
      ARGS=("(" "${ARGS[@]}" ")" "$op" "$@")
      lastop=$op
   fi
}

addcond "-a" "-path" "*/.*" "-prune"
addcond "-a" "-not" "-name" ".*"

while [ $# -gt 0 ]; do
   a="$1"; shift
   case "$a" in
      -ex)
         addcond "-o" "-path" "$1" "-prune"
         shift
         ;;
      -n)
         addcond "-o" "-name" "$1"
         shift
         ;;
      -*)
         ARGS+=( "$a" )
         ;;
      *)
         addcond "-o" "-iname" "$a"
         ;;
   esac
done

ARGS=( "-L" "$DIR" "${ARGS[@]}" )  # follow symlinks

rm -f /tmp/find-err.log
echo find "${ARGS[@]}" > /dev/stderr
find "${ARGS[@]}" 2> /tmp/find-err.log
if [ -f /tmp/find-err.log ]; then
   cat /tmp/find-err.log > /dev/stderr
fi
