echo "Install tef-simulator"
rm *devkit*.rpm
rpm -iUh tef-simulator-*rpm
systemctl daemon-reload
systemctl start tef-simulator

chsmack -a "_" /usr/lib/tizen-extensions-crosswalk/plugins.json
chsmack -a "_" /usr/lib/tef/simulator/libteec.so
chsmack -a "_" /etc/tef/tef.conf


# list installed packaged
# pkgcmd -l
# manual install 
# pkgcmd -i -t wgt -p Test.wgt
# manual uninstall 
# pkgcmd -u -n IJt1xdiAhM
