#!/bin/bash

# Script to start Vercel dev server

echo "🚀 Starting Vercel dev server..."
echo "📁 Current directory: $(pwd)"
echo ""

# Check if vercel is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Error: Vercel CLI not found!"
    echo "   Please install it with: npm install -g vercel"
    exit 1
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo "⚠️  Warning: .env.local not found"
    echo "   Run ./setup-env.sh first to create it"
    echo ""
fi

echo "✅ Starting server..."
echo "   This will start on http://localhost:3000 (or another port if 3000 is busy)"
echo "   Press Ctrl+C to stop the server"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start vercel dev
vercel dev

