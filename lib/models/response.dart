class StoryResponse {
  final String id;
  final String profileId;
  final String category;
  final int questionIndex;
  final String question;
  String answer;
  DateTime updatedAt;

  StoryResponse({
    required this.id,
    required this.profileId,
    required this.category,
    required this.questionIndex,
    required this.question,
    this.answer = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  bool get hasAnswer => answer.trim().isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profileId': profileId,
      'category': category,
      'questionIndex': questionIndex,
      'question': question,
      'answer': answer,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StoryResponse.fromMap(Map<String, dynamic> map) {
    return StoryResponse(
      id: map['id'] ?? '',
      profileId: map['profileId'] ?? '',
      category: map['category'] ?? '',
      questionIndex: map['questionIndex'] ?? 0,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
