#!/usr/bin/env bash
set -euo pipefail

# List DHCP reservations from Kea via SSH
# Usage: dhcp-list [subnet]
# Example: dhcp-list              (all subnets)
#          dhcp-list 10.40.250    (filter by third octet)

DHCP_SERVER="${HOMELAB_DHCP_SERVER:-10.40.250.2}"
SSH_USER="${HOMELAB_SSH_USER:-mwdavisii}"
KEA_CONF="/etc/kea/kea-dhcp4.conf"

FILTER="${1:-}"

JQ_QUERY='
  .Dhcp4.subnet4[]
  | .subnet as $subnet
  | (.reservations // [])[]
  | [$subnet, .hostname // "(none)", ."ip-address", ."hw-address"]
  | @tsv
'

OUTPUT=$(ssh "${SSH_USER}@${DHCP_SERVER}" "jq -r '${JQ_QUERY}' ${KEA_CONF}")

if [[ -z "$OUTPUT" ]]; then
    echo "No reservations found"
    exit 0
fi

if [[ -n "$FILTER" ]]; then
    OUTPUT=$(echo "$OUTPUT" | grep "$FILTER" || true)
    if [[ -z "$OUTPUT" ]]; then
        echo "No reservations matching '${FILTER}'"
        exit 0
    fi
fi

printf "%-18s %-24s %-16s %-20s\n" "SUBNET" "HOSTNAME" "IP" "MAC"
printf "%-18s %-24s %-16s %-20s\n" "------" "--------" "--" "---"
echo "$OUTPUT" | sort -t$'\t' -k3 -V | while IFS=$'\t' read -r subnet hostname ip mac; do
    printf "%-18s %-24s %-16s %-20s\n" "$subnet" "$hostname" "$ip" "$mac"
done
