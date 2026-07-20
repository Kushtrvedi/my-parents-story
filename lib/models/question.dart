enum EmotionalTone {
  warm,
  joyful,
  curious,
  reflective,
  proud,
  nostalgic,
  hopeful,
  legacy,
}

enum ExpectedMemoryType {
  sensory,
  emotional,
  narrative,
  factual,
  reflective,
}

enum EstimatedDuration {
  short,
  medium,
  long,
}

enum Difficulty {
  easy,
  moderate,
  sensitive,
}

enum QuestionPriority {
  core,
  important,
  optional,
}

class Chapter {
  final int number;
  final String id;
  final String title;
  final String description;
  final String icon;
  final int questionCount;

  const Chapter({
    required this.number,
    required this.id,
    required this.title,
    required this.description,
    this.icon = '',
    this.questionCount = 15,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'questionCount': questionCount,
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      number: map['number'] ?? 0,
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      questionCount: map['questionCount'] ?? 15,
    );
  }
}

class Question {
  final String id;
  final String chapterId;
  final int chapterNumber;
  final int questionNumber;
  final String question;
  final String purpose;
  final ExpectedMemoryType expectedMemoryType;
  final EmotionalTone emotionalTone;
  final EstimatedDuration estimatedDuration;
  final List<String> followUpTopics;
  final List<String> searchTags;
  final List<String> people;
  final List<String> places;
  final String suitableAgeRange;
  final Difficulty difficulty;
  final QuestionPriority priority;
  final List<String> followUps;

  const Question({
    required this.id,
    required this.chapterId,
    required this.chapterNumber,
    required this.questionNumber,
    required this.question,
    required this.purpose,
    required this.expectedMemoryType,
    required this.emotionalTone,
    required this.estimatedDuration,
    this.followUpTopics = const [],
    this.searchTags = const [],
    this.people = const [],
    this.places = const [],
    this.suitableAgeRange = '60-90',
    this.difficulty = Difficulty.easy,
    this.priority = QuestionPriority.core,
    this.followUps = const [],
  });

  Question copyWith({
    String? id,
    String? chapterId,
    int? chapterNumber,
    int? questionNumber,
    String? question,
    String? purpose,
    ExpectedMemoryType? expectedMemoryType,
    EmotionalTone? emotionalTone,
    EstimatedDuration? estimatedDuration,
    List<String>? followUpTopics,
    List<String>? searchTags,
    List<String>? people,
    List<String>? places,
    String? suitableAgeRange,
    Difficulty? difficulty,
    QuestionPriority? priority,
    List<String>? followUps,
  }) {
    return Question(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      questionNumber: questionNumber ?? this.questionNumber,
      question: question ?? this.question,
      purpose: purpose ?? this.purpose,
      expectedMemoryType: expectedMemoryType ?? this.expectedMemoryType,
      emotionalTone: emotionalTone ?? this.emotionalTone,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      followUpTopics: followUpTopics ?? this.followUpTopics,
      searchTags: searchTags ?? this.searchTags,
      people: people ?? this.people,
      places: places ?? this.places,
      suitableAgeRange: suitableAgeRange ?? this.suitableAgeRange,
      difficulty: difficulty ?? this.difficulty,
      priority: priority ?? this.priority,
      followUps: followUps ?? this.followUps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapterId': chapterId,
      'chapterNumber': chapterNumber,
      'questionNumber': questionNumber,
      'question': question,
      'purpose': purpose,
      'expectedMemoryType': expectedMemoryType.name,
      'emotionalTone': emotionalTone.name,
      'estimatedDuration': estimatedDuration.name,
      'followUpTopics': followUpTopics,
      'searchTags': searchTags,
      'people': people,
      'places': places,
      'suitableAgeRange': suitableAgeRange,
      'difficulty': difficulty.name,
      'priority': priority.name,
      'followUps': followUps,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      chapterId: map['chapterId'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      questionNumber: map['questionNumber'] ?? 0,
      question: map['question'] ?? '',
      purpose: map['purpose'] ?? '',
      expectedMemoryType: ExpectedMemoryType.values.firstWhere(
        (e) => e.name == map['expectedMemoryType'],
        orElse: () => ExpectedMemoryType.narrative,
      ),
      emotionalTone: EmotionalTone.values.firstWhere(
        (e) => e.name == map['emotionalTone'],
        orElse: () => EmotionalTone.warm,
      ),
      estimatedDuration: EstimatedDuration.values.firstWhere(
        (e) => e.name == map['estimatedDuration'],
        orElse: () => EstimatedDuration.medium,
      ),
      followUpTopics: List<String>.from(map['followUpTopics'] ?? []),
      searchTags: List<String>.from(map['searchTags'] ?? []),
      people: List<String>.from(map['people'] ?? []),
      places: List<String>.from(map['places'] ?? []),
      suitableAgeRange: map['suitableAgeRange'] ?? '60-90',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      priority: QuestionPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => QuestionPriority.core,
      ),
      followUps: List<String>.from(map['followUps'] ?? []),
    );
  }
}
