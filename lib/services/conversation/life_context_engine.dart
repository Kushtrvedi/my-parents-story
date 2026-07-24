import '../../models/memory.dart';
import '../../services/storage_service.dart';

class LifeContextEngine {
  final StorageService _storageService;

  LifeContextEngine(this._storageService);

  /// Retrieves relevant memories based on Life Graph overlap (people, places, themes, events).
  List<Memory> getRelevantContext(String profileId, String currentTranscript,
      {int limit = 2}) {
    final allMemories = _storageService
        .getMemoriesForProfile(profileId)
        .where((m) => m.hasAnswer)
        .toList();

    if (allMemories.isEmpty) return [];

    final normalizedTranscript = currentTranscript.toLowerCase();

    // Sort memories by Life Graph relevance score
    allMemories.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, normalizedTranscript);
      final scoreB = _calculateRelevanceScore(b, normalizedTranscript);

      // If scores are equal, prefer LEGACY or HIGH importance
      if (scoreA == scoreB) {
        final importanceA = _getImportanceWeight(a.storyImportance);
        final importanceB = _getImportanceWeight(b.storyImportance);
        return importanceB.compareTo(importanceA);
      }

      return scoreB.compareTo(scoreA); // Descending
    });

    final relevant = allMemories
        .where((m) => _calculateRelevanceScore(m, normalizedTranscript) > 0)
        .take(limit)
        .toList();

    if (relevant.isEmpty && allMemories.isNotEmpty) {
      // Fallback: return the most recently edited memory
      allMemories.sort((a, b) =>
          (b.lastEdited ?? b.createdAt).compareTo(a.lastEdited ?? a.createdAt));
      return [allMemories.first];
    }

    return relevant;
  }

  /// Finds stories marked as unfinished that we can seamlessly return to.
  Memory? getUnfinishedStory(String profileId) {
    final allMemories = _storageService
        .getMemoriesForProfile(profileId)
        .where((m) => m.hasAnswer && m.isUnfinished)
        .toList();

    if (allMemories.isEmpty) return null;

    // Pick the most recently discussed unfinished story
    allMemories.sort((a, b) =>
        (b.lastEdited ?? b.createdAt).compareTo(a.lastEdited ?? a.createdAt));
    return allMemories.first;
  }

  /// Identifies chronological gaps in the user's Life Graph (e.g., decades with no stories).
  String? getTimelineGap(String profileId) {
    final allMemories = _storageService.getMemoriesForProfile(profileId);
    final decades = allMemories
        .where((m) => m.decade != null && m.decade != 'unknown')
        .map((m) => m.decade!)
        .toSet();

    if (decades.isEmpty) return null;

    // Simplistic gap detection: if we have 1970s and 1990s but no 1980s.
    // Assuming decades are formatted like "1970s", "1980s", etc.
    final parsedDecades = decades
        .map((d) {
          final match = RegExp(r'(\d{4})').firstMatch(d);
          if (match != null) return int.tryParse(match.group(1)!) ?? 0;
          return 0;
        })
        .where((d) => d > 0)
        .toList();

    if (parsedDecades.length < 2) return null;

    parsedDecades.sort();

    for (int i = 0; i < parsedDecades.length - 1; i++) {
      if (parsedDecades[i + 1] - parsedDecades[i] > 10) {
        // Gap detected!
        return '${parsedDecades[i] + 10}s';
      }
    }

    return null;
  }

  int _calculateRelevanceScore(Memory memory, String normalizedTranscript) {
    int score = 0;

    for (var person in memory.people) {
      if (normalizedTranscript.contains(person.toLowerCase())) score += 3;
    }

    for (var place in memory.places) {
      if (normalizedTranscript.contains(place.toLowerCase())) score += 2;
    }

    for (var theme in memory.lifeThemes) {
      if (normalizedTranscript.contains(theme.toLowerCase())) score += 2;
    }

    for (var rel in memory.familyRelationships) {
      if (normalizedTranscript.contains(rel.toLowerCase())) score += 2;
    }

    for (var event in memory.historicalEvents) {
      if (normalizedTranscript.contains(event.toLowerCase())) score += 3;
    }

    return score;
  }

  int _getImportanceWeight(String? importance) {
    switch (importance?.toUpperCase()) {
      case 'LEGACY':
        return 4;
      case 'HIGH':
        return 3;
      case 'MEDIUM':
        return 2;
      case 'LOW':
        return 1;
      default:
        return 1;
    }
  }
}
