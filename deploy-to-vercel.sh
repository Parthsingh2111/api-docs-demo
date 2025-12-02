#!/bin/bash
# Script to build Flutter web and deploy to Vercel

echo "Building Flutter web app..."
flutter build web --release

if [ $? -eq 0 ]; then
  echo "✓ Build successful!"
  echo ""
  echo "To deploy to Vercel:"
  echo "1. Install Vercel CLI: npm i -g vercel"
  echo "2. Run: vercel --prod"
  echo ""
  echo "Or use the Vercel dashboard and point it to the build/web directory"
else
  echo "✗ Build failed!"
  exit 1
fi

