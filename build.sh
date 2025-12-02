#!/bin/bash
set -e

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
  echo "Installing Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
  export PATH="$PATH:$(pwd)/flutter/bin"
fi

# Verify Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Build for web
flutter build web --release

echo "Build complete! Output in build/web/"

