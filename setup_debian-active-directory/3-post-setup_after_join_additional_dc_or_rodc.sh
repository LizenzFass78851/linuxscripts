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

# 2. Reconfigure static IP to use self as DNS (Debian style)
echo "Reconfiguring static IP..."
cat > /etc/network/interfaces << EOF
source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback
allow-hotplug ${PRIMARY_DC_INTERFACE}
auto ${PRIMARY_DC_INTERFACE}
iface ${PRIMARY_DC_INTERFACE} inet static
    address ${PRIMARY_DC_IP}
    netmask 255.255.255.0
    gateway ${PRIMARY_DC_GATEWAY_IP}
EOF
systemctl restart networking

# 3. Configure resolve file
cat > /etc/resolv.conf << EOF
search ${REALM}
nameserver ${PRIMARY_DC_IP}
nameserver ${SECONDARY_DC_IP}
EOF

# 4. Create reverse DNS record for secondary DC 
echo "Creating reverse DNS record for secondary DC..."
if [ ! "${PRIMARY_DC_PTR_ADDRESS}" == "${SECONDARY_DC_PTR_ADDRESS}" ]; then
    samba-tool dns zonecreate ${PRIMARY_DC_HOSTNAME} ${SECONDARY_DC_PTR_ADDRESS} -Uadministrator%${ADMIN_PASSWORD}
fi
samba-tool dns add ${PRIMARY_DC_HOSTNAME}.${REALM} ${SECONDARY_DC_PTR_ADDRESS} $(echo ${SECONDARY_DC_IP} | awk -F. '{ print $4 }') PTR ${SECONDARY_DC_HOSTNAME}.${REALM} -Uadministrator%${ADMIN_PASSWORD}

echo "Installation complete. Please review the configuration and reboot the system."
