# Backup & Restore

## Overview

Export/import system for data portability. Every backup includes integrity checks.

## Backup Format

```json
{
  "magic": "MPS_BACKUP_V1",
  "version": "1.0",
  "schemaVersion": "1.0.0",
  "appVersion": "0.1.0-alpha",
  "exportedAt": "2026-07-21T...",
  "language": "en",
  "checksum": "a1b2c3d4",
  "profiles": {...},
  "responses": {...},
  "chapters": {...}
}
```

## Integrity Checks

1. **Magic header** — verifies file is MPS backup
2. **Schema version** — checks compatibility
3. **Checksum** — detects corruption
4. **Field validation** — ensures required fields exist

## Recovery Scenarios

| Scenario | Handling |
|----------|----------|
| Missing profiles | Import profiles only |
| Missing responses | Import responses only |
| Schema mismatch | Warn user, attempt migration |
| Checksum fail | Warn user, offer partial restore |
| Empty backup | Reject with clear error |

## Export Formats

- **JSON** — full backup with all metadata
- **PDF** — generated memoir book (separate from backup)

## Future

- Encrypted backups
- Selective export (single profile)
- Cloud backup (opt-in)
