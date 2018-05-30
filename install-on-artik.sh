#!/bin/bash

SCRIPT=`basename $0`

function usage() {
	if [ $# -gt 0 ]; then
		echo "$@"
		echo "usage $SCRIPT [secos|tzdev|twts]"
	else
		echo "usage $SCRIPT [secos|tzdev|twts]"
	fi
	exit 1
}

function install_secos() {
if [ ! -f ./sign_secos.sh ]; then
	echo "./sign_secos.sh not found"
	exit 1
fi
type -p fastboot > /dev/null || usage "fastboot not installed"
./sign_secos.sh
sudo fastboot flash partmap artik530s_20180416_fuse/partmap_emmc.txt
sudo fastboot flash loader artik530s_20180416_fuse/loader-emmc.img
sudo fastboot flash secure result-artik530_raptor/secureos.img
#fastboot flash secure secureos-leszek.img

sleep 0.5;fastboot reboot

echo "============================"
echo "ifconfig eth0 172.16.0.66 up"
echo "============================"
}

function install_tzdev() {
echo "preparing tzdev files..."
mkdir -p install/root install/lib install/usr/apps/tee
cp secos/out/ree-install/modules/tzdev.ko secos/out/ree-install/bin/tzdaemon install/root/
cp secos/out/ree-install/lib/libteec.so install/lib/
cp -r secos/out/app-ree-install/usr/apps/* install/usr/apps/
cp -r secos/out/app-tee-install/usr/apps/tee/* install/usr/apps/tee/
cat > install/root/ifup.sh <<EOF
ifconfig eth0 172.16.0.66 up
EOF
chmod +x install/root/ifup.sh
cat > install/root/tzdev.sh <<EOF
insmod -f tzdev.ko
EOF
chmod +x install/root/tzdev.sh
cat > install/root/run.sh <<EOF
./tzdaemon
EOF
chmod +x install/root/run.sh
}

function install_twts() {
echo "preparing twts files..."
mkdir -p install/usr/apps install/lib install/usr/local/ssl/bin/
cp -a twts/dist/usr/apps/ install/usr/
cp -a twts/tw_test_suite/lib/tf/* install/lib/
cp -a twts/tw_test_suite/lib/solution/* install/lib/

cp tls_test_server/tls_server install/usr/apps/
cp -a tls_test_server/openssl_cert_files/* install/usr/local/ssl/bin/
cp  tls_test_server/echo_server_tcp install/usr/apps/
cp  tls_test_server/echo_server_tcp_noresponse install/usr/apps/
cp  tls_test_server/echo_server_udp install/usr/apps/
cp  tls_test_server/echo_server_udp_noresponse install/usr/apps/
chmod 775 install/usr/apps/*
chmod 775 install/usr/local/ssl/bin/openssl
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
	scp -r install/* root@172.16.0.66:/
	echo "done."
fi
