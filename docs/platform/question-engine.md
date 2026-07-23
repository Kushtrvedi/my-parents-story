# Question Engine

## Overview

The Question Engine provides 300 guided questions across 20 chapters (15 per chapter), organized into 5 life-stage groups.

## Structure

```
Chapter {
  id: String          // "ch01" - "ch20"
  number: int
  title: String
  description: String
  icon: String
  questionCount: int  // always 15
}

Question {
  id: String              // "ch01_q01"
  chapterId: String
  chapterNumber: int
  questionNumber: int
  question: String
  purpose: String
  expectedMemoryType: enum
  emotionalTone: enum
  estimatedDuration: enum
  difficulty: enum
  priority: enum
  searchTags: List<String>
  people: List<String>
  places: List<String>
  followUps: List<String>
}
```

## Life-Stage Groups

| Group | Chapters | Focus |
|-------|----------|-------|
| Childhood | ch01-ch05 | Roots, birth, home, school, friends |
| Youth | ch06-ch08 | Dreams, education, first job |
| Family Life | ch09-ch13 | Love, marriage, parenthood, traditions |
| Life Journey | ch14-ch17 | Challenges, success, faith, travel |
| Legacy | ch18-ch20 | Wisdom, legacy, reflections |

## Question Metadata

Each question carries metadata for the Question Engine:

- **EmotionalTone**: warm, joyful, curious, reflective, proud, nostalgic, hopeful, legacy
- **ExpectedMemoryType**: sensory, emotional, narrative, factual, reflective
- **EstimatedDuration**: short, medium, long
- **Difficulty**: easy, moderate, sensitive
- **QuestionPriority**: core, important, optional

## Follow-Up System

Each core question has 5-10 follow-up questions that can be triggered based on the richness of the response.
