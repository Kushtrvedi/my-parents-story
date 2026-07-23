# Browser Capability Verification

The platform architecture relies heavily on progressive enhancement. We cannot assume every device supports the same web APIs.

---

## 1. Required Capabilities
Before allowing a user into specific flows, the application must explicitly validate support for:
- **Speech Recognition:** Web Speech API (`window.SpeechRecognition` or `window.webkitSpeechRecognition`).
- **Speech Synthesis:** (For "Ask Grandpa" Voice Interface).
- **Audio Recording:** `MediaRecorder` API.
- **IndexedDB:** Required for Hive/local storage persistence.
- **Service Worker / PWA Install:** Required for offline mode and native-app feel.

## 2. Browser AI Detection (Tier 2 Engine)
If the user's device supports Chrome's Prompt API and Gemini Nano:
- Detect via `window.ai.languageModel.capabilities()`.
- Check availability states: `available`, `downloadable`, `downloading`, `unavailable`.
- Trigger model download if needed before enabling on-device AI.

## 3. Graceful Fallbacks
The architecture must prove that every unsupported feature falls back cleanly:
- **No Web Speech API:** Disable voice recording; show keyboard-only input gracefully.
- **No Browser AI:** Fallback to Tier 1 (Curated Conversation Engine) or Tier 3 (Cloud API, if connected).
- **No IndexedDB:** Fatal error; show a friendly "Unsupported Browser" screen explaining the requirement for local privacy.
