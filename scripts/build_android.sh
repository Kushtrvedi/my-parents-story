#!/bin/bash

# Build Android APK

set -e

echo "Building Android APK..."

flutter clean
flutter pub get
flutter build apk --release

echo ""
echo "Build complete!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
