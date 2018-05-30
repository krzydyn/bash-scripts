PREFIX32="/usr/local/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-"
PREFIX64="/usr/local/gcc-linaro-5.3-2016.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
PREFIX32_HF="arm-linux-gnueabihf-"


make ARCH=arm64 distclean
make ARCH=arm64 CROSS_COMPILE=$PREFIX64 artik710_raptor_defconfig
make ARCH=arm64 CROSS_COMPILE=$PREFIX64 Image -j4
