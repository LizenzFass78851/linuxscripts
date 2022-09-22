# Build Gluon Script
the script carries out the workflow to build gluon with the ffc site config
All targets with all cpu cores are used when building and broken equals 1


### the following packages are required for ubuntu and debian
Simply enter the command below and all the necessary packages will be installed under ubuntu and debian
````
sudo apt update && sudo apt install -y --no-install-recommends build-essential ca-certificates curl gawk file git libncurses-dev lua-check python2 shellcheck time unzip wget qemu-utils
````


### Note when building the targets for x86 and x64 from gluon master
another package must be installed so that there are no errors when building the corresponding targets.
````
sudo apt install qemu-utils -y
````

without this package the following error occurs since the current gluon master:
````
WARNING: Install qemu-img to create VDI/VMDK images
make[6]: *** [Makefile:152: /media/user/disk/gluon/openwrt/build_dir/target-i386_pentium4_musl/linux-x86_generic/tmp/openwrt-x86-generic-generic-squashfs-combined.vdi] error 1
````
