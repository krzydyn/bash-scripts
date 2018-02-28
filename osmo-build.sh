#!/bin/bash

function buildPart {
	savedir=`pwd`
	case "$1" in
	lime)
		echo "Build LimeSuite"
		cd LimeSuite/build/
		cmake ..
		make -j8
		sudo make install
		sudo ldconfig
		cd ../../
		;;
	uhd)
		echo "Build UHD drivers"
		cd uhd/host/
		mkdir build
		cd build
		cmake ..
		make -j8
		sudo make install
		sudo ldconfig
		cd ../../../
		;;
	soapy)
		echo "Build SoapyUHD"
		cd SoapyUHD
		mkdir build
		cd build
		cmake ..
		make -j8
		sudo make install
		sudo ldconfig
		cd ../../
		;;
	bts)
		echo "Build OsmoBTS"
		cd osmo-combo/
		sudo make -j8
		sudo ldconfig
		cd ../
		;;
	trx)
		echo "Build osmo-trx"
		cd osmo-trx/
		autoreconf -i
		./configure
		make -j8
		sudo make install
		sudo ldconfig
		cd ../
	esac
	cd $savedir
}


buildPart trx

