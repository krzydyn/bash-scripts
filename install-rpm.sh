#!/bin/sh

PROF="emulator"
if [ -n "$1" ]; then
    PROF=$1
fi
RPM_SRC="$HOME/GBS-ROOT/local/repos/$PROF/i586/RPMS"


mkdir -p RPMS
cp -a "$RPM_SRC"/*rpm RPMS/

cat > RPMS/prep.sh <<EOF
rm -f *devel* *devkit* tef-simulator-helloworld*

systemctl stop tef-simulator

echo "Uninstalling packages"
echo "   Uninstall tct-test-ta"
rpm -e \`rpm -qa |grep tct-test-ta\` --nodeps
echo "   Uninstall tef-simulator"
rpm -e \`rpm -qa |grep tef-simulator\` --nodeps
echo "   Uninstall tef-libteec"
rpm -e \`rpm -qa |grep tef-libteec\` --nodeps

rm -rf /tmp/tastore /opt/usr/apps/ta_sdk
rm -rf /usr/lib/tastore /usr/lib64/tastore
rm -rf /etc/tef
rm -rf /var/log/ta/

echo "Installing packages"
rpm -Uh tef-libteec*
rpm -Uh tef-simulator-*
rpm -Uh tct-test-ta*

echo "Restarting tef-simulator"
systemctl restart tef-simulator
systemctl status tef-simulator

dlogutil -c
EOF

rm -f RPMS/*boost*

scp RPMS/* te:
ssh te
