#!/bin/sh

# Ubuntu based Armbian only

apt update
test -a /bin/xfce4-session || apt install -y xubuntu-desktop 
apt install -y armbian-config freerdp2-x11 

# if another language is desired then adjust accordingly here
apt install -y language-pack-de language-pack-gnome-de

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
