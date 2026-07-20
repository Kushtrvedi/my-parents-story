# Voice System

## Overview

The voice system enables hands-free memory capture through speech-to-text transcription.

## Architecture

```
User speaks
    ↓
Microphone captures audio
    ↓
Speech-to-Text engine processes
    ↓
Transcript displayed in real-time
    ↓
User stops recording
    ↓
Transcript saved as answer
```

## Implementation

### Speech-to-Text Service

Uses `speech_to_text` package with:
- Real-time transcription
- Locale support (en_US default)
- 5-minute max recording
- 3-second pause detection
- Error handling

### Permissions

**Android** (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

**iOS** (Info.plist):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone to record your voice memories.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We use speech recognition to convert your spoken memories into text.</string>
```

## User Experience

### Recording State
- Microphone icon turns red
- "Recording..." indicator shown
- Live transcript displayed
- Tap to stop

### After Recording
- Transcript appears in text field
- User can edit before saving
- Combined with any typed text

## Limitations

- Requires internet for Google Speech Recognition
- Background noise affects accuracy
- Some accents may have lower accuracy
- Maximum 5 minutes per recording

## Fallback

If speech-to-text unavailable:
- Voice button disabled
- Text input remains functional
- User informed of limitation

## Future Enhancements

- On-device speech recognition
- Multiple language support
- Audio playback of recordings
- Word-level timestamps
- Sentiment analysis
