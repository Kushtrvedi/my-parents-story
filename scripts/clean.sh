#!/bin/bash

# Clean script
# Removes build artifacts and caches

set -e

echo "Cleaning project..."

flutter clean

# Remove platform-specific caches
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -rf android/.gradle
rm -rf build
rm -rf .dart_tool

echo "Clean complete!"
echo "Run 'flutter pub get' to reinstall dependencies."
