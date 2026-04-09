#!/usr/bin/env bash
set -euo pipefail

# Delete an A record + PTR record via remote nsupdate
# Usage: dns-delete <hostname> <ip>
# Example: dns-delete nas 10.40.250.20

DOMAIN="${HOMELAB_DOMAIN:-mwdavisii.com}"
DNS_SERVER="${HOMELAB_DNS_SERVER:-10.40.250.54}"

if [[ -z "${HOMELAB_TSIG_KEY:-}" ]]; then
    echo "Error: HOMELAB_TSIG_KEY must be set to the path of your TSIG key file"
    exit 1
fi

if [[ ! -f "$HOMELAB_TSIG_KEY" ]]; then
    echo "Error: TSIG key file not found: $HOMELAB_TSIG_KEY"
    exit 1
fi

if [[ $# -ne 2 ]]; then
    echo "Usage: dns-delete <hostname> <ip>"
    echo "Example: dns-delete nas 10.40.250.20"
    exit 1
fi

HOSTNAME="$1"
IP="$2"
FQDN="${HOSTNAME}.${DOMAIN}"

if ! [[ $IP =~ ^10\.40\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: IP must be in 10.40.x.x format"
    exit 1
fi

IFS='.' read -r o1 o2 o3 o4 <<< "$IP"
REVERSE_ZONE="${o3}.${o2}.${o1}.in-addr.arpa"
PTR_RECORD="${o4}.${REVERSE_ZONE}"

echo "Deleting DNS records:"
echo "  Forward: ${FQDN}"
echo "  Reverse: ${PTR_RECORD}"
echo ""

echo -n "Deleting A record... "
nsupdate -k "$HOMELAB_TSIG_KEY" <<EOF
server ${DNS_SERVER}
zone ${DOMAIN}
update delete ${FQDN} A
send
EOF
echo "done"

echo -n "Deleting PTR record... "
nsupdate -k "$HOMELAB_TSIG_KEY" <<EOF
server ${DNS_SERVER}
zone ${REVERSE_ZONE}
update delete ${PTR_RECORD} PTR
send
EOF
echo "done"

echo ""
echo "Verifying (should be empty):"
echo -n "  A:   "
dig +short "@${DNS_SERVER}" "${FQDN}"
echo -n "  PTR: "
dig +short "@${DNS_SERVER}" -x "${IP}"
