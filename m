printf "\n========================\n"

if [ -f build/Makefile ]; then
	echo "Entering build dir"
	cd build && make -f Makefile $@
	echo "Leaving build dir"
else
	make $@
fi
