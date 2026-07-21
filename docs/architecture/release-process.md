# Release Process

## Version Numbering

```
vMAJOR.MINOR.PATCH
v0.1.0-alpha    ← current
v0.2.0-beta     ← next
v1.0.0          ← first stable release
```

## Pre-Release Checklist

### Alpha (v0.1.0)
- [x] Core architecture complete
- [x] 300 questions across 20 chapters
- [x] Voice recording + TTS
- [x] Template book generation
- [x] PDF export
- [x] 4 languages (EN, HI, GU, ES)
- [x] 26 tests passing
- [x] Documentation complete

### Beta (v0.2.0)
- [ ] Memory timeline
- [ ] Memory relationships
- [ ] Search engine
- [ ] Duplicate detection
- [ ] Autosave + recovery
- [ ] Book versioning
- [ ] Archive integrity
- [ ] Recovery system
- [ ] Quality scoring
- [ ] 90% test coverage
- [ ] No analyzer warnings
- [ ] Release build verified

### Stable (v1.0.0)
- [ ] Closed beta with families
- [ ] Accessibility audit passed
- [ ] Performance validated on low-end devices
- [ ] All beta feedback incorporated
- [ ] App Store assets ready

## Build Process

```bash
# Debug
flutter run

# Release (Android)
flutter build apk --release

# Release (iOS)
flutter build ipa --release

# Test
flutter test
flutter analyze
```

## Post-Release

- Monitor crash reports
- Collect user feedback
- Plan next version
