import '../models/memory.dart';
import '../core/extensions/string_extensions.dart';

class DuplicateCandidate {
  final Memory existing;
  final Memory incoming;
  final double similarity;
  final String matchType;

  const DuplicateCandidate({
    required this.existing,
    required this.incoming,
    required this.similarity,
    required this.matchType,
  });
}

class DuplicateDetector {
  static const double _highThreshold = 0.85;
  static const double _mediumThreshold = 0.65;

  List<DuplicateCandidate> findDuplicates(Memory incoming, List<Memory> existingMemories) {
    final candidates = <DuplicateCandidate>[];

    for (final existing in existingMemories) {
      if (existing.id == incoming.id) continue;

      final similarity = _calculateSimilarity(incoming, existing);
      if (similarity >= _mediumThreshold) {
        final matchType = _determineMatchType(incoming, existing);
        candidates.add(DuplicateCandidate(
          existing: existing,
          incoming: incoming,
          similarity: similarity,
          matchType: matchType,
        ));
      }
    }

    candidates.sort((a, b) => b.similarity.compareTo(a.similarity));
    return candidates;
  }

  double _calculateSimilarity(Memory a, Memory b) {
    double score = 0;
    int factors = 0;

    final textSimilarity = a.answer.similarityTo(b.answer);
    score += textSimilarity;
    factors++;

    if (a.people.isNotEmpty && b.people.isNotEmpty) {
      final commonPeople = a.people.where((p) => b.people.contains(p)).length;
      score += commonPeople / (a.people.length + b.people.length - commonPeople);
      factors++;
    }

    if (a.places.isNotEmpty && b.places.isNotEmpty) {
      final commonPlaces = a.places.where((p) => b.places.contains(p)).length;
      score += commonPlaces / (a.places.length + b.places.length - commonPlaces);
      factors++;
    }

    if (a.chapterId == b.chapterId) {
      score += 0.3;
      factors++;
    }

    return factors > 0 ? score / factors : 0;
  }

  String _determineMatchType(Memory incoming, Memory existing) {
    if (incoming.chapterId == existing.chapterId && incoming.questionId == existing.questionId) {
      return 'same_question';
    }
    if (incoming.chapterId == existing.chapterId) {
      return 'same_chapter';
    }
    return 'cross_chapter';
  }

  bool isLikelyDuplicate(Memory incoming, List<Memory> existingMemories) {
    final duplicates = findDuplicates(incoming, existingMemories);
    return duplicates.any((d) => d.similarity >= _highThreshold);
  }
}
