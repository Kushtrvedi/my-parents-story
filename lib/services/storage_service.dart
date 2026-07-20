import 'package:uuid/uuid.dart';
import '../models/parent_profile.dart';
import '../models/response.dart';
import '../models/generated_chapter.dart';
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
    final responses = getResponsesForProfile(id);
    for (final r in responses) {
      LocalStorage.responses.delete(r.id);
    }
    final chapters = getChapters(id);
    for (final c in chapters) {
      LocalStorage.chapters.delete(c.id);
    }
  }

  // Response Management
  StoryResponse saveResponse({
    required String profileId,
    required String category,
    required int questionIndex,
    required String question,
    String answer = '',
  }) {
    final id = '${profileId}_${category}_$questionIndex';
    final response = StoryResponse(
      id: id,
      profileId: profileId,
      category: category,
      questionIndex: questionIndex,
      question: question,
      answer: answer,
    );
    LocalStorage.responses.put(id, response.toMap());
    return response;
  }

  StoryResponse? getResponse(String profileId, String category, int questionIndex) {
    final id = '${profileId}_${category}_$questionIndex';
    final data = LocalStorage.responses.get(id);
    if (data == null) return null;
    return StoryResponse.fromMap(Map<String, dynamic>.from(data));
  }

  List<StoryResponse> getResponsesForProfile(String profileId) {
    return LocalStorage.responses.values
        .map((e) => StoryResponse.fromMap(Map<String, dynamic>.from(e)))
        .where((r) => r.profileId == profileId)
        .toList()
      ..sort((a, b) => a.questionIndex.compareTo(b.questionIndex));
  }

  List<StoryResponse> getResponsesForCategory(String profileId, String category) {
    return getResponsesForProfile(profileId)
        .where((r) => r.category == category)
        .toList();
  }

  Map<String, int> getCompletionProgress(String profileId) {
    final responses = getResponsesForProfile(profileId);
    final Map<String, int> progress = {};
    for (final r in responses) {
      if (r.hasAnswer) {
        progress[r.category] = (progress[r.category] ?? 0) + 1;
      }
    }
    return progress;
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
}
