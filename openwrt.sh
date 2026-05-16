#!/bin/bash

# --- Configuration ---
ROUTER_IP="openwrt.lan"
USERNAME="root"
PASSWORD="Ny3MJaOTg1Czuv"
OUTPUT_FILE="./openwrt.hosts"

# --- 1. Authenticate and get Session ID ---
echo "Authenticating with $ROUTER_IP..."
AUTH_JSON=$(curl -s -X POST "http://$ROUTER_IP/cgi-bin/luci/rpc/auth" \
    -d "{
        \"id\": 1,
        \"method\": \"login\",
        \"params\": [\"$USERNAME\", \"$PASSWORD\"]
    }")

# Extract the 'result' field using jq
SESSION_ID=$(echo "$AUTH_JSON" | jq -r '.result')

# Check if authentication failed
if [ "$SESSION_ID" == "null" ] || [ -z "$SESSION_ID" ]; then
    echo "Error: Authentication failed. Check your username/password."
    exit 1
fi

echo "Login successful. Session ID: ${SESSION_ID:0:8}..."

# --- 2. Fetch DHCP Leases ---
echo "Fetching DHCP leases..."
LEASES_JSON=$(curl -s -X POST "http://$ROUTER_IP/cgi-bin/luci/rpc/luci?auth=$SESSION_ID" \
    -d '{
        "id": 1,
        "method": "getDHCPLeases",
        "params": []
    }')

# --- 3. Generate the Hosts File ---
echo "# Generated from OpenWrt DHCP leases on $(date)" > "$OUTPUT_FILE"
echo "$LEASES_JSON"
# Use jq to iterate over the 'result' array and format as: IP hostname
echo "$LEASES_JSON" | jq -r '.result[] | "\(.ipaddr) \(.hostname)"' >> "$OUTPUT_FILE"

echo "Success! Hosts file created at: $OUTPUT_FILE"
cat "$OUTPUT_FILE"