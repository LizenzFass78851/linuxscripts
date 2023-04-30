#!/bin/bash

# for ubuntu 22.04 and linuxmint 21.x
# config Links, Apps and Hostname

LINKS="https://download.anydesk.com/linux/anydesk_6.2.1-1_amd64.deb
https://dn3.freedownloadmanager.org/6/latest/freedownloadmanager.deb
https://dl.google.com/dl/linux/direct/google-earth-pro-stable_7.3.6_amd64.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
https://download.virtualbox.org/virtualbox/7.0.6/virtualbox-7.0_7.0.6-155176~Ubuntu~jammy_amd64.deb
https://download.virtualbox.org/virtualbox/7.0.6/Oracle_VM_VirtualBox_Extension_Pack-7.0.6a-155176.vbox-extpack
https://repo.steampowered.com/steam/archive/stable/steam_latest.deb
https://dl.discordapp.net/apps/linux/0.0.24/discord-0.0.24.deb
https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
https://github.com/shiftkey/desktop/releases/download/release-3.1.1-linux1/GitHubDesktop-linux-3.1.1-linux1.deb"

APPS="adb
aria2
bleachbit
borgbackup
clamav
clamav-daemon
clamav-freshclam
clamtk
docker
docker-compose
fastboot
firefox
gimp
git
gparted
gqrx-sdr
handbrake
inkscape
iperf
john
kdenlive 
kodi
libreoffice
nano
nmap
obs-studio
openjdk-17-jre
openjdk-8-jre
openssh-server
p7zip
p7zip-full
p7zip-rar
parted
picard
remmina
tar
testdisk
thunderbird
unzip
vlc
vorta
wget
wine
winetricks
wireshark-qt
xrdp"

SNAPS="p7zip-desktop"

HOSTNAME="Test-PC"

# ----------------------------------------------------------------------------------

rm *.deb

USERS=$(ls /home/)

for TARG1 in ${LINKS}; do
	wget $TARG1
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		wget $TARG1
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo downloading $TARG1 failed again;
			exit 1;
		fi
	fi
done

rm /etc/apt/preferences.d/nosnap.pref
apt update

apt install -yy \
  snapd \
  ${APPS} \
  $(pwd)/$1*.deb
RESULT=$?
if [ $RESULT -ne 0 ]; then
	echo installing apps failed;
	exit 1;
fi

for SNAP1 in ${SNAPS}; do
	snap install $SNAP1
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo install snap $SNAP1 failed;
		exit 1;
	fi
done

update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper

echo ${HOSTNAME} > /etc/hostname

## only for local testing
#passwd -d root 
#
#for TARG2 in ${USERS}; do
#	passwd -d $TARG2
#done

rm *.deb

echo Installation successful

