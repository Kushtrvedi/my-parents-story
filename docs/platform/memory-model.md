# Memory Model

## Overview

The Memory model is the central data structure in My Parents' Story. Each memory represents a single recorded response to a question, and carries rich metadata that enables timeline, search, relationships, and quality scoring.

## Schema (v1.0.0)

```
Memory {
  id: String              // {profileId}_{chapterId}_{questionId}
  parentId: String        // references ParentProfile
  chapterId: String       // ch01-ch20
  questionId: String      // ch##_##
  
  // Immutable input
  originalRecording: VoiceRecording?
  originalTranscript: String?
  createdAt: DateTime
  language: String
  schemaVersion: String   // "1.0.0"
  
  // Editable enrichments
  version: int
  memoir: Memoir?
  tags: List<String>
  photos: List<Photo>
  people: List<String>    // extracted or user-identified
  places: List<String>    // extracted or user-identified
  followUps: List<String>
  translations: Map<String, String>
  metadata: Map<String, dynamic>
}
```

## Lifecycle

1. **Created** — user answers a question (voice or text)
2. **Enriched** — people, places, tags identified
3. **Memoir** — polished text generated from transcript
4. **Scored** — internal quality score calculated
5. **Linked** — connected to related memories via people/places
6. **Exported** — included in generated book

## Versioning

Each memory has a `version` counter incremented on edits. The `schemaVersion` field tracks data model compatibility for future migrations.

## Idempotency

Memory IDs are deterministic: `{profileId}_{chapterId}_{questionId}`. Re-answering the same question overwrites the previous memory, preserving edit history through the `version` counter.
