#!/bin/sh

gzfile=gzip_1.10-0ubuntu4.1_amd64.deb

wget https://launchpad.net/ubuntu/+archive/primary/+files/$gzfile
apt install -y --allow-downgrades --allow-change-held-packages ./$gzfile
echo gzip hold | dpkg --set-selections
rm $gzfile

