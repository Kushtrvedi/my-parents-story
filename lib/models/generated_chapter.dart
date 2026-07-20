class GeneratedChapter {
  final String id;
  final String profileId;
  final String category;
  final int chapterNumber;
  final String title;
  final String content;
  DateTime createdAt;

  GeneratedChapter({
    required this.id,
    required this.profileId,
    required this.category,
    required this.chapterNumber,
    required this.title,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'category': category,
      'chapterNumber': chapterNumber,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GeneratedChapter.fromMap(Map<String, dynamic> map) {
    return GeneratedChapter(
      id: map['id'] ?? '',
      profileId: map['profileId'] ?? '',
      category: map['category'] ?? '',
      chapterNumber: map['chapterNumber'] ?? 0,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}

class GeneratedBook {
  final String profileId;
  final List<GeneratedChapter> chapters;
  final String finalLetter;

  GeneratedBook({
    required this.profileId,
    required this.chapters,
    required this.finalLetter,
  });
}
