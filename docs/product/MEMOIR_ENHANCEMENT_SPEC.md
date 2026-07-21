# MEMOIR ENHANCEMENT SPEC

**Date**: 2026-07-21
**Status**: FINAL SPEC — Ready for implementation

---

## Executive Summary

Transform the current PDF export into a professionally designed memoir that families would proudly print and keep on a bookshelf. The memoir should feel like a precious family heirloom, not a document.

---

## Premium Memoir Structure

```
┌─────────────────────────────┐
│  Cover                      │
│  (Title, parent name, photo)│
├─────────────────────────────┤
│  Dedication                 │
│  (From the person recording)│
├─────────────────────────────┤
│  Photograph                 │
│  (Full-page portrait)       │
├─────────────────────────────┤
│  About My Parent            │
│  (Brief biography)          │
├─────────────────────────────┤
│  Life Timeline              │
│  (Visual chapter overview)  │
├─────────────────────────────┤
│  Chapter 1: Childhood       │
│  Chapter 2: Family          │
│  Chapter 3: Education       │
│  Chapter 4: Career          │
│  Chapter 5: Marriage        │
│  Chapter 6: Parenthood      │
│  Chapter 7: Challenges      │
│  Chapter 8: Values          │
│  ...                        │
│  Chapter 19: Life Lessons   │
│  Chapter 20: Wisdom         │
├─────────────────────────────┤
│  Life Lessons               │
│  (Distilled wisdom)         │
├─────────────────────────────┤
│  Letter to Children         │
│  (Heartfelt message)        │
├─────────────────────────────┤
│  Letter to Grandchildren    │
│  (Future generations)       │
├─────────────────────────────┤
│  Favourite Quotes           │
│  (Words they live by)       │
├─────────────────────────────┤
│  Signature                  │
│  ("With love, [name]")      │
├─────────────────────────────┤
│  Edition Page               │
│  (Date, app, recorded by)   │
├─────────────────────────────┤
│  Legacy Page                │
│  ("Your Legacy Lives On")   │
│  (Portrait, signature, date)│
│  (No app branding)          │
└─────────────────────────────┘
```

---

## Feature Priority Matrix

### v1.0 — Before Play Store Launch

| # | Feature | Priority | Status |
|---|---------|----------|--------|
| 1 | Premium Memoir Book Design | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 2 | Answer Review & Edit Flow | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 3 | Parent Photograph | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 4 | Parent Signature | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 5 | Edition & Timestamp Page | ⭐⭐⭐⭐☆ | ☑ Spec Complete |
| 6 | Chapter Review Before Final Book | ⭐⭐⭐⭐☆ | ☑ Spec Complete |
| 7 | Beautiful Cover Design | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 8 | Letter to Children | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 9 | Letter to Grandchildren | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 10 | Favourite Quotes Page | ⭐⭐⭐⭐☆ | ☑ Spec Complete |
| 11 | Memory Approval Ceremony | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 12 | Legacy Page | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 13 | Book Preview & Flip-Through | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |
| 14 | Enhanced Chapter Review | ⭐⭐⭐⭐⭐ | ☑ Spec Complete |

### v1.1 — After Launch

| # | Feature | Priority |
|---|---------|----------|
| 1 | AI Follow-up Questions | ⭐⭐⭐⭐⭐ |
| 2 | Family Collaboration | ⭐⭐⭐⭐☆ |
| 3 | Multiple Contributors | ⭐⭐⭐⭐☆ |
| 4 | QR Codes Linking to Voice Recordings | ⭐⭐⭐⭐☆ |
| 5 | Hardcover Print Export | ⭐⭐⭐☆☆ |
| 6 | Family Tree Generator | ⭐⭐⭐☆☆ |
| 7 | Video Memories | ⭐⭐⭐☆☆ |
| 8 | Interactive ePub Export | ⭐⭐⭐☆☆ |

---

## Feature 1: Premium Memoir Book Design

### Current State
Basic PDF with simple text layout.

### Target State
Professionally typeset memoir that feels like a published book.

### Book Components

#### Cover
- Parent's name in elegant serif typography
- Full-page portrait photo
- Subtitle: "A Life Story"
- Decorative border or frame
- Warm cream background (#FAF8F5)

#### Dedication
- "For [family member]"
- Simple, centered
- Optional personal message

#### Photograph Page
- Full-page portrait
- Caption: "[Name], [Year]"
- Clean white border

#### About My Parent
- Brief biography (3-5 paragraphs)
- Key life events
- Personality and values

#### Life Timeline
- Visual timeline with chapter icons
- Key milestones marked
- Clean, minimal design

#### Chapter Opener
- Chapter number in large serif font
- Chapter title
- Decorative element (small icon or rule)
- Pull quote from the chapter

#### Content Pages
- Question in italic
- Answer in clean body text
- Pull quotes highlighted in gold
- Photos embedded where available
- Generous white space

#### Chapter Close
- Decorative divider
- Page break

#### Letter to Children
- Full page
- Handwritten-style font option
- Parent's photo as watermark
- Emotional closing

#### Letter to Grandchildren
- Same format as Letter to Children
- Forward-looking, legacy-focused

#### Favourite Quotes
- 3-5 quotes the parent lives by
- Each on its own page
- Attribution below each quote

#### Signature Page
- "With love,"
- Signature image
- Parent's name
- Date

#### Edition Page
```
First Edition

Completed on
[Date]

Created using
My Parents' Story

Recorded by
[Child's name]

Location
[City, Country]
```

#### Thank You
- Closing message
- App branding subtle

### Typography

| Element | Font | Size | Color |
|---------|------|------|-------|
| Chapter titles | Playfair Display | 28pt | #3A5A40 |
| Body text | Source Sans Pro | 11pt | #1a1a1a |
| Pull quotes | Playfair Display Italic | 14pt | #D4A373 |
| Page numbers | Source Sans Pro Light | 9pt | #666666 |
| Running headers | Source Sans Pro | 8pt | #999999 |
| Letters | Lora Italic | 12pt | #1a1a1a |

### Layout Rules
- 1-inch margins all sides
- Chapter openers: 30% of page height
- Pull quotes: Centered, 60% width
- Photos: Full bleed or centered with caption
- Page numbers: Bottom center
- Running headers: Top outer edge

---

## Feature 2: Answer Review & Edit Flow

### Current State
Record → Save → Next

### Target State
Record → Transcript → Edit → Save Draft → Approve → Continue

### Flow

```
┌─────────────────┐
│  Question        │
│  "Tell me about  │
│   your childhood"│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Voice Recording │
│  (Tap to start)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Transcript      │
│  Generated       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Edit Screen     │
│  - Read transcript│
│  - Edit text     │
│  - Save draft    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Approve?        │
│  "Does this      │
│   capture your   │
│   memory?"       │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌───────┐
│ Edit  │ │ Approve│
│ Again │ │        │
└───┬───┘ └───┬───┘
    │         │
    └────┬────┘
         │
         ▼
┌─────────────────┐
│  Memory Saved   │
│  "Beautiful.     │
│   This memory    │
│   has been saved."│
└─────────────────┘
```

### Implementation

**New Screen**: `edit_answer_screen.dart`
- Text editor for transcript
- Word count display
- Save draft button
- Approve button
- "Listen to recording" button

**Storage Changes**
```dart
// Add to Memory model
String? editedTranscript;
bool isApproved;
DateTime? approvedAt;
```

**Translation Keys**
```dart
'editAnswer': 'Edit your answer',
'readTranscript': 'Read your story',
'approveAnswer': 'Does this capture your memory?',
'editAgain': 'Edit again',
'approveMemory': 'Yes, save this memory',
'memorySaved': 'Beautiful. This memory has been saved.',
```

---

## Feature 3: Parent Photograph

### Current State
No photo integration.

### Target State
Ask for photos before book generation.

### Photo Types

| Photo | Required | Used In |
|-------|----------|---------|
| Primary portrait | Yes | Cover, Photo page |
| Childhood photo | No | Chapter 1 opener |
| Wedding photo | No | Chapter 5 opener |
| Family photo | No | Chapter 6 opener |

### Flow

```
Book Preview → "Add photos to your memoir?"
  → Photo Selection
  → Choose from gallery or take photo
  → Crop/Edit
  → Confirm
  → Included in book
```

### New Screen: `photo_selection_screen.dart`

**Layout**
- Grid of photo slots
- Each slot shows:
  - Photo type (Portrait, Childhood, Wedding, Family)
  - Placeholder if empty
  - "Add photo" button
  - Preview if photo exists

**Photo Processing**
- Resize to 2400x3200 (portrait orientation)
- Compress to 85% quality
- Save to app directory

### Storage
```dart
// Add to ParentProfile
String? portraitPath;
String? childhoodPhotoPath;
String? weddingPhotoPath;
String? familyPhotoPath;
```

---

## Feature 4: Parent Signature

### Current State
No signature capture.

### Target State
Parent signs directly on screen or uploads scanned signature.

### Options

1. **Draw on screen**
   - Canvas widget
   - Black ink on white background
   - Clear/redo button
   - Save as PNG

2. **Upload from gallery**
   - Pick image
   - Crop to signature area
   - Convert to transparent PNG

### New Screen: `signature_screen.dart`

**Layout**
- Large drawing area (white background)
- "Draw your signature" instruction
- Clear button
- Save button
- "Or upload from gallery" link

### Signature Page in Book
```
With love,


[Signature Image]

Parent Name
```

### Storage
```dart
// Add to ParentProfile
String? signaturePath;
```

---

## Feature 5: Edition & Timestamp Page

### Current State
No metadata in book.

### Target State
Final page with historical context.

### Content
```
First Edition

Completed on
21 July 2026

Created using
My Parents' Story

Recorded by
[Child's name]

Location
[City, Country] (optional)
```

### Storage
```dart
// Add to Memoir model
String? recordedBy;
String? location;
DateTime completedAt;
```

### New Screen: `edition_info_screen.dart`
- Input for "Recorded by" name
- Input for location (optional)
- Auto-filled completion date

---

## Feature 6: Chapter Review Before Final Book

### Current State
All answers included automatically.

### Target State
Nothing enters the final book without approval.

### Flow

```
Chapter Complete → "Review your answers"
  → Chapter Review Screen (list of Q&A)
  → Edit any answer
  → Approve chapter
  → "Chapter locked"
  → Included in final book
```

### New Screen: `chapter_review_screen.dart`

**Layout**
- Chapter title at top
- List of Q&A pairs
- Each pair shows:
  - Question
  - Answer preview (first 100 words)
  - "Edit" button
  - "Approved" badge
- "Approve Chapter" button at bottom
- "Continue editing" link

### Storage
```dart
// Add to GeneratedChapter
bool isApproved;
DateTime? approvedAt;
```

---

## Feature 7: Letter to Children

### Current State
Not implemented.

### Target State
A heartfelt message from parent to children, placed at the emotional end of the memoir.

### Implementation

**New Question (Chapter 21)**
```
"If you could leave one message for your children,
what would it be? What do you want them to remember
about you? What wisdom do you want to pass on?"
```

**Recording Flow**
- Standard voice recording
- Transcript generated
- Editable like other answers
- Special formatting in book (handwritten-style font)

**Placement in Book**
- After "Life Lessons" chapter
- Before "Letter to Grandchildren"
- Full page, centered
- Parent's photo as subtle watermark

### Translation Keys
```dart
'letterToChildren': 'A Letter to My Children',
'letterToChildrenPrompt': 'If you could leave one message for your children, what would it be?',
'letterToGrandchildren': 'A Letter to My Grandchildren',
'letterToGrandchildrenPrompt': 'What wisdom would you pass on to grandchildren you may never meet?',
```

---

## Feature 8: Letter to Grandchildren

### Current State
Not implemented.

### Target State
A message from parent to future generations.

### Implementation

**New Question (Chapter 22)**
```
"What wisdom would you pass on to grandchildren
you may never meet? What do you want them to know
about the grandparent they never had the chance to know?"
```

**Placement in Book**
- After "Letter to Children"
- Before "Favourite Quotes"
- Same formatting as Letter to Children

---

## Feature 9: Favourite Quotes Page

### Current State
Not implemented.

### Target State
3-5 quotes the parent lives by.

### Implementation

**New Questions (Chapter 23)**
```
"What is your favourite quote or saying?"
"What words do you live by?"
"Is there a proverb or teaching that shaped your life?"
```

**Placement in Book**
- After "Letter to Grandchildren"
- Before "Signature"
- Each quote on its own page
- Attribution below

---

## Feature 10: Memory Approval Ceremony

### Current State
Chapter approved with a simple confirmation.

### Target State
A quiet, meaningful moment when a chapter is completed.

### Flow

```
Chapter Complete
  → Screen fades to warm background
  → "This chapter has now become part of your family's history."
  → Pause (2 seconds)
  → "Would you like to continue?" or "Take a break."
  → User chooses
```

### Implementation

**New Screen**: `chapter_complete_screen.dart`

**Layout**
- Warm cream background (#FAF8F5)
- Book icon centered
- Chapter title displayed
- Message: "This chapter has now become part of your family's history."
- Two buttons:
  - "Continue to next chapter" (primary)
  - "Take a break" (secondary)

**Timing**
- Message appears after 1 second pause
- Buttons appear after 2 seconds
- Gentle fade-in animation

**Translation Keys**
```dart
'chapterComplete': 'Chapter Complete',
'chapterPartOfHistory': 'This chapter has now become part of your family\'s history.',
'continueToNext': 'Continue to next chapter',
'takeBreak': 'Take a break',
'comeBackLater': 'Your progress is saved. Come back anytime.',
```

---

## Feature 11: Legacy Page

### Current State
Memoir ends with Edition Page and Thank You.

### Target State
Final page is a quiet, emotional closing with no app branding.

### Content

```
Your Legacy Lives On

Every story shared in this book is a gift to future generations.
Your voice, your memories, and your wisdom will continue
to be part of your family's story.


[Parent Portrait]

[Signature]

[Date]
```

### Implementation

**Layout**
- Centered text, elegant typography
- Parent portrait below text
- Signature below portrait
- Date below signature
- No app logo, no branding, no promotion
- Warm cream background

**Placement in Book**
- After Edition Page
- Very last page
- Full page

**Translation Keys**
```dart
'legacyPageTitle': 'Your Legacy Lives On',
'legacyPageMessage': 'Every story shared in this book is a gift to future generations. Your voice, your memories, and your wisdom will continue to be part of your family\'s story.',
```

---

## Feature 12: Book Preview & Flip-Through

### Current State
User taps "Generate" and immediately gets a PDF.

### Target State
User experiences their memoir before exporting.

### Flow

```
All Chapters Approved
  → "Your memoir is ready to preview"
  → Book Preview Screen (flip-through interface)
  → User flips through pages
  → "Does everything look right?"
  → Approve → Generate Final Memoir
```

### New Screen: `book_preview_flippable.dart`

**Layout**
- Full-screen book view
- Swipe left/right to flip pages
- Page indicator at bottom (e.g., "Page 12 of 48")
- Chapter navigation sidebar (optional)
- "Edit" button on each page
- "Approve & Export" button at end

**Interactions**
- Swipe left: next page
- Swipe right: previous page
- Tap on text: edit that answer
- Tap on photo: replace photo
- Long press: see original recording

**Page Display**
- Rendered pages matching final PDF layout
- Typography and styling identical to output
- Photos embedded
- Pull quotes highlighted

### Translation Keys
```dart
'previewYourMemoir': 'Preview Your Memoir',
'flipToExplore': 'Swipe to explore your memoir',
'doesEverythingLookRight': 'Does everything look right?',
'editPage': 'Edit this page',
'approveAndExport': 'Approve & Export',
'generateFinalMemoir': 'Generate Final Memoir',
```

---

## Feature 13: Enhanced Chapter Review

### Current State
Question → Transcript → Edit

### Target State
Original Voice → Transcript → Edited Story → Included in Book

### Flow

```
Chapter Review Screen
  → List of Q&A pairs
  → Each pair shows:
    - Original recording (play button)
    - Transcript (read-only)
    - Edited version (if edited)
    - "Included in book" badge
  → Edit any answer
  → Approve chapter
```

### Enhanced Display

For each answer:
```
┌─────────────────────────────────┐
│  🔊 Listen to original          │
│  (Play button, recording time)  │
├─────────────────────────────────┤
│  Transcript                     │
│  (Auto-generated text)          │
├─────────────────────────────────┤
│  Your edited version            │
│  (User's edited text)           │
│  "Included in final book"       │
└─────────────────────────────────┘
```

### Implementation

**Modified Screen**: `chapter_review_screen.dart`

**Layout**
- Chapter title at top
- List of enhanced Q&A cards
- Each card has three sections:
  1. Voice player (original recording)
  2. Transcript (auto-generated)
  3. Edited story (user's version)
- "Included in book" badge
- Edit button per answer

**Translation Keys**
```dart
'listenToOriginal': 'Listen to original',
'readTranscript': 'Read transcript',
'yourEditedVersion': 'Your edited version',
'includedInBook': 'Included in final book',
'editThisAnswer': 'Edit this answer',
```

---

## Editing Workflow Summary

### Current Flow
```
Question → Voice Recording → Save → Next
```

### New Flow
```
Question → Voice Recording → Transcript → Edit → Save Draft → Approve → Continue
```

### Chapter Flow
```
All Questions Answered → Memory Approval Ceremony → Chapter Review → Edit Any → Approve Chapter → Locked → In Final Book
```

### Book Generation Flow
```
All Chapters Approved → Add Photos → Add Signature → Add Edition Info 
→ Book Preview (Flip-Through) → Approve → Generate Final Memoir → Legacy Page
```

---

## Implementation Roadmap

### v1.0 — Before Launch (14 features)

| Feature | Files to Modify |
|---------|-----------------|
| Premium Memoir Design | `pdf_export_service.dart` (major rewrite) |
| Answer Review & Edit | `question_screen.dart`, new `edit_answer_screen.dart` |
| Parent Photograph | new `photo_selection_screen.dart`, `parent_profile.dart` |
| Parent Signature | new `signature_screen.dart`, `parent_profile.dart` |
| Edition Page | new `edition_info_screen.dart`, `memoir.dart` |
| Chapter Review | new `chapter_review_screen.dart`, `generated_chapter.dart` |
| Letter to Children | `questions.dart`, `pdf_export_service.dart` |
| Favourite Quotes | `questions.dart`, `pdf_export_service.dart` |
| Memory Approval Ceremony | new `chapter_complete_screen.dart` |
| Legacy Page | `pdf_export_service.dart` |
| Book Preview Flip-Through | new `book_preview_flippable.dart` |
| Enhanced Chapter Review | `chapter_review_screen.dart` |

### v1.1 — After Launch (4 features)

| Feature | Files to Modify |
|---------|-----------------|
| AI Follow-up Questions | `questions.dart`, `question_screen.dart` |
| Family Collaboration | new `collaboration_service.dart` |
| QR Code Voice Playback | `pdf_export_service.dart` |
| ePub Export | new `epub_export_service.dart` |

---

## Files to Create/Modify

### New Files (v1.0)
- `lib/screens/edit_answer_screen.dart`
- `lib/screens/photo_selection_screen.dart`
- `lib/screens/signature_screen.dart`
- `lib/screens/edition_info_screen.dart`
- `lib/screens/chapter_review_screen.dart`
- `lib/screens/chapter_complete_screen.dart`
- `lib/screens/book_preview_flippable.dart`

### Modified Files (v1.0)
- `lib/models/memory.dart` — Add `editedTranscript`, `isApproved`, `approvedAt`
- `lib/models/parent_profile.dart` — Add photo paths, `signaturePath`
- `lib/models/memoir.dart` — Add `recordedBy`, `location`, `completedAt`
- `lib/models/generated_chapter.dart` — Add `isApproved`, `approvedAt`
- `lib/screens/question_screen.dart` — Add edit button, word count
- `lib/screens/book_preview_screen.dart` — Photo selection, chapter review
- `lib/services/pdf_export_service.dart` — Major rewrite for premium design
- `lib/services/template_book_service.dart` — Chapter structure updates
- `lib/data/questions.dart` — Add Letter to Children, Grandchildren, Quotes
- `lib/l10n/translations.dart` — New keys for all new copy
