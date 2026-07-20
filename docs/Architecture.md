# Architecture

## Overview

My Parents' Story follows a clean architecture pattern with clear separation of concerns.

## Layers

```
┌─────────────────────────────────────┐
│           Presentation              │
│  ┌─────────┐  ┌─────────────────┐  │
│  │ Screens │  │    Widgets      │  │
│  └─────────┘  └─────────────────┘  │
├─────────────────────────────────────┤
│            Services                 │
│  ┌──────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│  │Fire. │ │AI   │ │Voice│ │PDF  │ │
│  │Svc   │ │Svc  │ │Svc  │ │Svc  │ │
│  └──────┘ └─────┘ └─────┘ └─────┘ │
├─────────────────────────────────────┤
│             Models                  │
│  ┌─────────┐ ┌────────┐ ┌────────┐ │
│  │Profile  │ │Response│ │Chapter │ │
│  └─────────┘ └────────┘ └────────┘ │
├─────────────────────────────────────┤
│            External                 │
│  ┌──────┐ ┌─────┐ ┌──────────────┐ │
│  │Fire. │ │Open │ │Speech-to-Text│ │
│  │API   │ │AI   │ │              │ │
│  └──────┘ └─────┘ └──────────────┘ │
└─────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── app_theme.dart           # Colors, typography, theme
├── data/
│   └── questions.dart           # 300 guided questions
├── models/
│   ├── parent_profile.dart      # Parent data model
│   ├── response.dart            # Question response model
│   └── generated_chapter.dart   # Chapter content model
├── screens/
│   ├── landing_screen.dart      # Welcome & parent selection
│   ├── profile_screen.dart      # Parent profile creation
│   ├── categories_screen.dart   # Journey categories
│   ├── question_screen.dart     # Question experience
│   ├── timeline_screen.dart     # Story timeline view
│   ├── generate_book_screen.dart # AI chapter generation
│   └── book_preview_screen.dart # PDF preview & export
└── services/
    ├── firestore_service.dart   # Firebase Firestore operations
    ├── ai_service.dart          # OpenAI API integration
    ├── voice_service.dart       # Speech-to-text handling
    └── pdf_service.dart         # PDF generation & export
```

## Data Flow

```
User Input → Screen → Service → External API → Model → Screen
                ↓
            Firestore
```

1. **User** interacts with a Screen
2. **Screen** calls appropriate Service
3. **Service** communicates with Firebase or OpenAI
4. **Response** is parsed into a Model
5. **Model** is passed back to Screen for display

## State Management

This MVP uses `StatefulWidget` for simplicity. Each screen manages its own state through:
- `setState()` for UI updates
- Service callbacks for async operations
- Constructor parameters for navigation data

## Navigation

Flat navigation structure using `Navigator.push`:

```
LandingScreen
  └→ ProfileScreen
       └→ CategoriesScreen
            ├→ QuestionScreen
            ├→ TimelineScreen
            └→ GenerateBookScreen
                 └→ BookPreviewScreen
```

## Key Design Decisions

1. **No external state management** - Reduces complexity for MVP
2. **Service-oriented** - Clean separation of business logic
3. **Model-driven** - Clear data contracts between layers
4. **Offline-capable** - Firestore handles offline caching
5. **Progressive enhancement** - AI features degrade gracefully
