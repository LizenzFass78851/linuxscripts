#!/bin/bash

# Ubuntu based Armbian Xfce Desktop only

set -e

apt update || true

XFREERDP_PKG="$(apt-cache search freerdp[01-99]-x11 | awk -F' ' '{ print $1 }' | sort -u -n | head -n1)"
[ -z "$XFREERDP_PKG" ] && echo "No freerdp-x11 package found" && exit 1

apt install -y $XFREERDP_PKG

cp rpitc.tar.xz /opt && cd /opt
tar -xf rpitc.tar.xz && rm rpitc.tar.xz

USERS="$(ls /home/)"
for USER in ${USERS}; do
        passwd $USER -d
        echo "[SeatDefaults]"          > /etc/lightdm/lightdm.conf.d/90-xubuntu.conf
        echo "autologin-user = $USER" >> /etc/lightdm/lightdm.conf.d/90-xubuntu.conf
        mkdir -p /home/$USER/Desktop/
	cp ./config/xFreeRDP.desktop /home/$USER/Desktop/
done
