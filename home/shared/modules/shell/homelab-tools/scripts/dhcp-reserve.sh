#!/usr/bin/env bash
set -euo pipefail

# Add a DHCP reservation to Kea via SSH
# Usage: dhcp-reserve <hostname> <ip> <mac>
# Example: dhcp-reserve nas 10.40.250.20 40:b0:34:fb:28:5d

DHCP_SERVER="${HOMELAB_DHCP_SERVER:-10.40.250.2}"
SSH_USER="${HOMELAB_SSH_USER:-mwdavisii}"
KEA_CONF="/etc/kea/kea-dhcp4.conf"

if [[ $# -ne 3 ]]; then
    echo "Usage: dhcp-reserve <hostname> <ip> <mac>"
    echo "Example: dhcp-reserve nas 10.40.250.20 40:b0:34:fb:28:5d"
    exit 1
fi

HOSTNAME="$1"
IP="$2"
MAC="$3"

if ! [[ $IP =~ ^10\.40\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: IP must be in 10.40.x.x format"
    exit 1
fi

if ! [[ $MAC =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
    echo "Error: MAC must be in xx:xx:xx:xx:xx:xx format"
    exit 1
fi

# Extract subnet from IP (e.g., 10.40.250.20 -> 10.40.250.0/24)
IFS='.' read -r o1 o2 o3 o4 <<< "$IP"
SUBNET="${o1}.${o2}.${o3}.0/24"

echo "Adding DHCP reservation on ${DHCP_SERVER}:"
echo "  Hostname: ${HOSTNAME}"
echo "  IP:       ${IP}"
echo "  MAC:      ${MAC}"
echo "  Subnet:   ${SUBNET}"
echo ""

# Build the jq filter to add reservation to the correct subnet
JQ_FILTER=$(cat <<'JQEOF'
.Dhcp4.subnet4 |= map(
  if .subnet == $subnet then
    .reservations = ((.reservations // []) + [{
      "ip-address": $ip,
      "hostname": $hostname,
      "hw-address": $mac
    }])
  else . end
)
JQEOF
)

ssh "${SSH_USER}@${DHCP_SERVER}" bash -s <<REMOTE
set -euo pipefail

# Check if subnet exists in config
if ! jq -e --arg subnet "${SUBNET}" '.Dhcp4.subnet4[] | select(.subnet == \$subnet)' ${KEA_CONF} > /dev/null 2>&1; then
    echo "Error: Subnet ${SUBNET} not found in Kea config"
    echo "Available subnets:"
    jq -r '.Dhcp4.subnet4[].subnet' ${KEA_CONF}
    exit 1
fi

# Check for duplicate IP or MAC in that subnet
if jq -e --arg subnet "${SUBNET}" --arg ip "${IP}" \
    '.Dhcp4.subnet4[] | select(.subnet == \$subnet) | .reservations[]? | select(."ip-address" == \$ip)' \
    ${KEA_CONF} > /dev/null 2>&1; then
    echo "Error: IP ${IP} already has a reservation in subnet ${SUBNET}"
    exit 1
fi

if jq -e --arg subnet "${SUBNET}" --arg mac "${MAC}" \
    '.Dhcp4.subnet4[] | select(.subnet == \$subnet) | .reservations[]? | select(."hw-address" == \$mac)' \
    ${KEA_CONF} > /dev/null 2>&1; then
    echo "Error: MAC ${MAC} already has a reservation in subnet ${SUBNET}"
    exit 1
fi

# Backup config
sudo cp ${KEA_CONF} ${KEA_CONF}.bak

# Add reservation
sudo jq --arg subnet "${SUBNET}" \
        --arg ip "${IP}" \
        --arg hostname "${HOSTNAME}" \
        --arg mac "${MAC}" \
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
echo "Reservation added successfully"
REMOTE
