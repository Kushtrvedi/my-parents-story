class VoiceRecording {
  final String id;
  final String file;
  final Duration duration;
  final int? sampleRate;
  final String language;
  final DateTime createdAt;

  VoiceRecording({
    required this.id,
    required this.file,
    required this.duration,
    this.sampleRate,
    required this.language,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file': file,
      'durationMs': duration.inMilliseconds,
      'sampleRate': sampleRate,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory VoiceRecording.fromMap(Map<String, dynamic> map) {
    return VoiceRecording(
      id: map['id'] ?? '',
      file: map['file'] ?? '',
      duration: Duration(milliseconds: map['durationMs'] ?? 0),
      sampleRate: map['sampleRate'],
      language: map['language'] ?? 'en',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
