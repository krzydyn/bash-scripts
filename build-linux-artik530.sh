PREFIX32_HF="/usr/local/gcc-linaro-4.9-2014.11-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"

if [ -f ./build.sh ]; then
./build.sh -b artik530_raptor
else
make ARCH=arm distclean
make ARCH=arm CROSS_COMPILE=$PREFIX32_HF artik530_raptor_defconfig
make ARCH=arm CROSS_COMPILE=$PREFIX32_HF zImage -j4
fi
