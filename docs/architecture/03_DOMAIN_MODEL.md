# Domain Model

The Life Graph is built entirely from explicit Domain Objects. These objects form an archival-quality model of a human life, rather than a loose collection of AI-extracted tags.

---

## 1. Universal Entity Properties
Every Domain Object in the system MUST implement the following base properties:
- `id`: A stable, unique identifier (UUID).
- `creationSource`: The origin of this entity (e.g., `Story #42`, `User Manual Entry`).
- `confidence`: A float between `0.0` and `1.0` representing the certainty of this extraction.
- `createdAt` / `updatedAt`: Timestamps for versioning.
- `sourceAttribution`: Links back to the raw source data (e.g., Audio Segment, Timestamp 14:52) so facts can be verified.
- `links`: Edges connecting this entity to other entities (e.g., a `Place` linked to a `Person`).

---

## 2. Core Entities

### Person
Represents a human being in the family network.
- `name` (Fact)
- `birthYear`, `deathYear` (Fact)
- `interpretations`: Array of generated traits (e.g., "Courageous", "Strict").

### Relationship (The Relationship Timeline)
Relationships are not static. The system maintains a Relationship Timeline to track how connections evolve.
- `sourcePersonId`
- `targetPersonId`
- `evolution`: E.g., `[Father -> Mentor -> Business Partner -> Best Friend]`

### Place
- `name` (Fact)
- `coordinates` (Optional)
- `significance` (Interpretation)

### Life Event
A chronological milestone.
- `date` / `decade` (Fact)
- `type` (Marriage, Migration, Graduation, Birth, Loss)

### Tradition
- `description`
- `frequency` (e.g., "Every Diwali")
- `associatedPeople`

### Recipe
- `dishName`
- `ingredients`
- `instructions`

### Lesson / Achievement / Regret
Abstract concepts and philosophies passed down.
- `summary`
- `context`

### Artifact / Photo / Audio Recording
Digital media attached to the graph.
- `fileUrl`
- `duration` / `dimensions`
- `transcription` (if audio)

### Story
The foundational conversational unit that generates all other entities.
- `transcript`
- `audioRef`
- `extractedEntities`: List of IDs pointing to the People, Places, and Events derived from this story.
