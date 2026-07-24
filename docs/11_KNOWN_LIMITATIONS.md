# 11. Known Limitations (Family Beta)

This document tracks known limitations and expected behaviors across platforms during the Family Beta phase. Use this to help beta testers distinguish between actual bugs and platform-specific constraints.

## Browser Capabilities & Speech Recognition
* **Safari (iOS / macOS):** Speech-to-text relies on Apple's native dictation, which may limit continuous listening duration and can sometimes pause unexpectedly when the user stops speaking.
* **Chrome (Android / Desktop):** Uses Google's cloud speech recognition engine. It generally provides the most stable long-form dictation experience for this application.
* **Microphone Permissions:** If a user denies microphone permissions initially, they must manually re-enable them in their browser's site settings. The app cannot force the prompt to appear again.

## AI & Offline Capabilities
* **Browser AI Availability:** Local AI features (like summarizing stories without cloud calls) require WebGPU or specific flags in Chrome (e.g., Gemini Nano in Chrome Canary). Most standard mobile browsers will gracefully fall back to Cloud AI.
* **Offline Constraints:** The app is designed as a PWA (Progressive Web App). If the user loses internet connection, they can continue recording and saving memories *locally* via Hive storage. However, they cannot sync to Google Drive or generate the final AI-powered Legacy Book until they reconnect.

## Google Drive Integration
* **Permissions:** When signing in with Google to backup memories, the app requests minimal permissions (app folder only). However, strict browser pop-up blockers might prevent the OAuth window from opening. Users should be advised to allow pop-ups for the app domain.

## PWA Installation
* **iOS (Safari):** Users must manually tap "Share" > "Add to Home Screen". There is no automatic prompt.
* **Android (Chrome):** An "Install App" banner should appear automatically.
* **Updates:** Service Workers cache the application for offline use. When a new version is deployed, users may need to close and reopen the app (or force refresh) to see the latest updates.

## Deep Linking & Navigation
* **Browser Refresh:** Manually refreshing the browser while deep within a nested route (e.g., `/myparents/#/journey`) might reset state if the local storage cache hasn't flushed recently. Users are encouraged to use in-app navigation buttons.
