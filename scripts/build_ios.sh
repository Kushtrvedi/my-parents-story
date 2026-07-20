#!/bin/bash

# Build iOS

set -e

echo "Building iOS..."

flutter clean
flutter pub get
flutter build ios --release --no-codesign

echo ""
echo "Build complete!"
echo "Open ios/Runner.xcworkspace in Xcode to archive and submit."
