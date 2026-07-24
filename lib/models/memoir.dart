class Memoir {
  final int version;
  final String text;
  final String createdBy; // 'human' or 'AI'
  final DateTime editedAt;

  Memoir({
    required this.version,
    required this.text,
    required this.createdBy,
    DateTime? editedAt,
  }) : editedAt = editedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'text': text,
      'createdBy': createdBy,
      'editedAt': editedAt.toIso8601String(),
    };
  }

  factory Memoir.fromMap(Map<String, dynamic> map) {
    return Memoir(
      version: map['version'] ?? 1,
      text: map['text'] ?? '',
      createdBy: map['createdBy'] ?? 'human',
      editedAt: map['editedAt'] != null
          ? DateTime.parse(map['editedAt'])
          : DateTime.now(),
    );
  }
}
