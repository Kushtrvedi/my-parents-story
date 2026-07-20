# AI System

## Overview

The AI system transforms fragmented interview responses into cohesive, book-quality memoir chapters using OpenAI's GPT-4o model.

## Chapter Generation Flow

```
User completes questions
        ↓
Collect responses for category
        ↓
Format as Q&A pairs
        ↓
Send to OpenAI with memoir editor prompt
        ↓
Receive polished chapter
        ↓
Store in Firestore
```

## Prompts

### Chapter Generation

```
You are a professional memoir editor.

Convert the following interview responses into a warm, authentic 
first-person memoir chapter.

Parent's Name: {name}
Chapter Theme: {category}

Interview Responses:
{q&a pairs}

Rules:
- Preserve factual details
- Do not invent events
- Maintain the parent's natural voice
- Improve readability and flow while preserving authenticity
- Write in first person as if the parent is telling their story
- Create a cohesive, book-quality narrative
- Use warm, evocative language
- Connect ideas smoothly between paragraphs
```

### Final Letter

```
You are a professional memoir editor.

Based on the following life story interview responses from {name}, 
write a heartfelt closing letter titled "What I Hope My Family Remembers."

Interview Responses:
{all q&a pairs}

Rules:
- Write in first person as {name}
- Create a warm, emotionally resonant letter
- Summarize key themes and wisdom
- Focus on what matters most to them
- End with a loving message to future generations
```

## Offline Fallback

When OpenAI API is unavailable:
1. Responses are concatenated as-is
2. Basic formatting is applied
3. Chapter structure is preserved
4. User is informed of degraded quality

## Configuration

Set API key in `.env`:
```
OPENAI_API_KEY=sk-...
```

## Rate Limits

- OpenAI: 3 RPM for GPT-4o (free tier)
- App caches generated chapters
- Only regenerates on explicit request

## Quality Guidelines

Generated chapters should:
- Sound like the parent is speaking
- Preserve specific names, dates, places
- Connect related memories thematically
- Maintain emotional authenticity
- Flow naturally between paragraphs
