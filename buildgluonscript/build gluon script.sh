#!/bin/bash

# the script carries out the workflow to build gluon with the ffc site config
# All targets with all cpu cores are used when building and broken equals 1

git clone --branch v2025.1.x https://github.com/freifunk-gluon/gluon.git
cd gluon
git clone https://gitlab.com/FreifunkChemnitz/site-ffc.git site
make update

export DEFAULT_GLUON_RELEASE="b$(date '+%Y%m%d')"
export BROKEN=1

TARGETS="$(make list-targets)"

for STEP in download build; do
	for TARG in ${TARGETS}; do
		if [ "$STEP" = download ]; then
			(echo "downloading $TARG"              && make GLUON_TARGET=$TARG -j$(nproc||printf "2") download) || \
			(echo "downloading $TARG failed"       && make GLUON_TARGET=$TARG V=s                    download) || \
			(echo "downloading $TARG failed again" && exit 1)
		else
			(echo "building $TARG"                 && make GLUON_TARGET=$TARG -j$(nproc||printf "2")         ) || \
			(echo "building $TARG failed"          && make GLUON_TARGET=$TARG V=s                            ) || \
			(echo "building $TARG failed again"    && exit 1)
		fi
	done
done
