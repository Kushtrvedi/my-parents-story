# Release Checklist

This checklist must be completed for every production release to ensure the stability and quality of the oral-history platform.

---

## 1. Pre-Deployment (Automated via CI)
- [ ] `flutter analyze` passed.
- [ ] `flutter test` passed.
- [ ] `flutter build web` passed.
- [ ] Lighthouse audit passed Performance Budget.
- [ ] Vercel Preview URL generated.

## 2. Real Device Testing (Manual QA)
Do not rely solely on responsive browser emulation. Browser APIs—especially speech recognition and AI capabilities—can differ significantly across platforms.

Test the Vercel Preview URL on:
- [ ] Windows (Chrome / Edge)
- [ ] macOS (Safari / Chrome)
- [ ] Android Phone (Chrome)
- [ ] Android Tablet (Chrome)
- [ ] iPhone (Safari)
- [ ] iPad (Safari)

## 3. Post-Deployment Verification (Production)
Immediately after the production release, verify the following:
- [ ] 404 Errors (Ensure Vercel SPA routing `vercel.json` is working)
- [ ] 500 Errors
- [ ] Broken Assets (Fonts, Icons, Images)
- [ ] Manifest (PWA installability)
- [ ] Service Worker (Offline caching)
- [ ] Offline Mode (Disconnect network and load)
- [ ] PDF Export / Memoir Generation
- [ ] Conversation Mode (Speech-to-text recording)
- [ ] Life Graph (Metadata extraction)
- [ ] Book Generation

## 4. Observability Checks
Review production logs and telemetry for:
- [ ] JavaScript console errors
- [ ] Network request failures
- [ ] Unhandled exceptions
- [ ] Flutter framework errors
- [ ] Browser compatibility warnings
- [ ] Asset loading failures
