#!/bin/bash

# Path to the acme.json file and the output directory
ACME_JSON="./volumes/letsencrypt/acme.json"
OUTPUT_DIR="./volumes/letsencrypt"

# Ensure the output directory exists
mkdir -p $OUTPUT_DIR

# Verify acme.json exists
if [ ! -f "$ACME_JSON" ]; then
  echo "Error: acme.json not found at $ACME_JSON"
  exit 1
fi

# Extract and decode the certificate chain (including intermediates)
echo "Extracting and decoding fullchain certificate..."
CERTIFICATE=$(jq -r '.letsencrypt.Certificates[] | select(.domain.main == "vpn.thingsmart.co") | .certificate' $ACME_JSON)

if [ -z "$CERTIFICATE" ]; then
  echo "Error: Failed to extract certificate from acme.json"
  exit 1
fi

# Decode and save the certificate chain as fullchain.pem
echo "$CERTIFICATE" | base64 --decode > $OUTPUT_DIR/fullchain.pem

# Extract and decode the private key and save as privkey.pem
echo "Extracting and decoding private key..."
PRIVATE_KEY=$(jq -r '.letsencrypt.Certificates[] | select(.domain.main == "vpn.thingsmart.co") | .key' $ACME_JSON)

if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: Failed to extract private key from acme.json"
  exit 1
fi

# Decode and save the private key as privkey.pem
echo "$PRIVATE_KEY" | base64 --decode > $OUTPUT_DIR/privkey.pem

# Verify the files were created successfully
if [ -f "$OUTPUT_DIR/fullchain.pem" ] && [ -f "$OUTPUT_DIR/privkey.pem" ]; then
    echo "Certificates successfully extracted and saved as fullchain.pem and privkey.pem!"
else
    echo "Error: Failed to extract certificates. Please check acme.json."
    exit 1
fi
