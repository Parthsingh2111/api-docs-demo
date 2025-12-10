#!/bin/bash

# Helper script to prepare PEM keys for Vercel environment variables
# This converts multi-line PEM files into single-line strings with \n escapes

echo "=========================================="
echo "Vercel Environment Variable Key Converter"
echo "=========================================="
echo ""
echo "This script converts PEM keys to Vercel-compatible format."
echo "Copy the output and paste into Vercel environment variables."
echo ""

# Check if backend directory exists
if [ ! -d "backend" ]; then
  echo "Error: backend directory not found. Run this script from the project root."
  exit 1
fi

cd backend

echo "--- Configuration 1 ---"
echo ""
echo "PAYGLOCAL_PUBLIC_KEY_CONTENT:"
if [ -f "keys/payglocal_public_key" ]; then
  cat keys/payglocal_public_key | tr '\n' '\\n'
  echo ""
else
  echo "ERROR: keys/payglocal_public_key not found"
fi
echo ""

echo "PAYGLOCAL_PRIVATE_KEY_CONTENT:"
if [ -f "keys/payglocal_private_key" ]; then
  cat keys/payglocal_private_key | tr '\n' '\\n'
  echo ""
else
  echo "ERROR: keys/payglocal_private_key not found"
fi
echo ""
echo ""

echo "--- Configuration 2 ---"
echo ""
echo "PAYGLOCAL_PUBLIC_KEY2_CONTENT:"
if [ -f "keys2/payglocal_public_key2" ]; then
  cat keys2/payglocal_public_key2 | tr '\n' '\\n'
  echo ""
else
  echo "ERROR: keys2/payglocal_public_key2 not found"
fi
echo ""

echo "PAYGLOCAL_PRIVATE_KEY2_CONTENT:"
if [ -f "keys2/payglocal_private_key2" ]; then
  cat keys2/payglocal_private_key2 | tr '\n' '\\n'
  echo ""
else
  echo "ERROR: keys2/payglocal_private_key2 not found"
fi
echo ""
echo ""

echo "--- Configuration 3 ---"
echo ""
echo "PAYGLOCAL_PRIVATE_KEY3_CONTENT:"
if [ -f "keys3/payglocal_private_key3" ]; then
  cat keys3/payglocal_private_key3 | tr '\n' '\\n'
  echo ""
else
  echo "ERROR: keys3/payglocal_private_key3 not found"
fi
echo ""
echo ""

echo "=========================================="
echo "Next Steps:"
echo "1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables"
echo "2. Add each *_CONTENT variable above with the corresponding value"
echo "3. Select: Production, Preview, and Development"
echo "4. Add all other variables from .env file (API keys, merchant IDs, etc.)"
echo "5. Redeploy your project"
echo "=========================================="
