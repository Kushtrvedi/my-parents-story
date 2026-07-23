import 'package:uuid/uuid.dart';
import '../models/parent_profile.dart';
import '../models/memory.dart';
import '../models/memoir.dart';
import '../models/voice_recording.dart';
import '../models/generated_chapter.dart';
import '../models/question.dart';
import '../data/questions.dart';
import 'local_storage.dart';

const _uuid = Uuid();

class StorageService {
  // Profile Management
  ParentProfile createProfile({
    required String name,
    required String parentType,
    String birthYear = '',
    String city = '',
    String photoPath = '',
  }) {
    final id = _uuid.v4();
    final profile = ParentProfile(
      id: id,
      name: name,
      parentType: parentType,
      birthYear: birthYear,
      city: city,
      photoPath: photoPath,
    );
    LocalStorage.profiles.put(id, profile.toMap());
    return profile;
  }

  ParentProfile? getProfile(String id) {
    final data = LocalStorage.profiles.get(id);
    if (data == null) return null;
    return ParentProfile.fromMap(Map<String, dynamic>.from(data));
  }

  List<ParentProfile> getAllProfiles() {
    return LocalStorage.profiles.values
        .map((e) => ParentProfile.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  void updateProfile(ParentProfile profile) {
    LocalStorage.profiles.put(profile.id, profile.toMap());
  }

  void deleteProfile(String id) {
    LocalStorage.profiles.delete(id);
    final responses = getMemoriesForProfile(id);
    for (final r in responses) {
      LocalStorage.responses.delete(r.id);
    }
    final chapters = getChapters(id);
    for (final c in chapters) {
      LocalStorage.chapters.delete(c.id);
    }
  }

  // Memory Management
  Memory saveMemory({
    required String profileId,
    required String chapterId,
    required String questionId,
    String? originalTranscript,
    String? editedTranscript,
    DateTime? lastEdited,
    VoiceRecording? originalRecording,
    Memoir? memoir,
    bool? isApproved,
    DateTime? approvedAt,

    String? emotionalTone,
    String? storyImportance,
    String? lifeStage,
    String? summary,
    List<String>? lifeThemes,
    List<String>? peopleMentioned,
    List<String>? placesMentioned,
    List<String>? historicalEvents,
    List<String>? objects,
    List<String>? familyRelationships,
    MemoryType? memoryType,
    String? decade,
    bool? isUnfinished,
  }) {
    final id = '${profileId}_${chapterId}_$questionId';
    final existingData = LocalStorage.responses.get(id);
    Memory memory;

    if (existingData != null) {
      final existing = Memory.fromMap(Map<String, dynamic>.from(existingData));
      memory = Memory(
        id: id,
        parentId: profileId,
        chapterId: chapterId,
        questionId: questionId,
        originalTranscript: originalTranscript ?? existing.originalTranscript,
        editedTranscript: editedTranscript ?? existing.editedTranscript,
        lastEdited: lastEdited ?? existing.lastEdited,
        originalRecording: originalRecording ?? existing.originalRecording,
        memoir: memoir ?? existing.memoir,
        isApproved: isApproved ?? existing.isApproved,
        approvedAt: approvedAt ?? existing.approvedAt,
        createdAt: existing.createdAt,
        emotionalTone: emotionalTone ?? existing.emotionalTone,
        storyImportance: storyImportance ?? existing.storyImportance,
        lifeStage: lifeStage ?? existing.lifeStage,
        summary: summary ?? existing.summary,
        lifeThemes: lifeThemes ?? existing.lifeThemes,
        people: peopleMentioned ?? existing.people,
        places: placesMentioned ?? existing.places,
        historicalEvents: historicalEvents ?? existing.historicalEvents,
        objects: objects ?? existing.objects,
        familyRelationships: familyRelationships ?? existing.familyRelationships,
        memoryType: memoryType ?? existing.memoryType,
        decade: decade ?? existing.decade,
        isUnfinished: isUnfinished ?? existing.isUnfinished,
      );
    } else {
      memory = Memory(
        id: id,
        parentId: profileId,
        chapterId: chapterId,
        questionId: questionId,
        originalTranscript: originalTranscript,
        editedTranscript: editedTranscript,
        lastEdited: lastEdited,
        originalRecording: originalRecording,
        memoir: memoir,
        isApproved: isApproved ?? false,
        approvedAt: approvedAt,
        emotionalTone: emotionalTone,
        storyImportance: storyImportance,
        lifeStage: lifeStage,
        summary: summary,
        lifeThemes: lifeThemes ?? const [],
        people: peopleMentioned ?? const [],
        places: placesMentioned ?? const [],
        historicalEvents: historicalEvents ?? const [],
        objects: objects ?? const [],
        familyRelationships: familyRelationships ?? const [],
        memoryType: memoryType ?? MemoryType.unknown,
        decade: decade,
        isUnfinished: isUnfinished ?? false,
      );
    }
    LocalStorage.responses.put(id, memory.toMap());
    return memory;
  }

  Memory? getMemory(String profileId, String chapterId, String questionId) {
    final id = '${profileId}_${chapterId}_$questionId';
    final data = LocalStorage.responses.get(id);
    if (data == null) return null;
    return Memory.fromMap(Map<String, dynamic>.from(data));
  }

  List<Memory> getMemoriesForProfile(String profileId) {
    return LocalStorage.responses.values
        .map((e) => Memory.fromMap(Map<String, dynamic>.from(e)))
        .where((m) => m.parentId == profileId)
        .toList();
  }

  List<Memory> getMemoriesForChapter(String profileId, String chapterId) {
    return getMemoriesForProfile(profileId)
        .where((m) => m.chapterId == chapterId)
        .toList();
  }

  Map<String, int> getCompletionProgress(String profileId) {
    final memories = getMemoriesForProfile(profileId);
    final Map<String, int> progress = {};
    for (final m in memories) {
      if (m.hasAnswer) {
        progress[m.chapterId] = (progress[m.chapterId] ?? 0) + 1;
      }
    }
    return progress;
  }

  void clearAlphaDatabase() {
    LocalStorage.profiles.clear();
    LocalStorage.responses.clear();
    LocalStorage.chapters.clear();
    LocalStorage.settings.clear();
  }

  // Chapter Management
  void saveChapter(GeneratedChapter chapter) {
    LocalStorage.chapters.put(chapter.id, chapter.toMap());
  }

  List<GeneratedChapter> getChapters(String profileId) {
    return LocalStorage.chapters.values
        .map((e) => GeneratedChapter.fromMap(Map<String, dynamic>.from(e)))
        .where((c) => c.profileId == profileId)
        .toList()
      ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
  }

  GeneratedChapter? getChapter(String profileId, String category) {
    final id = '${profileId}_$category';
    final data = LocalStorage.chapters.get(id);
    if (data == null) return null;
    return GeneratedChapter.fromMap(Map<String, dynamic>.from(data));
  }

  void deleteChapters(String profileId) {
    final chapters = getChapters(profileId);
    for (final c in chapters) {
      LocalStorage.chapters.delete(c.id);
    }
  }

  // Questions
  List<Question> getQuestionsForChapter(String chapterId) {
    return QuestionDatabase.getQuestionsForChapter(chapterId);
  }

  List<Chapter> getAllChapters() {
    return QuestionDatabase.chapters;
  }

  Chapter? getChapterById(String chapterId) {
    return QuestionDatabase.getChapterById(chapterId);
  }

  int get totalQuestions => QuestionDatabase.totalQuestions;
  int get totalChapters => QuestionDatabase.totalChapters;

  // Milestones
  void incrementMilestone(String profileId, String type) {
    final key = '${profileId}_milestone_$type';
    final current = LocalStorage.settings.get(key) ?? 0;
    LocalStorage.settings.put(key, current + 1);
  }

  int getMilestone(String profileId, String type) {
    final key = '${profileId}_milestone_$type';
    return LocalStorage.settings.get(key) ?? 0;
  }

  // Generic Settings
  dynamic getSetting(String key) {
    return LocalStorage.settings.get(key);
  }

  void saveSetting(String key, dynamic value) {
    LocalStorage.settings.put(key, value);
  }

  void deleteSetting(String key) {
    LocalStorage.settings.delete(key);
  }
}
