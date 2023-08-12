#!/bin/bash

# the script carries out the workflow to build gluon with the ffc site config
# All targets with all cpu cores are used when building and broken equals 1


BROKENS="1"


git clone --branch v2023.1 https://github.com/freifunk-gluon/gluon.git
cd gluon
git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site
make update


TARGETS="$(make list-targets)"

for TARG in ${TARGETS}; do
	echo downloading $TARG
	make GLUON_TARGET=$TARG BROKEN=$BROKENS -j$(nproc||printf "2") download
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo downloading $TARG failed;
		make GLUON_TARGET=$TARG BROKEN=$BROKENS V=s download
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo downloading $TARG failed again;
			exit 1;
		fi
	fi
done

for TARG in ${TARGETS}; do
	echo building $TARG
	make GLUON_TARGET=$TARG BROKEN=$BROKENS -j$(nproc||printf "2")
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo building $TARG failed;
		make GLUON_TARGET=$TARG BROKEN=$BROKENS V=s
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo building $TARG failed again;
			exit 1;
		fi
	fi
done
