import '../models/memory.dart';
import '../core/extensions/string_extensions.dart';

class SearchResult {
  final Memory memory;
  final double score;
  final String matchedField;

  const SearchResult({required this.memory, required this.score, required this.matchedField});
}

class MemorySearchEngine {
  static const Map<String, double> _fieldWeights = {
    'transcript': 1.0,
    'memoir': 1.0,
    'people': 0.8,
    'places': 0.8,
    'tags': 0.6,
    'chapterId': 0.4,
    'question': 0.3,
  };

  List<SearchResult> search(String query, List<Memory> memories) {
    if (query.isBlank || memories.isEmpty) return [];

    final queryWords = query.toLowerCase().extractWords();
    if (queryWords.isEmpty) return [];

    final results = <SearchResult>[];

    for (final memory in memories) {
      final score = _scoreMemory(queryWords, memory);
      if (score > 0) {
        final matchedField = _findPrimaryMatch(queryWords, memory);
        results.add(SearchResult(memory: memory, score: score, matchedField: matchedField));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  double _scoreMemory(List<String> queryWords, Memory memory) {
    double totalScore = 0;

    for (final word in queryWords) {
      totalScore += _scoreField(word, memory.answer, _fieldWeights['transcript']!);
      if (memory.memoir != null) {
        totalScore += _scoreField(word, memory.memoir!.text, _fieldWeights['memoir']!);
      }
      for (final person in memory.people) {
        totalScore += _scoreField(word, person, _fieldWeights['people']!);
      }
      for (final place in memory.places) {
        totalScore += _scoreField(word, place, _fieldWeights['places']!);
      }
      for (final tag in memory.tags) {
        totalScore += _scoreField(word, tag, _fieldWeights['tags']!);
      }
      totalScore += _scoreField(word, memory.chapterId, _fieldWeights['chapterId']!);
    }

    return totalScore / queryWords.length;
  }

  double _scoreField(String queryWord, String fieldValue, double weight) {
    if (fieldValue.isEmpty) return 0;
    final lowerField = fieldValue.toLowerCase();
    if (lowerField.contains(queryWord)) return weight;
    final words = lowerField.extractWords();
    for (final word in words) {
      if (word.similarityTo(queryWord) > 0.7) return weight * 0.8;
    }
    return 0;
  }

  String _findPrimaryMatch(List<String> queryWords, Memory memory) {
    for (final word in queryWords) {
      if (memory.answer.toLowerCase().contains(word)) return 'transcript';
      if (memory.memoir?.text.toLowerCase().contains(word) ?? false) return 'memoir';
      if (memory.people.any((p) => p.toLowerCase().contains(word))) return 'people';
      if (memory.places.any((p) => p.toLowerCase().contains(word))) return 'places';
      if (memory.tags.any((t) => t.toLowerCase().contains(word))) return 'tags';
    }
    return 'transcript';
  }

  List<Memory> searchSimple(String query, List<Memory> memories) {
    return search(query, memories).map((r) => r.memory).toList();
  }
}
