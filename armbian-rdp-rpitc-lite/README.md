# Armbian RDP RPITC (Lite)
this is a small script that loads the rpitc data on an armbian installation (can be used both with and without a desktop) and from it a mini thinclient with currently nothing but xfreerdp to use an armbian-enabled device as a thinclient to connect to a e.g. terminal server (windows desktop) or similar.
##### only applicable to ubuntu based armbian
##### as armbian desktop image (if no console only images are desired) only xfce desktop


### to run the following:
````
wget https://github.com/LizenzFass78851/linuxscripts/raw/main/armbian-rdp-rpitc-lite/install-armbian-rpitc-rdp.sh 
wget https://github.com/LizenzFass78851/linuxscripts/raw/main/armbian-rdp-rpitc-lite/rpitc.tar.xz

chmod +x install-armbian-rpitc-rdp.sh
./install-armbian-rpitc-rdp.sh

rm install-armbian-rpitc-rdp.sh
rm rpitc.tar.xz 
````
