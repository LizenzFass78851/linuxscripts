#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Samba AD DC Installation Script
# Based on: https://wiki.ubuntuusers.de/HowTo/Samba-AD-Server_unter_Ubuntu_20.04_installieren/

# 1. Disable IPv6
echo "Disabling IPv6..."
cat > /etc/default/grub.d/disable-ipv6.cfg << EOF
GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"
EOF
update-grub

# 2. Configure static IP
echo "Configuring static IP..."
cat > /etc/netplan/99-${PRIMARY_DC_INTERFACE}-static-${PRIMARY_DC_IP}.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${PRIMARY_DC_INTERFACE}:
      addresses:
        - ${PRIMARY_DC_IP}/24
      dhcp4: no
      routes:
        - to: default
          via: ${PRIMARY_DC_GATEWAY_IP}
      nameservers:
        search: [${REALM}]
        addresses: [${PRIMARY_DC_GATEWAY_IP}]
EOF
chmod 600 /etc/netplan/99-${PRIMARY_DC_INTERFACE}-static-${PRIMARY_DC_IP}.yaml
netplan apply

# 3. Disable systemd-resolved stub listener
echo "Disabling systemd-resolved stub listener..."
mkdir -p /etc/systemd/resolved.conf.d/
cat > /etc/systemd/resolved.conf.d/disable-stub-listener.conf << EOF
[Resolve]
DNSStubListener=no
EOF

rm -f /etc/resolv.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

systemctl daemon-reload
systemctl restart systemd-resolved

# 4. Set hostname
echo "Setting hostname..."
hostnamectl set-hostname ${PRIMARY_DC_HOSTNAME}

# 5. Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1       localhost
${PRIMARY_DC_IP}    ${PRIMARY_DC_HOSTNAME}.${REALM}    ${PRIMARY_DC_HOSTNAME}
EOF

# 6. Install required packages
echo "Installing required packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y samba heimdal-clients smbclient winbind chrony ldb-tools python3-setproctitle

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

# 10. Provision Samba AD
echo "Provisioning Samba AD..."
samba-tool domain provision --use-rfc2307 --realm="${REALM}" --domain="${DOMAIN}" \
    --server-role=dc --dns-backend=SAMBA_INTERNAL --adminpass="${ADMIN_PASSWORD}" \
    --option="interfaces=127.0.0.1 ${PRIMARY_DC_IP}" --option="bind interfaces only=yes"

# 11. Copy Kerberos configuration
echo "Configuring Kerberos..."
cp /var/lib/samba/private/krb5.conf /etc/


# 12. Reconfigure static IP
echo "Reconfiguring static IP..."
cat > /etc/netplan/99-${PRIMARY_DC_INTERFACE}-static-${PRIMARY_DC_IP}.yaml << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${PRIMARY_DC_INTERFACE}:
      addresses:
        - ${PRIMARY_DC_IP}/24
      dhcp4: no
      routes:
        - to: default
          via: ${PRIMARY_DC_GATEWAY_IP}
      nameservers:
        search: [${REALM}]
        addresses: [${PRIMARY_DC_IP}]
EOF
chmod 600 /etc/netplan/99-${PRIMARY_DC_INTERFACE}-static-${PRIMARY_DC_IP}.yaml
netplan apply

# 13. Configure chrony
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
bindaddress ${PRIMARY_DC_IP}
allow ${PRIMARY_DC_NETWORK}
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

# 14. Start and enable services
echo "Starting services..."
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc
systemctl restart chrony

# 15. Create reverse DNS zone
echo "Creating reverse DNS zone..."
samba-tool dns zonecreate ${PRIMARY_DC_HOSTNAME} ${PRIMARY_DC_PTR_ADDRESS} -Uadministrator%${ADMIN_PASSWORD}
samba-tool dns add ${PRIMARY_DC_HOSTNAME}.${REALM} ${PRIMARY_DC_PTR_ADDRESS} $(echo ${PRIMARY_DC_IP} | awk --field-separator=. '{ print $4 }') PTR ${PRIMARY_DC_HOSTNAME}.${REALM} -Uadministrator%${ADMIN_PASSWORD}

echo "Installation complete. Please review the configuration and reboot the system."
