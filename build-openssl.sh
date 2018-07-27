#!/bin/bash

TOOL32HF="/usr/local/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
TOOL32="/usr/local/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64="/usr/local/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
TOOL32v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"

BOARD=
ARCH=

while [ $# -gt 0 ]; do
	case "$1" in
		-c) DO_BUILD=false;;
		-b) BOARD=$2;shift;;
		-t) BUILD_TYPE=$2;shift;;
		*)  if [ -z "$BOARD" ]; then
			BOARD=$1; shift
			fi
			break;;
	esac
	shift
done

function usage() {
	[ -n "$@" ] && echo "$@"
	echo "Supported boards: artik530, artik7/artik710, artik711"
	exit 1
}

if [ -z "$BOARD" ]; then
	usage "Board name not given."
fi

CFLAGS=" -Wunused-function -Wunused-label -Wunused-value -Wunused-variable -Wuninitialized"
case "$BOARD" in
	artik530)
		ARCH="arm"
		CROSS_COMPILE="$TOOL32HF"
		CFLAGS="${CFLAGS} -march=armv7-a -mcpu=cortex-a9 -marm"
		;;
	artik711)
		ARCH="arm64"
		CROSS_COMPILE="$TOOL64"
		;;
	*) usage "Unsupported board name $BOARD.";;
esac

BUILD_DIR="build-$BOARD"

export AS="${CROSS_COMPILE}as"
export AR="${CROSS_COMPILE}ar"
export CC="${CROSS_COMPILE}gcc$CFLAGS"
export CPP="${CROSS_COMPILE}gcc -E"
export CXX="${CROSS_COMPILE}g++"
export LD="${CROSS_COMPILE}ld"
export RANLIB="${CROSS_COMPILE}ranlib"
export NM="${CROSS_COMPILE}nm"
export STRIP="${CROSS_COMPILE}strip"
export OBJCOPY="${CROSS_COMPILE}objcopy"
export OBJDUMP="${CROSS_COMPILE}objdump"

if [ ! -f ./Configure ]; then
	usage "./Configure not found"
fi

if [ $ARCH = "arm" ]; then
	./Configure linux-generic32 shared -DL_ENDIAN --prefix=/tmp/openssl --openssldir=/tmp/openssl
elif [ $ARCH = "arm64" ]; then
	./Configure linux-generic64 shared -DL_ENDIAN --prefix=/tmp/openssl --openssldir=/tmp/openssl
else
	usage "wrong ARCH=$ARCH"
fi

rm -rf $BUILD_DIR
mkdir $BUILD_DIR
make clean
make -j4
make -C apps

echo "compiled using ${CC}"

cp ./apps/openssl $BUILD_DIR
