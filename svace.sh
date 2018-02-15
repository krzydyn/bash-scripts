#!/bin/bash

export SVACE_HOME=~/SVACE/svace-analyzer-2.4-20170901-x64-linux
export PATH="$SVACE_HOME/bin:$PATH"

PROF="tizen"
ARCH="armv7l"
PROJ=`basename \`pwd\``

case "$PROJ" in
	tef-simulator)
		ARCH="i586"
		PROF="emulator"
		;;
	key-manager-ta)
		ARCH="i586"
		PROF="emulator"
		;;
esac

echo "svace build gbs build -A $ARCH --include-all --overwrite -P $PROF $@"
svace init
svace build gbs build -A $ARCH --include-all --overwrite -P $PROF "$@" && svace analyze
