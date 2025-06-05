#!/bin/bash

# Build all targets as of the defined version from gluon, also broken and use all cpu cores (broken can be set in the script)
# If there were changes to the targets during gluon, this can also be set in the script


BROKENS="1"

# for gluon v2023.2.5
TARGETS="armsr-armv7
armsr-armv8
ath79-generic
ath79-mikrotik
ath79-nand
bcm27xx-bcm2708
bcm27xx-bcm2709
bcm27xx-bcm2710
bcm27xx-bcm2711
ipq40xx-generic
ipq40xx-mikrotik
ipq806x-generic
lantiq-xrx200
lantiq-xway
mediatek-filogic
mediatek-mt7622
mpc85xx-p1010
mpc85xx-p1020
mvebu-cortexa9
ramips-mt7620
ramips-mt7621
ramips-mt76x8
realtek-rtl838x
rockchip-armv8
sunxi-cortexa7
x86-generic
x86-geode
x86-legacy
x86-64"


git clone --branch v2023.2.5 https://github.com/freifunk-gluon/gluon.git
cd gluon
git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site
make update

export DEFAULT_GLUON_RELEASE="b$(date '+%Y%m%d')"

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

