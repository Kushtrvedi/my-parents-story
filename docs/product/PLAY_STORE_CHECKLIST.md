# Google Play Store Release Checklist

Before uploading the `.aab` (Android App Bundle) to the Google Play Console for a public or closed beta release, ensure every item on this checklist is completed.

## 1. App Configuration & Security
- [ ] **Versioning:** Update `version` in `pubspec.yaml` (e.g., `1.0.0+1`).
- [ ] **App Signing:** Generate a secure Keystore and configure `build.gradle` for release signing.
- [ ] **Minification & Obfuscation:** Ensure `shrinkResources` and `minifyEnabled` are set to true (or handled via Flutter's `--obfuscate` flag).
- [ ] **Permissions:** Verify `AndroidManifest.xml` does NOT contain `READ_EXTERNAL_STORAGE` or `WRITE_EXTERNAL_STORAGE`.

## 2. Store Listing Assets
- [ ] **App Icon:** 512x512 PNG, high resolution, follows Google Play icon design specifications.
- [ ] **Feature Graphic:** 1024x500 PNG. Must convey the emotional legacy/gift aspect of the app without relying on UI screenshots.
- [ ] **Screenshots:** Minimum of 4 screenshots showing:
  1. The Landing/Welcome screen.
  2. The Profile selection screen.
  3. The Question / Recording screen.
  4. The generated Memoir/PDF or Sharing quote screen.
- [ ] **Title & Description:** 
  - Short Description (80 chars): e.g., "Help your parents preserve their life story, one memory at a time."
  - Full Description: Highlight privacy, local-first storage, and the "gift" philosophy.

## 3. Privacy & Policy Compliance
- [ ] **Privacy Policy URL:** Must be hosted publicly. The policy MUST state that all audio and text data remains completely local on the device and is never uploaded to external servers.
- [ ] **Data Safety Form:** 
  - Fill out the Google Play Data Safety section.
  - Declare that no user data (audio, photos, text) is collected or shared.
- [ ] **Target Audience:** Set the target age group accurately (likely 18+, as this is an app for adults interviewing their parents).

## 4. Release & Rollout Strategy
- [ ] **Closed Beta:** Invite 10-20 target users (aged 55-85 and their children). Observe usability before public launch.
- [ ] **Release Notes:** Write clear, localized release notes ("What's New") for the update.
- [ ] **Staged Rollout:** For public releases, start at 10% rollout to monitor for unexpected crashes using Google Play Vitals.
