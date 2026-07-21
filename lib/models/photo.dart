import '../utils/path_resolver.dart';

class Photo {
  final String id;
  final String path; // Stored as a relative path
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

  /// Resolves the absolute path for display
  Future<String> get absolutePath async {
    return await PathResolver.toAbsolute(path);
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
