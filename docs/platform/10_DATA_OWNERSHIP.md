# 10. Data Ownership Constitution

This document defines the core principles governing user data, establishing the trust model between the platform and the families who use it. 

## 1. Absolute Ownership
*   **Families own 100% of their memories.**
*   No ownership of content is transferred to the platform, ever.
*   Users have the irrevocable right to permanently delete all data at any time.

## 2. Unrestricted Portability
Families must never be locked into this ecosystem. The platform guarantees the ability to export:
*   **JSON Backup Payload** (The raw Life Graph data structure)
*   **The Legacy Book** (Print-ready PDF / Paged HTML)
*   **Original Audio Recordings** (If configured to persist locally)
*   **Asset Library Images/Documents**

*As future archive formats are developed, they will be provided as standard export capabilities.*

## 3. Total Transparency
Families must always know exactly where their deeply personal stories reside.

*   **Local Storage:** The primary source of truth (the Hive database) lives *only* on the user's physical device.
*   **Cloud Processing:** Speech-to-text processing depends on browser capabilities. If a device lacks an offline language pack, the browser may send audio clips to its respective cloud provider (e.g., Google or Apple) purely for transcription. Audio is never stored by our platform.
*   **Cloud Synchronization:** Synchronization only occurs if the user explicitly authorizes it.

## 4. Privacy-First Syncing
The platform utilizes the **Google Drive AppData folder** for cloud backups.
*   This is a hidden, application-specific directory inside the user's *own* personal Google account.
*   Backups remain securely under the user's jurisdiction rather than residing on our centralized servers.
*   Files in this folder cannot be accidentally shared or seen in the normal Drive UI, protecting sensitive family conversations.

---

*This constitution ensures that the platform acts solely as a facilitator for preserving family history, never as a custodian holding memories hostage.*
