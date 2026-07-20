# Database Structure

## Firebase Firestore

### Collections

#### users
```json
{
  "id": "uuid",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### parent_profiles
```json
{
  "id": "uuid",
  "userId": "uuid (ref: users)",
  "name": "string",
  "parentType": "mom | dad",
  "birthYear": "string",
  "city": "string",
  "photoUrl": "string (URL)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### responses
```json
{
  "id": "{profileId}_{category}_{questionIndex}",
  "profileId": "uuid (ref: parent_profiles)",
  "category": "string",
  "questionIndex": "int",
  "question": "string",
  "textAnswer": "string",
  "voiceTranscript": "string",
  "isDraft": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### generated_chapters
```json
{
  "id": "{profileId}_{category}",
  "profileId": "uuid (ref: parent_profiles)",
  "category": "string",
  "chapterNumber": "int",
  "title": "string",
  "content": "string (markdown)",
  "isGenerated": "boolean",
  "createdAt": "timestamp"
}
```

#### generated_books
```json
{
  "id": "profileId",
  "profileId": "uuid (ref: parent_profiles)",
  "pdfUrl": "string (URL)",
  "createdAt": "timestamp"
}
```

#### analytics
```json
{
  "id": "auto",
  "event": "string",
  "profileId": "uuid",
  "category": "string",
  "seconds": "int",
  "timestamp": "timestamp"
}
```

## Relationships

```
users (1) ──→ (N) parent_profiles
parent_profiles (1) ──→ (N) responses
parent_profiles (1) ──→ (N) generated_chapters
parent_profiles (1) ──→ (1) generated_books
```

## Indexes

Required composite indexes:
- `responses`: `profileId` + `category` + `questionIndex`
- `generated_chapters`: `profileId` + `chapterNumber`

## Security Rules

See [SECURITY.md](../SECURITY.md) for Firestore security rules.
