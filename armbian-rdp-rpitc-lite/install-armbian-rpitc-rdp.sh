#!/bin/sh

# Ubuntu based Armbian Xfce Desktop only

apt update
apt install -y freerdp2-x11 

cp rpitc.tar.xz /opt
cd /opt
tar -xf rpitc.tar.xz
rm rpitc.tar.xz

USERS="$(ls /home/)"
for USER in ${USERS}; do
        passwd $USER -d
        echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/90-xubuntu.conf
        echo "autologin-user = $USER" >> /etc/lightdm/lightdm.conf.d/90-xubuntu.conf
        mkdir /home/$USER/Desktop/
	cp ./config/xFreeRDP.desktop /home/$USER/Desktop/
done
