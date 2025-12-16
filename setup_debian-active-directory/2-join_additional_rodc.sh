#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Samba Additional DC Join Script
# Based on the original AD DC installation script

# 1. Disable IPv6
echo "Disabling IPv6..."
cat > /etc/default/grub.d/disable-ipv6.cfg << EOF
GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"
EOF
update-grub

# 2. Configure static IP (Debian style)
echo "Configuring static IP..."
cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
allow-hotplug ${SECONDARY_DC_INTERFACE}
auto ${SECONDARY_DC_INTERFACE}
iface ${SECONDARY_DC_INTERFACE} inet static
    address ${SECONDARY_DC_IP}
    netmask 255.255.255.0
    gateway ${SECONDARY_DC_GATEWAY_IP}
EOF
systemctl restart networking

# 3. Configure resolve file
cat > /etc/resolv.conf << EOF
search ${REALM}
nameserver ${PRIMARY_DC_IP}
EOF

# 4. Set hostname
echo "Setting hostname..."
hostnamectl set-hostname ${SECONDARY_DC_HOSTNAME}

# 5. Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1       localhost
${SECONDARY_DC_IP}    ${SECONDARY_DC_HOSTNAME}.${REALM}    ${SECONDARY_DC_HOSTNAME}
${PRIMARY_DC_IP}   ${PRIMARY_DC_IP_HOSTNAME}.${REALM}    ${PRIMARY_DC_IP_HOSTNAME}
EOF

# 6. Install required packages
echo "Installing required packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y samba heimdal-clients smbclient winbind chrony ldb-tools python3-setproctitle dnsutils

# 7. Backup original config files
echo "Backing up original configuration files..."
mv /etc/samba/smb.conf{,.bu.orig}
mv /etc/krb5.conf{,.bu.orig}
mv /etc/default/chrony{,.bu.orig}
mv /etc/chrony/chrony.conf{,.bu.orig}

# 8. Stop and mask standard Samba services
echo "Stopping and masking standard Samba services..."
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl mask smbd nmbd winbind

# 9. Clean up Samba databases
echo "Cleaning up Samba databases..."
rm -f /run/samba/*.tdb
rm -f /var/lib/samba/*.tdb
rm -f /var/cache/samba/*.tdb
rm -f /var/lib/samba/private/*.tdb

# 10. Join Domain
echo "Joining domain as additional DC..."
samba-tool domain join ${REALM} RODC -U"administrator%${ADMIN_PASSWORD}" \
    --option="interfaces=127.0.0.1 ${SECONDARY_DC_IP}" \
    --option="bind interfaces only=yes" \
    --option="idmap_ldb:use rfc2307 = yes" \
    --option="dns forwarder=${SECONDARY_DC_FORWARDER_DNS}" \
    --dns-backend=SAMBA_INTERNAL

# 11. Copy Kerberos configuration
echo "Configuring Kerberos..."
cp /var/lib/samba/private/krb5.conf /etc/

# 12. Reconfigure static IP (Debian style)
echo "Reconfiguring static IP..."
cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
allow-hotplug ${SECONDARY_DC_INTERFACE}
auto ${SECONDARY_DC_INTERFACE}
iface ${SECONDARY_DC_INTERFACE} inet static
    address ${SECONDARY_DC_IP}
    netmask 255.255.255.0
    gateway ${SECONDARY_DC_GATEWAY_IP}
EOF
systemctl restart networking

# 13. Configure resolve file
cat > /etc/resolv.conf << EOF
search ${REALM}
nameserver ${SECONDARY_DC_IP}
nameserver ${PRIMARY_DC_IP}
EOF

# 14. Configure chrony
echo "Configuring chrony..."
cat > /etc/chrony/chrony.conf << EOF
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst
keyfile /etc/chrony/chrony.keys
driftfile /var/lib/chrony/chrony.drift
logdir /var/log/chrony
maxupdateskew 100.0
rtcsync
makestep 1 3
leapsectz right/UTC
bindcmdaddress 127.0.0.1
bindaddress ${SECONDARY_DC_IP}
allow ${SECONDARY_DC_NETWORK}
ntpsigndsocket /var/lib/samba/ntp_signd
EOF

# Configure chrony for IPv4 only
cat > /etc/default/chrony << EOF
DAEMON_OPTS="-F 1 -4"
SYNC_IN_CONTAINER="no"
EOF

# Set correct permissions for NTP signd socket
chgrp _chrony /var/lib/samba/ntp_signd
chmod g+rx /var/lib/samba/ntp_signd

# 15. Start and enable services
echo "Starting services..."
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc
systemctl restart chrony

echo "Additional DC setup complete. Please review the configuration and reboot the system."
