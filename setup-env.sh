#!/bin/bash

# Script to set up .env.local from backend/.env

echo "Setting up .env.local for local testing..."

if [ -f "backend/.env" ]; then
    echo "Found backend/.env file"
    
    # Read the relevant variables from backend/.env
    source backend/.env
    
    # Create .env.local with the required variables
    cat > .env.local << EOF
# Auto-generated from backend/.env for Vercel local testing
PAYGLOCAL_API_KEY=${PAYGLOCAL_API_KEY}
PAYGLOCAL_MERCHANT_ID=${PAYGLOCAL_MERCHANT_ID}
PAYGLOCAL_PUBLIC_KEY_ID=${PAYGLOCAL_PUBLIC_KEY_ID}
PAYGLOCAL_PRIVATE_KEY_ID=${PAYGLOCAL_PRIVATE_KEY_ID}
PAYGLOCAL_Env_VAR=${PAYGLOCAL_Env_VAR:-uat}
PAYGLOCAL_LOG_LEVEL=${PAYGLOCAL_LOG_LEVEL:-debug}

# Key file paths (relative to project root)
PAYGLOCAL_PUBLIC_KEY=backend/keys/payglocal_public_key
PAYGLOCAL_PRIVATE_KEY=backend/keys/payglocal_private_key
EOF
    
    echo "✅ Created .env.local file"
    echo "📝 Please review and adjust if needed"
else
    echo "❌ backend/.env file not found"
    echo "Please create .env.local manually with your credentials"
fi

