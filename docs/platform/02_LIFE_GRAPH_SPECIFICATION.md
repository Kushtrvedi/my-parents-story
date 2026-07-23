# Life Graph Specification

The **Life Graph** is the structured knowledge base that powers the entire My Parents' Story platform. It transforms raw conversational audio and transcripts into a highly normalized, queryable, and enduring oral history archive.

---

## 1. The Data Pipeline

The Life Graph sits at the center of the architecture:

```text
Conversation
      ↓
Life Context Engine
      ↓
LIFE GRAPH
      ↓
Legacy Intelligence
      ↓
Legacy Composer
```

## 2. Core Mechanisms

### 2.1 Entity Normalization
Rather than storing loose metadata strings, the system resolves mentions into explicit Domain Entities (defined in `03_DOMAIN_MODEL.md`). When a user mentions "Dad", the system resolves this to the specific `Person` entity representing their father.

### 2.2 Confidence Scores
Every entity, fact, and relationship extracted by the Legacy Intelligence Layer is assigned a `confidence` score (0.0 to 1.0).
- **High Confidence (>0.90):** Facts explicitly stated by the user.
- **Low Confidence (<0.60):** Inferred details or passing mentions.
- **Reinforcement:** Low-confidence data requires reinforcement across multiple stories before it is actively queried or heavily featured in final compositions. This prevents AI hallucinations from polluting the family history.

### 2.3 The Legacy Index
After every story is processed, the system computes lightweight signals to build the **Legacy Index**. The Legacy Index scores the overall "health" and richness of the Life Graph.
- **Completeness:** Are there major timeline gaps?
- **Emotional Richness:** Do we have stories of joy, sorrow, triumph, and regret, or just facts?
- **Historical Significance:** Does the graph contain ties to major world/local events?
- **Family Significance:** Are all core family members represented?
- **Narrative Continuity:** Do stories flow logically?

The Legacy Index is NOT used to score the user. It is used by the Life Context Engine to organically guide future conversations toward areas that will strengthen the overall memoir.

## 3. Querying the Life Graph

Because the Life Graph is fully normalized, the Legacy Composer can execute complex, cross-sectional queries to generate unique experiences without requiring new interviews:
- *"Tell me every story Dad ever told about perseverance."* (Filters: `Person = Dad`, `Lesson/Theme = Perseverance`)
- *"Show every tradition involving Grandma."* (Filters: `Person = Grandma`, `Entity = Tradition`)
- *"Generate a children's version of my mother's life."* (Filters: `Person = Mother`, modifies output tone in Composer)
