#!/bin/bash

# for linuxmint 22.x (ubuntu 24.04)
# config Links, Apps and Hostname

LINKS="https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$(curl -L -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep -o -E "https://(.*)rustdesk-(.*)-$(uname -m).deb" | cut -d ' ' -f 999 )"

NEEDEDAPPS="tilix"

APPS="adb
aria2
bleachbit
borgbackup
clamav
clamav-daemon
clamav-freshclam
clamtk
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
openjdk-17-jre
openjdk-8-jre
openssh-server
p7zip
p7zip-full
p7zip-rar
parted
picard
remmina
steam
tar
testdisk
thunderbird
unzip
virtualbox
vlc
vorta
wget
winetricks
wireshark
xrdp"

FLATPAKS="io.github.shiftey.Desktop
io.github.peazip.PeaZip
com.anydesk.Anydesk
com.discordapp.Discord
com.obsproject.Studio
org.onlyoffice.desktopeditors"

HOSTNAME="Test-PC"

# ----------------------------------------------------------------------------------
function errorrmessage() {
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo add apt repo failed;
		exit 1;
	fi
}

function errorrmessage2() {
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo installing apps failed;
		exit 1;
	fi
}


function dockerinstaller() {
apt remove -y docker docker-engine docker.io containerd runc

apt update

apt install -y \
    ca-certificates \
    curl \
    gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$UBUNTU_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
errorrmessage

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
errorrmessage2
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

apt update
errorrmessage

apt install -yy \
  ${NEEDEDAPPS} \
  ${APPS} \
  $(pwd)/$1*.deb
errorrmessage2

dockerinstaller

for FLATPAKS1 in ${FLATPAKS}; do
	flatpak install flathub $FLATPAKS1 -y
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo install flatpak $FLATPAKS1 failed;
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
