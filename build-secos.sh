#!/bin/bash
#. "$HOME/bin/.functions.inc"

TOOL32HF="/usr/local/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
TOOL32="/usr/local/gcc-linaro-4.9-2015.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64="/usr/local/gcc-linaro-4.9-2015.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
TOOL32v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
TOOL64v5="/usr/local/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"

TOOL32HFv6="/usr/local/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"
TOOL32v6="/usr/local/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"

SECOS_DIR=`pwd`
BUILD_TYPE="release"
#BUILD_TYPE="relwithdebinfo"
BUILD_TYPE="debug"
DO_BUILD=true
BUILD_OPT=""

while [ $# -gt 0 ]; do
	case "$1" in
		-c) DO_BUILD=false;;
		-b) BOARD=$2;shift;;
		-t) BUILD_TYPE="$2";shift;;
		-B) BUILD_OPT="$1";;
		-rfs) BUILD_OPT=rfs-build;;
		-ree) BUILD_OPT=app-ree-build;;
		*)	if [ -z "$BOARD" ]; then
				BOARD=$1; shift
			fi
			break;;
	esac
	shift
done

function usage() {
	[ -n "$@" ] && echo "$@"
	echo "Supported boards: artik530, artik7/artik710, artik711, KantM, KantM2"
	exit 1
}

if [ -z "$BOARD" ]; then
	usage "Board name not given."
fi

OUTPUT_DIR="$SECOS_DIR/build-$BOARD/out"
CONFIGURE_SCRIPT="$SECOS_DIR/trustzone-cmake/configure"

case "$BOARD" in
	artik530)
		LINUX_DIR="/VolGroup02/Arch/artik530/linux-artik"
		TOOL_CHAINS="--ree-toolchain=${TOOL32HF} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		#LINUX_DIR="$HOME/sec-os-artik530/linux-4.4.71"
		#TOOL_CHAINS="--ree-toolchain=${TOOL32} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		;;
	artik7|artik710)
		LINUX_DIR="$HOME/sec-os-artik710/linux-artik"
		TOOL_CHAINS="--ree-user-toolchain=${TOOL64v5} --ree-kernel-toolchain=${TOOL64v5} --user-toolchain=${TOOL32v5} --kernel-toolchain=${TOOL32v5}"
		BOARD="artik7"
		;;
	artik711)
		LINUX_DIR="/VolGroup02/Arch/artik711/linux-artik"
		#TOOL_CHAINS="--ree-user-toolchain=${TOOL64} --ree-kernel-toolchain=${TOOL64} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		TOOL_CHAINS="--ree-toolchain=${TOOL64} --user-toolchain=${TOOL32v5} --kernel-toolchain=${TOOL32v5}"
		# below is 32-bit userspace (need 32-bit linux rootfs)
		#TOOL_CHAINS="--ree-user-toolchain=${TOOL32} --ree-kernel-toolchain=${TOOL64} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		BOARD="artik7"
		;;
	artik7_64)
		LINUX_DIR="$HOME/sec-os-artik710/linux-artik"
		TOOL_CHAINS="--all-toolchain=${TOOL64v5} --compat-toolchain=${TOOL32v5}"
		;;
	KantM)
		LINUX_DIR="/VolGroup02/Arch/linux-vd/linux-4.1.10"
		TOOL_CHAINS="--ree-toolchain=${TOOL32HF} --user-toolchain=${TOOL32} --kernel-toolchain=${TOOL32}"
		CONFIGURE_SCRIPT="$SECOS_DIR/trustzone-tee/trustzone-cmake/configure"
		BOARD="kantm"
		;;
	KantM2)
		LINUX_DIR="/VolGroup02/Arch/linux-vd/linux-4.1.10"
		TOOL_CHAINS="--ree-toolchain=${TOOL32v6} --user-toolchain=${TOOL32v6} --kernel-toolchain=${TOOL32v6}"
		CONFIGURE_SCRIPT="$SECOS_DIR/trustzone-tee/trustzone-cmake/configure"
		BOARD="kantm2"
		export TEE_SYSROOT="$PWD/build-kantM2/out/app-tee-build"
		#export TOOLCHAIN_PREFIX="${TOOL32HFv6}"
		;;
	*)
		usage "Unsupported board name $BOARD."
		;;
esac
#TODO add configure option
# TOOL_CHAINS+=" --socket-api"

if [ ! -f "$CONFIGURE_SCRIPT" ]; then
	 usage "Script not found: $CONFIGURE_SCRIPT"
fi

if [ ! -d ${LINUX_DIR} ]; then
	 usage "wrong linux dir"
fi

#rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

cd ${OUTPUT_DIR}

#showargs $CONFIGURE_SCRIPT --board=${BOARD} --linux-dir=${LINUX_DIR} --build-type=${BUILD_TYPE} ${TOOL_CHAINS}
$CONFIGURE_SCRIPT --board=${BOARD} --linux-dir=${LINUX_DIR} --build-type=${BUILD_TYPE} ${TOOL_CHAINS}

if $DO_BUILD; then
	make -j1 ${BUILD_OPT} 
fi
echo "Finished at `date`"
