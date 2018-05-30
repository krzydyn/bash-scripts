#!/bin/bash

TOOL32HF="/usr/local/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
TOOL32="/usr/local/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64="/usr/local/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
TOOL32v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"

SECOS_DIR=`pwd`
#BUILD_TYPE="release"
#BUILD_TYPE="relwithdebinfo"
BUILD_TYPE="debug"
DO_BUILD=true

while [ $# -ge 0 ]; do
	case "$1" in
		-c) DO_BUILD=false;;
		-b) BOARD=$2;shift;;
		-t) BUILD_TYPE=$2;shift;;
		*)	if [ -z "$BOARD" ]; then
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

OUTPUT_DIR="$SECOS_DIR/build-$BOARD/out"

case "$BOARD" in
	artik530)
		LINUX_DIR="VolGroup02/Arch/artik530/linux-artik"
		TOOL_CHAINS="--ree-toolchain=${TOOL32HF} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		#LINUX_DIR="$HOME/sec-os-artik530/linux-4.4.71"
		#TOOL_CHAINS="--ree-toolchain=${TOOL32} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		;;
	artik7|artik710)
		LINUX_DIR="$HOME/sec-os-artik710/linux-artik"
		TOOL_CHAINS="--ree-user-toolchain=${TOOL64} --ree-kernel-toolchain=${TOOL64} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		BOARD="artik7"
		;;
	artik711)
		LINUX_DIR="$HOME/sec-os-artik711/artik_files/build_env/linux-artik"
		TOOL_CHAINS="--ree-user-toolchain=${TOOL64} --ree-kernel-toolchain=${TOOL64} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		BOARD="artik7"
		;;
	artik7_64)
		LINUX_DIR="$HOME/sec-os-artik710/linux-artik"
		TOOL_CHAINS="--all-toolchain=${TOOL64v5} ----compat-toolchain=${TOOL32v5}"
		;;
	*)
		usage "Unsupported board name $BOARD."
		;;
esac
#TODO add configure option
# TOOL_CHAINS+=" --socket-api"

if [ ! -f $SECOS_DIR/trustzone-cmake/configure ]; then
	 usage "trustzone-cmake/configure not found"
fi

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

cd ${OUTPUT_DIR} && $SECOS_DIR/trustzone-cmake/configure --board=${BOARD} --linux-dir=${LINUX_DIR} --build-type=${BUILD_TYPE} ${TOOL_CHAINS}
if $DO_BUILD; then
	cd ${OUTPUT_DIR} && make -j4
fi
