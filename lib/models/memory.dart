import 'voice_recording.dart';
import 'photo.dart';
import 'memoir.dart';

class Memory {
  // Immutable Data
  final String id;
  final String parentId;
  final String chapterId;
  final String questionId;
  final VoiceRecording? originalRecording;
  final String? originalTranscript;
  final DateTime createdAt;
  final String language;
  
  // Schema version for migrations
  final String schemaVersion;

  // Editable Data
  int version;
  Memoir? memoir;
  List<String> tags;
  List<Photo> photos;
  List<String> people;
  List<String> places;
  List<String> followUps;
  Map<String, String> translations;
  List<String> lifeThemes;
  List<String> historicalEvents;
  List<String> objects;
  List<String> familyRelationships;
  String? emotionalTone;
  String? storyImportance;
  String? lifeStage;
  String? summary;
  Map<String, dynamic> metadata;

  // Approval State
  bool isApproved;
  DateTime? approvedAt;
  String? editedTranscript;
  DateTime? lastEdited;

  Memory({
    required this.id,
    required this.parentId,
    required this.chapterId,
    required this.questionId,
    this.originalRecording,
    this.originalTranscript,
    DateTime? createdAt,
    this.language = 'en',
    this.schemaVersion = '1.0.0',
    this.version = 1,
    this.memoir,
    this.tags = const [],
    this.photos = const [],
    this.people = const [],
    this.places = const [],
    this.followUps = const [],
    this.translations = const {},
    this.lifeThemes = const [],
    this.historicalEvents = const [],
    this.objects = const [],
    this.familyRelationships = const [],
    this.emotionalTone,
    this.storyImportance,
    this.lifeStage,
    this.summary,
    this.metadata = const {},
    this.isApproved = false,
    this.approvedAt,
    this.editedTranscript,
    this.lastEdited,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasAnswer => (memoir?.text.trim().isNotEmpty ?? false) || 
                        (editedTranscript?.trim().isNotEmpty ?? false) ||
                        (originalTranscript?.trim().isNotEmpty ?? false);
  
  String get answer => editedTranscript ?? memoir?.text ?? originalTranscript ?? '';

  String get displayAnswer {
    if (editedTranscript != null && editedTranscript!.isNotEmpty) {
      return editedTranscript!;
    }
    if (memoir?.text.isNotEmpty ?? false) {
      return memoir!.text;
    }
    return originalTranscript ?? '';
  }

  int get wordCount => answer.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'chapterId': chapterId,
      'questionId': questionId,
      'originalRecording': originalRecording?.toMap(),
      'originalTranscript': originalTranscript,
      'createdAt': createdAt.toIso8601String(),
      'language': language,
      'schemaVersion': schemaVersion,
      'version': version,
      'memoir': memoir?.toMap(),
      'tags': tags,
      'photos': photos.map((p) => p.toMap()).toList(),
      'people': people,
      'places': places,
      'followUps': followUps,
      'translations': translations,
      'lifeThemes': lifeThemes,
      'historicalEvents': historicalEvents,
      'objects': objects,
      'familyRelationships': familyRelationships,
      'emotionalTone': emotionalTone,
      'storyImportance': storyImportance,
      'lifeStage': lifeStage,
      'summary': summary,
      'metadata': metadata,
      'isApproved': isApproved,
      'approvedAt': approvedAt?.toIso8601String(),
      'editedTranscript': editedTranscript,
      'lastEdited': lastEdited?.toIso8601String(),
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['id'] ?? '',
      parentId: map['parentId'] ?? '',
      chapterId: map['chapterId'] ?? '',
      questionId: map['questionId'] ?? '',
      originalRecording: map['originalRecording'] != null ? VoiceRecording.fromMap(Map<String, dynamic>.from(map['originalRecording'])) : null,
      originalTranscript: map['originalTranscript'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      language: map['language'] ?? 'en',
      schemaVersion: map['schemaVersion'] ?? '1.0.0',
      version: map['version'] ?? 1,
      memoir: map['memoir'] != null ? Memoir.fromMap(Map<String, dynamic>.from(map['memoir'])) : null,
      tags: List<String>.from(map['tags'] ?? []),
      photos: (map['photos'] as List?)?.map((p) => Photo.fromMap(Map<String, dynamic>.from(p))).toList() ?? [],
      people: List<String>.from(map['people'] ?? []),
      places: List<String>.from(map['places'] ?? []),
      followUps: List<String>.from(map['followUps'] ?? []),
      translations: Map<String, String>.from(map['translations'] ?? {}),
      lifeThemes: List<String>.from(map['lifeThemes'] ?? []),
      historicalEvents: List<String>.from(map['historicalEvents'] ?? []),
      objects: List<String>.from(map['objects'] ?? []),
      familyRelationships: List<String>.from(map['familyRelationships'] ?? []),
      emotionalTone: map['emotionalTone'],
      storyImportance: map['storyImportance'],
      lifeStage: map['lifeStage'],
      summary: map['summary'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      isApproved: map['isApproved'] ?? false,
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      editedTranscript: map['editedTranscript'],
      lastEdited: map['lastEdited'] != null ? DateTime.parse(map['lastEdited']) : null,
    );
  }
}
