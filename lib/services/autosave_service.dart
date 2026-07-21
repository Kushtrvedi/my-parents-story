import 'dart:async';
import '../models/memory.dart';
import 'storage_service.dart';

class AutosaveState {
  final String profileId;
  final String chapterId;
  final String questionId;
  final String? transcript;
  final DateTime lastSaved;

  const AutosaveState({
    required this.profileId,
    required this.chapterId,
    required this.questionId,
    this.transcript,
    required this.lastSaved,
  });

  bool get isEmpty => transcript == null || transcript!.trim().isEmpty;
  bool get hasContent => !isEmpty;

  Map<String, dynamic> toMap() => {
    'profileId': profileId,
    'chapterId': chapterId,
    'questionId': questionId,
    'transcript': transcript,
    'lastSaved': lastSaved.toIso8601String(),
  };

  factory AutosaveState.fromMap(Map<String, dynamic> map) => AutosaveState(
    profileId: map['profileId'] ?? '',
    chapterId: map['chapterId'] ?? '',
    questionId: map['questionId'] ?? '',
    transcript: map['transcript'],
    lastSaved: map['lastSaved'] != null ? DateTime.parse(map['lastSaved']) : DateTime.now(),
  );
}

class AutosaveService {
  final StorageService _storage;
  Timer? _timer;
  AutosaveState? _currentState;

  AutosaveService(this._storage);

  AutosaveState? get currentState => _currentState;
  bool get hasUnsavedWork => _currentState?.hasContent ?? false;

  void startAutosave({
    required String profileId,
    required String chapterId,
    required String questionId,
  }) {
    _currentState = AutosaveState(
      profileId: profileId,
      chapterId: chapterId,
      questionId: questionId,
      lastSaved: DateTime.now(),
    );
  }

  void updateTranscript(String transcript) {
    if (_currentState == null) return;
    _currentState = AutosaveState(
      profileId: _currentState!.profileId,
      chapterId: _currentState!.chapterId,
      questionId: _currentState!.questionId,
      transcript: transcript,
      lastSaved: DateTime.now(),
    );
  }

  void saveNow() {
    if (_currentState == null || !_currentState!.hasContent) return;
    _storage.saveMemory(
      profileId: _currentState!.profileId,
      chapterId: _currentState!.chapterId,
      questionId: _currentState!.questionId,
      originalTranscript: _currentState!.transcript,
    );
  }

  void clearAutosave() {
    _currentState = null;
  }

  List<AutosaveState> recoverUnfinishedMemories(String profileId) {
    final memories = _storage.getMemoriesForProfile(profileId);
    return memories
        .where((m) => m.originalTranscript != null && m.originalTranscript!.trim().isNotEmpty && m.memoir == null)
        .map((m) => AutosaveState(
          profileId: m.parentId,
          chapterId: m.chapterId,
          questionId: m.questionId,
          transcript: m.originalTranscript,
          lastSaved: m.createdAt,
        ))
        .toList();
  }

  void dispose() {
    _timer?.cancel();
    saveNow();
  }
}
