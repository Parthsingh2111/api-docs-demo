#!/bin/bash

set -euo pipefail

# Change to backendJava directory
cd "$(dirname "$0")/backendJava"

# Set environment variables
export PAYGLOCAL_API_KEY="dGVzdG5ld2djYzI2OmtJZC1Ka3NGczBGdmJyajNkSjJQ"
export PAYGLOCAL_MERCHANT_ID="testnewgcc26"
export PAYGLOCAL_PUBLIC_KEY_ID="kId-yLtRky48X2HqW30k"
export PAYGLOCAL_PRIVATE_KEY_ID="kId-vU6e8l6bWtXK8oOK"
export PAYGLOCAL_ENV="UAT"
export PAYGLOCAL_LOG_LEVEL="debug"

# Load PEM keys from repo
export PAYGLOCAL_PUBLIC_KEY="$(cat ../backend/keys/payglocal_public_key)"
export PAYGLOCAL_MERCHANT_PRIVATE_KEY="$(cat ../backend/keys/payglocal_private_key)"

# Print environment variables for debugging
echo "Environment variables set:"
echo "PAYGLOCAL_MERCHANT_ID: $PAYGLOCAL_MERCHANT_ID"
echo "PAYGLOCAL_ENV: $PAYGLOCAL_ENV"
echo "PAYGLOCAL_PUBLIC_KEY length: ${#PAYGLOCAL_PUBLIC_KEY}"
echo "PAYGLOCAL_MERCHANT_PRIVATE_KEY length: ${#PAYGLOCAL_MERCHANT_PRIVATE_KEY}"

# Run the server in foreground
echo "Starting Spring Boot server on port 8085..."
mvn spring-boot:run 