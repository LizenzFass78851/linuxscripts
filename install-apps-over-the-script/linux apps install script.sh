#!/bin/bash

# for linuxmint 21.x (ubuntu 22.04)
# config Links, Apps and Hostname

LINKS="https://download.anydesk.com/linux/anydesk_6.2.1-1_amd64.deb
https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
https://dl.google.com/dl/linux/direct/google-earth-pro-stable_7.3.6_amd64.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
https://download.virtualbox.org/virtualbox/6.1.46/virtualbox-6.1_6.1.46-158378~Ubuntu~jammy_amd64.deb
https://download.virtualbox.org/virtualbox/6.1.46/Oracle_VM_VirtualBox_Extension_Pack-6.1.46.vbox-extpack
https://repo.steampowered.com/steam/archive/stable/steam_latest.deb
https://dl.discordapp.net/apps/linux/0.0.28/discord-0.0.28.deb
https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
https://github.com/shiftkey/desktop/releases/download/release-3.2.5-linux1/GitHubDesktop-linux-3.2.5-linux1.deb"

NEEDEDAPPS="snapd
tilix"

APPS="adb
aria2
bleachbit
borgbackup
clamav
clamav-daemon
clamav-freshclam
clamtk
containerd.io
docker-buildx-plugin
docker-ce
docker-ce-cli
docker-compose
docker-compose-plugin
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
winehq-stable
winetricks
wireshark-qt
xrdp"

SNAPS="p7zip-desktop"

HOSTNAME="Test-PC"

# ----------------------------------------------------------------------------------
function errorrmessage() {
	if [ $RESULT -ne 0 ]; then
		echo add apt repo failed;
		exit 1;
	fi
}

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

apt remove -y docker docker-engine docker.io containerd runc

dpkg --add-architecture i386 

apt update && \
  apt install -y \
    ca-certificates \
    curl \
    gnupg

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
errorrmessage
curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq.gpg
errorrmessage

chmod a+r /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/winehq.gpg

echo \
  "deb [arch="amd64" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
echo \
  "deb [arch="amd64 i386" signed-by=/etc/apt/keyrings/winehq.gpg] https://dl.winehq.org/wine-builds/ubuntu \
  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" main" | \
  tee /etc/apt/sources.list.d/winehq.list > /dev/null

rm /etc/apt/preferences.d/nosnap.pref

apt update
errorrmessage

apt install -yy \
  ${NEEDEDAPPS} \
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
#
#sed -i 's/autologin-user.*$/ /g' /etc/lightdm/lightdm.conf

rm *.deb

echo Installation successful

