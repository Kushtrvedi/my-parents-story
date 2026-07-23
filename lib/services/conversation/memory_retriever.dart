import '../../models/memory.dart';
import '../../services/storage_service.dart';

class MemoryRetriever {
  final StorageService _storageService;

  MemoryRetriever(this._storageService);

  /// Retrieves relevant memories based on keyword overlap from the current transcript.
  /// Matches against people, places, themes, and historical events.
  List<Memory> getRelevantContext(String profileId, String currentTranscript, {int limit = 2}) {
    final allMemories = _storageService.getMemoriesForProfile(profileId)
        .where((m) => m.hasAnswer)
        .toList();

    if (allMemories.isEmpty) return [];

    final normalizedTranscript = currentTranscript.toLowerCase();
    
    // Sort memories by relevance score
    allMemories.sort((a, b) {
      final scoreA = _calculateRelevanceScore(a, normalizedTranscript);
      final scoreB = _calculateRelevanceScore(b, normalizedTranscript);
      
      // If scores are equal, prefer LEGACY or HIGH importance
      if (scoreA == scoreB) {
        final importanceA = _getImportanceWeight(a.storyImportance);
        final importanceB = _getImportanceWeight(b.storyImportance);
        return importanceB.compareTo(importanceA); // Descending
      }
      
      return scoreB.compareTo(scoreA); // Descending
    });

    // Only return memories that actually have some relevance (score > 0),
    // or if none match, just return the most recent one.
    final relevant = allMemories.where((m) => _calculateRelevanceScore(m, normalizedTranscript) > 0).take(limit).toList();
    
    if (relevant.isEmpty && allMemories.isNotEmpty) {
      // Fallback: return the most recently edited memory
      allMemories.sort((a, b) => (b.lastEdited ?? b.createdAt).compareTo(a.lastEdited ?? a.createdAt));
      return [allMemories.first];
    }
    
    return relevant;
  }

  int _calculateRelevanceScore(Memory memory, String normalizedTranscript) {
    int score = 0;
    
    // Match against people
    for (var person in memory.people) {
      if (normalizedTranscript.contains(person.toLowerCase())) score += 3;
    }
    
    // Match against places
    for (var place in memory.places) {
      if (normalizedTranscript.contains(place.toLowerCase())) score += 2;
    }
    
    // Match against themes
    for (var theme in memory.lifeThemes) {
      if (normalizedTranscript.contains(theme.toLowerCase())) score += 2;
    }
    
    // Match against family relationships
    for (var rel in memory.familyRelationships) {
      if (normalizedTranscript.contains(rel.toLowerCase())) score += 2;
    }
    
    return score;
  }
  
  int _getImportanceWeight(String? importance) {
    switch (importance?.toUpperCase()) {
      case 'LEGACY': return 4;
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 1;
    }
  }
}
