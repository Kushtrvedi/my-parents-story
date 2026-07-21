class Photo {
  final String id;
  final String path;
  final String caption;
  final DateTime takenDate;
  final List<String> people;

  Photo({
    required this.id,
    required this.path,
    this.caption = '',
    required this.takenDate,
    this.people = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'caption': caption,
      'takenDate': takenDate.toIso8601String(),
      'people': people,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'] ?? '',
      path: map['path'] ?? '',
      caption: map['caption'] ?? '',
      takenDate: map['takenDate'] != null ? DateTime.parse(map['takenDate']) : DateTime.now(),
      people: List<String>.from(map['people'] ?? []),
    );
  }
}
