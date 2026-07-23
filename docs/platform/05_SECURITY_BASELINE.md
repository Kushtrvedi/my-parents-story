# Security Baseline

This document outlines the security requirements and architecture for the My Parents' Story platform.

---

## 1. On-Device Privacy Architecture
The application is designed around absolute family privacy.
- **Local Storage First:** All Life Graph data (Memories, Entities) is stored locally using IndexedDB (Hive/Isar) on the Web.
- **No Unintended Uploads:** Audio recordings and generated memoirs remain on the user's device unless explicitly shared.
- **API Keys:** We do not ask users to paste API keys. Cloud capabilities (Gemini Cloud API) are securely routed and managed via our own authenticated backend infrastructure (when implemented), or bypassed entirely if the user chooses local-only models.

## 2. Infrastructure Security
- **DNS & SSL:** `reyouos.com` and all subdomains must enforce strict HTTPS. Vercel automatically provisions and renews SSL certificates.
- **Headers:** Vercel routes must configure security headers (e.g., `Strict-Transport-Security`, `X-Content-Type-Options`).

## 3. Threat Model Considerations
- **Data Loss:** Because the application relies heavily on local storage for the Family Beta, the primary threat is data loss (e.g., user clears browser cache). The UI must emphasize exporting backups via `backup_service.dart`.
- **Third-Party Integrations:** All third-party plugins (e.g., `speech_to_text`) must be audited for data exfiltration risks. The Web Speech API operates via the browser, which may use cloud services (like Google or Apple dictation) depending on the OS/Browser combination. The user must be informed of this via the Privacy Trust translation (`privacyTrust`).
