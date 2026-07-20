# Deployment Guide

## Prerequisites

- Flutter 3.24+
- Firebase CLI
- OpenAI API key
- Android Studio (for Android builds)
- Xcode (for iOS builds)

## Initial Setup

```bash
# Clone the repository
git clone https://github.com/your-username/my-parents-story.git
cd my-parents-story

# Install dependencies
flutter pub get

# Copy environment file
cp .env.example .env

# Configure Firebase
flutterfire configure
```

## Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable the following services:
   - Authentication (Anonymous sign-in)
   - Cloud Firestore
   - Cloud Storage
   - Analytics
3. Run `flutterfire configure` to generate config files
4. Set up Firestore security rules (see docs/Security.md)

## Environment Configuration

Edit `.env` with your credentials:

```env
OPENAI_API_KEY=sk-your-key-here
```

Firebase configuration is handled by `flutterfire configure`.

## Building for Android

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### Play Store Bundle
```bash
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Building for iOS

### Development
```bash
flutter build ios --debug --codesign
```

### Release
```bash
flutter build ios --release
```

### Archive for App Store
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as build target
3. Product → Archive
4. Follow App Store submission workflow

## Play Store Deployment

1. Build AAB: `flutter build appbundle --release`
2. Sign with release keystore
3. Upload to [Google Play Console](https://play.google.com/console)
4. Complete store listing
5. Submit for review

## App Store Deployment

1. Build iOS archive in Xcode
2. Validate in Organizer
3. Upload to [App Store Connect](https://appstoreconnect.apple.com)
4. Complete store listing
5. Submit for review

## Post-Deployment

1. Enable Firebase App Check
2. Set up monitoring alerts
3. Configure crash reporting
4. Review analytics data
5. Plan feature updates

## Troubleshooting

### Build Fails
- Run `flutter clean && flutter pub get`
- Verify Firebase config files exist
- Check `.env` file is present

### Firebase Errors
- Verify project ID matches
- Check security rules
- Confirm services are enabled

### iOS Signing Issues
- Verify Apple Developer account
- Check provisioning profiles
- Validate certificates
