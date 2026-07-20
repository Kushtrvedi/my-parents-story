#!/bin/bash

# Build Android AAB for Play Store

set -e

echo "Building Android App Bundle..."

flutter clean
flutter pub get
flutter build appbundle --release

echo ""
echo "Build complete!"
echo "AAB location: build/app/outputs/bundle/release/app-release.aab"
