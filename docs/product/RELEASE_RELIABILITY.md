# Release Reliability Matrix

This document outlines the manual verification steps required before any production release of "My Parents' Story".

## 1. Recording Reliability
The most critical part of the app. A parent must never lose a story they are in the middle of telling.
- [ ] **Interruption (Phone Call):** Start recording. Call the device. Verify recording pauses or saves without crashing.
- [ ] **Notification:** Receive a push notification or SMS while recording.
- [ ] **Lock Screen:** Turn off the screen while recording. Turn it back on. Verify state.

## 2. Storage & Lifecycle
Ensure data persistence handles edge cases gracefully.
- [ ] **Low Disk Space:** Trigger a recording when the device has < 50MB free. Ensure it fails gracefully with a localized error message.
- [ ] **Uninstall/Reinstall:** Verify that local data is completely wiped, but restoring from an exported backup `.json` brings everything back correctly.
- [ ] **App Sent to Background:** Go to the home screen while recording. Return. Verify recording paused.
- [ ] **App Force-Closed:** Kill the app via the task switcher. Reopen. Verify the app boots normally and no previously saved data is corrupted.

## 3. Device Compatibility
- [ ] **Android 10 - 13+:** Verify permissions do not crash the app on older versions, and that Android 13+ does not prompt for broad storage permissions.
- [ ] **Tablets / Foldables:** Ensure the UI scales correctly (font sizes remain legible, no overflow errors).
- [ ] **Orientation:** If orientation changes are supported, rotate the device during recording and playback.

## 4. Performance & Scalability
- [ ] **Long Recordings:** Record continuously for 10+ minutes.
- [ ] **Large Memoir Generation:** Generate a PDF book with 50+ memories and 10+ photos. Verify memory usage and successful export.
- [ ] **Hundreds of Memories:** Ensure the timeline and chapter lists scroll smoothly without jank.
