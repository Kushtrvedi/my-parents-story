# SPEECH_SETUP_REPORT.md

## Speech Recognition Experience — Zero API Mode

### Supported Devices

| Feature | Requirement |
|---|---|
| Platform | Android 5.0+ (API 21+) |
| Speech Recognition | Google Speech Services or device-native |
| On-device Recognition | Android 12+ (API 31+) with Google app |
| Offline Language Packs | Downloadable via Google app settings |
| Microphone | Hardware microphone required |

### Detection Flow

```
App Start
  ↓
Check Setup Complete (Hive settings)
  ↓
If not complete → SetupWizardScreen
  ↓
Step 1: Microphone Permission
  Permission.microphone.request()
  ↓
Step 2: Speech Recognition Available
  SpeechToText.initialize()
  ↓
Step 3: On-device Recognition
  SpeechToText.isOnDeviceRecognitionAvailable()
  ↓
Step 4: Installed Languages
  SpeechToText.locales()
  ↓
Step 5: Offline Language Check
  Match locale against installed languages
  ↓
All Ready → Device Readiness Check (green checkmarks)
  ↓
Start My Parent's Story
```

### Installation Flow

#### Speech Recognition Unavailable
1. Display calm setup page: "Voice Recognition Required"
2. Button: "Install Voice Recognition"
3. Opens Android Settings → Speech Recognition
4. User installs Google Speech Services
5. Returns to app → Automatic re-check

#### Language Pack Missing
1. Display prompt: "Download offline speech recognition for Hindi?"
2. Button: "Download Language Pack"
3. Opens Android Settings → Language & Input → Speech
4. User downloads language pack
5. Returns to app → Automatic verification

### Offline Behavior

- **On-device available**: Always prefer on-device recognition
- **Cloud only**: Inform user about temporary internet dependency
- **No recognition available**: Guide to install Google Speech Services

### User Experience

#### First Launch
1. Welcome screen with emotional message
2. Setup wizard (4 steps, gentle animations)
3. Device Readiness Check with green checkmarks:
   - ✅ Microphone ready
   - ✅ Speech recognition available
   - ✅ Offline language installed
   - ✅ Storage ready
4. "Start My Parent's Story" button

#### Subsequent Launches
1. Welcome back message
2. Continue where left off option
3. Start new story option
4. Language picker

### Edge Cases

| Scenario | Handling |
|---|---|
| Microphone denied | Show recovery button, explain why needed |
| Speech unavailable | Guide to install Google Speech Services |
| Language missing | Guide to download language pack |
| No internet + cloud only | Inform user, recordings still saved locally |
| Device too old | Show calm message, suggest using another device |
| App backgrounded | Stop recording, save partial transcript |

### Files Modified

| File | Change |
|---|---|
| `lib/services/speech_setup_service.dart` | **NEW** — Device detection, permission handling, language checking |
| `lib/screens/setup_wizard_screen.dart` | **NEW** — 4-step guided setup with readiness check |
| `lib/screens/landing_screen.dart` | **REWRITTEN** — Welcome back, continue-later, language picker |
| `lib/screens/question_screen.dart` | **REWRITTEN** — Voice instructions, memory pause, break reminder |
| `lib/screens/pre_question_screen.dart` | **UPDATED** — Family assistant mode toggle |
| `lib/screens/life_journey_screen.dart` | **UPDATED** — Family mode toggle in app bar |
| `lib/screens/celebration_screen.dart` | **NEW** — "Today you preserved a lifetime" |
| `lib/design_system/touch_targets.dart` | **UPDATED** — 72dp minimum touch targets |
| `lib/l10n/translations.dart` | **UPDATED** — 37 new keys × 12 languages |
| `android/.../MainActivity.kt` | **UPDATED** — MethodChannel for settings |
