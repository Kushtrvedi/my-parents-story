# Search Engine

## Overview

Full-text search across all memory data. Works entirely offline.

## Searchable Fields

| Field | Weight |
|-------|--------|
| transcript | 1.0 |
| memoir text | 1.0 |
| people | 0.8 |
| places | 0.8 |
| tags | 0.6 |
| chapter title | 0.4 |
| question text | 0.3 |

## Algorithm

1. Tokenize query into words
2. For each memory, calculate relevance score
3. Score = sum of (field_weight × word_similarity)
4. Sort by score descending
5. Return top results

## Similarity

Uses Levenshtein distance for fuzzy matching:
- "Grandfather" matches "grandfather", "grandpa"
- "Village" matches "village", "gaon"
- Handles typos up to 2 character differences

## Search Modes

- **Quick search** — instant results as user types
- **Advanced search** — filter by chapter, people, places, date range
- **Timeline search** — find memories near a specific year

## Performance

- 300 memories: < 50ms
- 1000 memories: < 200ms
- No indexing required at current scale
