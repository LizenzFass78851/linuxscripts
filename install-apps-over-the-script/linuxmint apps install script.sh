#!/bin/bash

# for linuxmint 22.x (ubuntu 24.04)
# config Links, Apps and Hostname

INSTALL_DOCKER="true"

REMOVE_PASSWORD_ROOT="false"
REMOVE_PASSWORD_USERS="false"
AUTOLOGIN_LIGHTDM="false"

LINKS="https://files2.freedownloadmanager.org/6/latest/freedownloadmanager.deb
https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
$(curl -L -s https://api.github.com/repos/rustdesk/rustdesk/releases/latest | grep -o -E "https://(.*)rustdesk-(.*)-$(uname -m).deb" | cut -d ' ' -f 999 )
$(curl -L -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | grep -o -E "https://(.*)Heroic-(.*)-linux-$(dpkg --print-architecture).deb" | cut -d ' ' -f 999 )"

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
tilix
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

SET_HOSTNAME=""

# ----------------------------------------------------------------------------------

errorrmessage="add apt repo failed"
errorrmessage2="installing apps failed"
donemessage="Installation successful"

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

apt update \
|| ( echo ${errorrmessage} && exit 1 )

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
|| ( echo ${errorrmessage2} && exit 1 ) 
}

cleanup() {
rm *.deb
}

# ----------------------------------------------------------------------------------

cleanup

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

apt update \
|| ( echo ${errorrmessage} && exit 1 )

apt install -yy \
  ${APPS} \
  $(pwd)/$1*.deb \
|| ( echo ${errorrmessage2} && exit 1 )

if [ "${INSTALL_DOCKER}" = "true" ]; then
	dockerinstaller
fi

for FLATPAKS1 in ${FLATPAKS}; do
	flatpak install flathub $FLATPAKS1 -y
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo "install flatpak $FLATPAKS1 failed";
		exit 1;
	fi
done

if [ -x "$(command -v tilix)" ]; then
	update-alternatives --set x-terminal-emulator /usr/bin/tilix.wrapper
fi

if [ -n "$SET_HOSTNAME" ]; then
	hostnamectl set-hostname ${SET_HOSTNAME}
fi

if [ "${REMOVE_PASSWORD_ROOT}" = "true" ]; then
	passwd -d root
fi
if [ "${REMOVE_PASSWORD_USERS}" = "true" ]; then
	for TARG2 in ${USERS}; do
		passwd -d $TARG2
	done
fi
if [ "${AUTOLOGIN_LIGHTDM}" = "true" ]; then
	sed -i 's/autologin-user.*$/ /g' /etc/lightdm/lightdm.conf
fi

cleanup

echo ${donemessage} && exit 0
