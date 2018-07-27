#!/bin/bash

SCRIPT=`basename $0`

function usage() {
	if [ $# -gt 0 ]; then
		echo "$@"
	fi
	echo "usage $SCRIPT board_name [secos tzdev twts]"
	exit 1
}

while [ $# -ge 0 ]; do
	case "$1" in
		-b) BOARD=$2;shift;;
		*)	if [ -z "$BOARD" ]; then
				BOARD=$1; shift
			fi
			break;;
	esac
done

if [ -z "$BOARD" ]; then
	usage "Board name not given."
fi

PARTMAP=
LOADER_IMG=
SECOS_IMG=
TARTGET_IP=

case "$BOARD" in
	artik530)
		TARTGET_IP=172.16.0.66
		PARTMAP="artik530s_20180416_fuse/partmap_emmc.txt"
		LOADER_IMG="artik530s_20180416_fuse/loader-emmc.img"
		SECOS_IMG="result-artik530_raptor/secureos.img"
		SECOS_PART="secure"
		#fastboot flash secure secureos-leszek.img
		TLS_BIN_DIR=/VolGroup02/Arch/socket-DS/tls_test_server
		;;
	artik711)
		TARTGET_IP=10.42.0.2
		#PARTMAP="tools-artik7/partmap/partmap_artik711s_emmc.txt"
		#LOADER_IMG="boot-firmwares-artik711s/fip-loader-emmc.img"
		SECOS_IMG="result-artik711s_raptor/fip-secure.img"
		SECOS_PART="fip-secure"
		TLS_BIN_DIR=/VolGroup02/Arch/socket-DS/tls_test_server64
		;;
	*)
		usage "Unsupported board name $BOARD."
		;;
esac

SECOS_DIR=$HOME/Secos/Trustware/build-$BOARD
SECOS_SOCKETAPI_DIR=$SECOS_DIR/out/app-ree-build/trustzone-application/test_socketapi

function install_secos() {
if [ ! -f ./sign_secos.sh ]; then
	echo "./sign_secos.sh not found"
	exit 1
fi
type -p fastboot > /dev/null || usage "fastboot not installed"
./sign_secos.sh
rc=$?
if [ $rc -ne 0 ]; then
	echo "./sign_secos.sh rc=$rc"
	exit
fi
[ -n "$PARTMAP" ] && sudo fastboot flash partmap "$PARTMAP"
[ -n "$LOADER_IMG" ] && sudo fastboot flash loader "$LOADER_IMG"
sudo fastboot flash "$SECOS_PART" "$SECOS_IMG"

sleep 0.5;fastboot reboot

echo "============================"
echo "ifconfig eth0 172.16.0.66 up"
echo "============================"
}

USER_ARCH=
if file $SECOS_DIR/out/ree-install/bin/tzdaemon | grep "32-bit" > /dev/null; then
	USER_ARCH=arm
else
	USER_ARCH=aarch64
fi

function install_tzdev() {
echo "preparing tzdev files..."
mkdir -p install/root install/lib install/usr/modules install/usr/apps/tee install/bin
cp $SECOS_DIR/out/ree-install/modules/tzdev.ko install/usr/modules || exit 1
cp $SECOS_DIR/out/ree-install/bin/* install/bin/ || exit 1
cp $SECOS_DIR/out/ree-install/lib/lib*.so install/lib/ || exit 1
cp -r $SECOS_DIR/out/app-ree-install/usr/apps/* install/usr/apps/
cp -r $SECOS_DIR/out/app-tee-install/usr/apps/tee/* install/usr/apps/tee/
cp -r $SECOS_DIR/out/app-ree-install/usr/local install/usr/
chmod +x install/usr/apps/*
cat > install/root/ifup.sh <<EOF
ifconfig eth0 172.16.0.66 up
EOF
chmod +x install/root/ifup.sh
cat > install/root/tzdev.sh <<EOF
insmod -f /usr/modules/tzdev.ko
EOF
chmod +x install/root/tzdev.sh
cat > install/root/run.sh <<EOF
insmod -f /usr/modules/tzdev.ko
sleep 1
/bin/tzdaemon
EOF
chmod +x install/root/run.sh
}

function install_twts() {
echo "preparing twts files..."
mkdir -p install/usr/apps install/lib install/usr/local/ssl/bin/

if  [ -d "$SECOS_SOCKETAPI_DIR" ]; then

cp $SECOS_DIR/out/app-ree-install/lib/lib*.so install/usr/lib/
cp -r $SECOS_DIR/out/app-ree-install/usr/local install/usr/
cp $SECOS_DIR/out/app-ree-install/usr/apps/* install/usr/apps/

else

CERT_DIR=/VolGroup02/Arch/socket-DS/tls_test_server/openssl_cert_files
cp -r twts/dist/usr/apps/ install/usr/
cp -r twts/tw_test_suite/lib/tf/* install/lib/
cp -r twts/tw_test_suite/lib/solution/* install/lib/

cp -r $CERT_DIR/* install/usr/local/ssl/bin/
cp $TLS_BIN_DIR/openssl install/usr/local/ssl/bin/
cp $TLS_BIN_DIR/tls_server install/usr/apps/
cp $TLS_BIN_DIR/echo_server_* install/usr/apps/
fi
echo "Installing ARCH = $USER_ARCH"
chmod 0755 install/usr/apps/*
chmod 0644 install/usr/local/ssl/bin/*
chmod 0755 install/usr/local/ssl/bin/openssl
}

if [ $# -eq 0 ]; then
	usage
fi


rm -rf install
while [ $# -gt 0 ]; do
case "$1" in
	secos) install_secos;;
	tzdev) install_tzdev;;
	twts) install_twts;;
	*) usage "wrong arg '$1'";;
esac
shift
done

if [ -d install ]; then
	echo "copying install dir..."
	scp -r install/* "root@$TARTGET_IP:/"
	echo "done."
fi
