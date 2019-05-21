#!/bin/bash

export SVACE_HOME="/usr/local/svace-analyzer-2.4-20170901-x64-linux"
export PATH="$SVACE_HOME/bin:$PATH"

PROF="tizen"
PROF="KantM2"
ARCH="armv7l"
PROJ=`basename \`pwd\``
SECOS_DIR=~/Secos/Trustware

case "$PROJ" in
	tef-simulator)
		ARCH="i586"
		PROF="emulator"
		;;
	key-manager-ta)
		ARCH="i586"
		PROF="emulator"
		;;
	KantM2)
		ARCH="armv7l"
		PROF="KantM2"
		;;
esac

if [ -d packaging ]; then

	echo "svace build gbs build -A $ARCH --include-all --overwrite -P $PROF $@"
	svace init
	svace build gbs build -A $ARCH --include-all --overwrite -P $PROF "$@" && svace analyze

elif [ -d trustzone-cmake ]; then

TOOL32HF="/usr/local/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
TOOL32="/usr/local/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64="/usr/local/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
TOOL32v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"

BOARD="artik530"

case "$BOARD" in
	artik530)
		LINUX_DIR="$HOME/Boards/artik530/linux-artik"
		TOOL_CHAINS="--ree-toolchain=${TOOL32HF} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
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
	kant)
		# run svace under gbs
		gbs-build -P "KantM2"
		exit 0
		;;
	*)
		usage "Unsupported board name $BOARD."
		;;
esac
OUTPUT_DIR="$SECOS_DIR/build-$BOARD/out"
	rm -rf ${OUTPUT_DIR}
	mkdir -p ${OUTPUT_DIR}
	cd ${OUTPUT_DIR}
	$SECOS_DIR/trustzone-cmake/configure --board=${BOARD} --linux-dir=${LINUX_DIR} ${TOOL_CHAINS}
	svace init
	svace build make -j4 "$@" && svace analyze
else
	echo "nothing to do in this dir"
fi
