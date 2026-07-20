#!/bin/bash

# Setup script for My Parents' Story
# This script sets up the development environment

set -e

echo "=============================="
echo "My Parents' Story - Setup"
echo "=============================="
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "Error: Flutter is not installed."
    echo "Install from: https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "Flutter found: $(flutter --version | head -1)"

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "Installing Firebase CLI..."
    npm install -g firebase-tools
fi

echo "Firebase CLI found: $(firebase --version)"

# Install dependencies
echo ""
echo "Installing Flutter dependencies..."
flutter pub get

# Setup environment
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file from template..."
    cp .env.example .env
    echo ""
    echo "Please edit .env and add your OPENAI_API_KEY"
fi

# Configure Firebase
echo ""
echo "Configuring Firebase..."
echo "If you haven't created a Firebase project yet, do so at:"
echo "https://console.firebase.google.com"
echo ""
read -p "Run flutterfire configure? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    flutterfire configure
fi

echo ""
echo "=============================="
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env and add your OpenAI API key"
echo "2. Run: flutter run"
echo "=============================="
