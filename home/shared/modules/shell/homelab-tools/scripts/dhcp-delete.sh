#!/usr/bin/env bash
set -euo pipefail

# Remove a DHCP reservation from Kea via SSH
# Usage: dhcp-delete <hostname> <ip>
# Example: dhcp-delete nas 10.40.250.20

DHCP_SERVER="${HOMELAB_DHCP_SERVER:-10.40.250.2}"
SSH_USER="${HOMELAB_SSH_USER:-mwdavisii}"
KEA_CONF="/etc/kea/kea-dhcp4.conf"

if [[ $# -ne 2 ]]; then
    echo "Usage: dhcp-delete <hostname> <ip>"
    echo "Example: dhcp-delete nas 10.40.250.20"
    exit 1
fi

HOSTNAME="$1"
IP="$2"

if ! [[ $IP =~ ^10\.40\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: IP must be in 10.40.x.x format"
    exit 1
fi

IFS='.' read -r o1 o2 o3 o4 <<< "$IP"
SUBNET="${o1}.${o2}.${o3}.0/24"

echo "Removing DHCP reservation on ${DHCP_SERVER}:"
echo "  Hostname: ${HOSTNAME}"
echo "  IP:       ${IP}"
echo "  Subnet:   ${SUBNET}"
echo ""

JQ_FILTER='.Dhcp4.subnet4 |= map(
  if .subnet == $subnet then
    .reservations = [(.reservations // [])[] | select(."ip-address" != $ip)]
  else . end
)'

ssh "${SSH_USER}@${DHCP_SERVER}" bash -s <<REMOTE
set -euo pipefail

# Verify reservation exists
if ! jq -e --arg subnet "${SUBNET}" --arg ip "${IP}" \
    '.Dhcp4.subnet4[] | select(.subnet == \$subnet) | .reservations[]? | select(."ip-address" == \$ip)' \
    ${KEA_CONF} > /dev/null 2>&1; then
    echo "Error: No reservation found for IP ${IP} in subnet ${SUBNET}"
    exit 1
fi

# Show what we're removing
echo "Current reservation:"
jq --arg subnet "${SUBNET}" --arg ip "${IP}" \
    '.Dhcp4.subnet4[] | select(.subnet == \$subnet) | .reservations[]? | select(."ip-address" == \$ip)' \
    ${KEA_CONF}
echo ""

# Backup config
sudo cp ${KEA_CONF} ${KEA_CONF}.bak

# Remove reservation
sudo jq --arg subnet "${SUBNET}" --arg ip "${IP}" \
    '${JQ_FILTER}' \
    ${KEA_CONF}.bak | sudo tee ${KEA_CONF} > /dev/null

# Validate config
echo -n "Validating config... "
if sudo kea-dhcp4 -t ${KEA_CONF} 2>/dev/null; then
    echo "ok"
else
    echo "FAILED - rolling back"
    sudo cp ${KEA_CONF}.bak ${KEA_CONF}
    exit 1
fi

# Reload Kea
echo -n "Reloading Kea... "
sudo systemctl reload kea-dhcp4-server
echo "done"

echo ""
echo "Reservation removed successfully"
REMOTE
