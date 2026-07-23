#!/bin/bash
# Vercel Build Script for Flutter Web

echo "=== Cloning Flutter SDK ==="
git clone https://github.com/flutter/flutter.git -b stable --depth 1

echo "=== Exporting Flutter Path ==="
export PATH="$PATH:`pwd`/flutter/bin"

echo "=== Getting Dependencies ==="
flutter precache
flutter pub get

echo "=== Building Flutter Web ==="
# Building with base-href to support the /myparentsapp subpath deployment
flutter build web --release --base-href /myparentsapp/

echo "=== Restructuring for Vercel ==="
mkdir -p build/vercel_output/myparentsapp
cp -r build/web/* build/vercel_output/myparentsapp/

echo "=== Build Complete ==="
