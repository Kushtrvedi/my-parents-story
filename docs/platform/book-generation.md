# Book Generation

## Overview

Template-based memoir generation. No AI, no API, no network required.

## Process

1. User selects "Create my book"
2. System gathers all memories for the profile
3. Each chapter is composed from:
   - Chapter introduction (template)
   - User responses (transcript or memoir)
   - Follow-up responses
   - Chapter transition (template)
4. Final letter is generated from template
5. Book is assembled as GeneratedChapter objects
6. PDF is exported from assembled content

## Book Structure

```
Cover Page
  - Title: "A Life Story"
  - Subtitle: "{Name}'s Memoir"
  
Table of Contents
  - Auto-generated from chapters

Chapters (20)
  - Chapter title
  - Chapter introduction
  - User responses (as memoir text)
  - Chapter transition

Final Letter
  - "What I Hope My Family Remembers"
  
Back Cover
  - Generated date
  - Version info
```

## Versioning

Each generated book is saved as a version:
- `book_v1` — first generation
- `book_v2` — after adding more memories
- etc.

Users can regenerate as many times as they want.

## PDF Export

- Uses dart:pdf (completely offline)
- Premium typography
- Supports all 4 languages
- File size: ~100-500KB depending on content
