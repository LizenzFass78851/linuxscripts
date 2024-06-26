#!/bin/bash

# for linuxmint 21.x (ubuntu 22.04)
# config Links, Apps and Hostname

LINKS="https://download.anydesk.com/linux/anydesk_6.3.1-1_amd64.deb
https://github.com/rustdesk/rustdesk/releases/download/1.2.3-2/rustdesk-1.2.3-2-x86_64.deb
https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
https://dl.google.com/dl/linux/direct/google-earth-pro-stable_7.3.6_amd64.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
https://download.virtualbox.org/virtualbox/7.0.16/virtualbox-7.0_7.0.16-162802~Ubuntu~jammy_amd64.deb
https://download.virtualbox.org/virtualbox/7.0.16/Oracle_VM_VirtualBox_Extension_Pack-7.0.16.vbox-extpack
https://repo.steampowered.com/steam/archive/stable/steam_latest.deb
https://dl.discordapp.net/apps/linux/0.0.49/discord-0.0.49.deb
https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
https://github.com/shiftkey/desktop/releases/download/release-3.3.12-linux2/GitHubDesktop-linux-amd64-3.3.12-linux2.deb"

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

function errorrmessage2() {
	if [ $RESULT -ne 0 ]; then
		echo install docker-compose failed;
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
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
errorrmessage

chmod a+r /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/winehq-archive.key

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources

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


curl -SL $(curl -L -s https://api.github.com/repos/docker/compose/releases/latest | grep -o -E "https://(.*)docker-compose-linux-$(uname -m)") -o /usr/local/bin/docker-compose
errorrmessage2

ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


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

