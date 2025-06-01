#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

# Samba Post-Setup Additional DC Join Script for primary DC
# Run this script on the primary DC after the initial of secondary DC setup is complete.
# Based on the original AD DC installation script

# 1. Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1       localhost
${PRIMARY_DC_IP}    ${PRIMARY_DC_HOSTNAME}.${REALM}    ${PRIMARY_DC_HOSTNAME}
${SECONDARY_DC_IP}   ${SECONDARY_DC_HOSTNAME}.${REALM}    ${SECONDARY_DC_HOSTNAME}
EOF

# 2. Reconfigure static IP to use self as DNS
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
        addresses: [${PRIMARY_DC_IP}, ${SECONDARY_DC_IP}]
EOF
chmod 600 /etc/netplan/99-${PRIMARY_DC_INTERFACE}-static-${PRIMARY_DC_IP}.yaml
netplan apply

# 3. Create reverse DNS record for secondary DC 
echo "Creating reverse DNS record for secondary DC..."
if [ ! "${PRIMARY_DC_PTR_ADDRESS}" == "${SECONDARY_DC_PTR_ADDRESS}" ]; then
    samba-tool dns zonecreate ${PRIMARY_DC_HOSTNAME} ${SECONDARY_DC_PTR_ADDRESS} -Uadministrator%${ADMIN_PASSWORD}
fi
samba-tool dns add ${PRIMARY_DC_HOSTNAME}.${REALM} ${SECONDARY_DC_PTR_ADDRESS} $(echo ${SECONDARY_DC_IP} | awk -F. '{ print $4 }') PTR ${SECONDARY_DC_HOSTNAME}.${REALM} -Uadministrator%${ADMIN_PASSWORD}

echo "Installation complete. Please review the configuration and reboot the system."
