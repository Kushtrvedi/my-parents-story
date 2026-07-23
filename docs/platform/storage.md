# Storage

## Overview

Local-first storage using Hive. No cloud, no network, no accounts.

## Boxes

| Box | Contents |
|-----|----------|
| profiles | ParentProfile data |
| responses | Memory data (transcripts, memoirs, metadata) |
| chapters | Generated chapter content |
| settings | App preferences, milestones |

## Key Design Decisions

- **No cloud sync** — data never leaves the device
- **No accounts** — no authentication, no user IDs
- **Deterministic IDs** — memory IDs are `{profileId}_{chapterId}_{questionId}`
- **Schema versioning** — each memory carries `schemaVersion` for future migrations
- **Overwrite semantics** — re-answering a question overwrites the previous response

## Data Safety

- Hive stores data in binary format on device
- Backup/export creates JSON snapshots
- No encryption at rest (device-level encryption recommended)
- No automatic cleanup — user controls deletion

## Migration Strategy

When schema changes:
1. Increment `schemaVersion` in Memory model
2. Add migration function in `StorageService`
3. Migrate on first access after update
4. Preserve original data until migration confirmed
