import 'storage_service.dart';

class BookVersion {
  final int version;
  final DateTime generatedAt;
  final int totalChapters;
  final int totalWords;
  final String? filePath;

  const BookVersion({
    required this.version,
    required this.generatedAt,
    required this.totalChapters,
    required this.totalWords,
    this.filePath,
  });

  Map<String, dynamic> toMap() => {
    'version': version,
    'generatedAt': generatedAt.toIso8601String(),
    'totalChapters': totalChapters,
    'totalWords': totalWords,
    'filePath': filePath,
  };

  factory BookVersion.fromMap(Map<String, dynamic> map) => BookVersion(
    version: map['version'] ?? 1,
    generatedAt: map['generatedAt'] != null ? DateTime.parse(map['generatedAt']) : DateTime.now(),
    totalChapters: map['totalChapters'] ?? 0,
    totalWords: map['totalWords'] ?? 0,
    filePath: map['filePath'],
  );
}

class BookVersioningService {
  final StorageService _storage;

  BookVersioningService(this._storage);

  String _versionKey(String profileId) => '${profileId}_book_versions';

  List<BookVersion> getVersions(String profileId) {
    final data = _storage.getSetting(_versionKey(profileId));
    if (data == null) return [];
    final list = List<Map<String, dynamic>>.from(data ?? []);
    return list.map((m) => BookVersion.fromMap(m)).toList()
      ..sort((a, b) => b.version.compareTo(a.version));
  }

  BookVersion? getLatestVersion(String profileId) {
    final versions = getVersions(profileId);
    return versions.isNotEmpty ? versions.first : null;
  }

  void saveVersion(String profileId, BookVersion version) {
    final versions = getVersions(profileId);
    final updated = [version, ...versions.where((v) => v.version != version.version)];
    final limited = updated.take(10).toList();
    _storage.saveSetting(
      _versionKey(profileId),
      limited.map((v) => v.toMap()).toList(),
    );
  }

  int getNextVersionNumber(String profileId) {
    final versions = getVersions(profileId);
    if (versions.isEmpty) return 1;
    return versions.first.version + 1;
  }

  void deleteVersion(String profileId, int version) {
    final versions = getVersions(profileId);
    final updated = versions.where((v) => v.version != version).toList();
    _storage.saveSetting(
      _versionKey(profileId),
      updated.map((v) => v.toMap()).toList(),
    );
  }
}
