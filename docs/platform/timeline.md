# Timeline

## Overview

Automatic chronological ordering of memories. No manual arrangement required.

## How It Works

1. Extract year from each memory's transcript
2. If no year in transcript, use `createdAt` date
3. Group memories by year
4. Sort years chronologically
5. Within each year, sort by chapter order

## Year Extraction

The system extracts years from:
- Explicit dates: "In 1965, I..."
- Age references: "When I was 10..." (calculated from birth year)
- Context clues: "During the war...", "After independence..."
- Chapter context: childhood questions → earlier years

## Timeline View

```
1948 ─── Born in [Village]
         └─ ch02: Birth and Early Childhood

1955 ─── Started school
         └─ ch04: School Days

1965 ─── First job at [Company]
         └─ ch08: First Job and Career

1972 ─── Married [Spouse]
         └─ ch10: Marriage and Partnership

1980 ─── First child born
         └─ ch11: Parenthood
```

## Missing Years

Years without memories show as gaps:
```
1960 ─── (no memories yet)
1961 ─── (no memories yet)
```

This gently encourages the user to fill gaps.

## Filtering

- Filter by decade
- Filter by life stage
- Filter by people present
- Filter by location
