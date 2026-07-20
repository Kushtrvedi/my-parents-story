#!/bin/bash

# Deploy script
# Builds and prepares for release

set -e

echo "=============================="
echo "My Parents' Story - Deploy"
echo "=============================="
echo ""

# Run tests
echo "Running tests..."
flutter test

# Run analyzer
echo ""
echo "Running analyzer..."
flutter analyze

# Build release
echo ""
echo "Building release APK..."
flutter build apk --release

echo ""
echo "=============================="
echo "Deployment preparation complete!"
echo ""
echo "Artifacts:"
echo "  APK: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "To deploy:"
echo "  1. Android: Upload APK to Play Console or share directly"
echo "  2. iOS: Archive in Xcode and submit to App Store Connect"
echo "=============================="
