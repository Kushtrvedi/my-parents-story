import '../models/memory.dart';

class QualityDimension {
  final String name;
  final double score;
  final String reason;

  const QualityDimension({required this.name, required this.score, required this.reason});
}

class MemoryQualityScore {
  final String memoryId;
  final double overallScore;
  final List<QualityDimension> dimensions;

  const MemoryQualityScore({
    required this.memoryId,
    required this.overallScore,
    required this.dimensions,
  });

  String get grade {
    if (overallScore >= 0.9) return 'excellent';
    if (overallScore >= 0.7) return 'good';
    if (overallScore >= 0.5) return 'fair';
    return 'needs_more';
  }
}

class QualityScoringService {
  MemoryQualityScore scoreMemory(Memory memory) {
    final dimensions = <QualityDimension>[];

    dimensions.add(_scoreTranscript(memory));
    dimensions.add(_scoreMemoir(memory));
    dimensions.add(_scorePeople(memory));
    dimensions.add(_scorePlaces(memory));
    dimensions.add(_scoreTags(memory));
    dimensions.add(_scoreRecording(memory));
    dimensions.add(_scoreChapterAssignment(memory));

    final totalScore = dimensions.fold(0.0, (sum, d) => sum + d.score) / dimensions.length;

    return MemoryQualityScore(
      memoryId: memory.id,
      overallScore: totalScore,
      dimensions: dimensions,
    );
  }

  List<MemoryQualityScore> scoreAll(List<Memory> memories) {
    return memories.map(scoreMemory).toList();
  }

  QualityDimension _scoreTranscript(Memory memory) {
    final hasTranscript = memory.originalTranscript != null && memory.originalTranscript!.trim().isNotEmpty;
    final length = memory.originalTranscript?.trim().length ?? 0;

    if (!hasTranscript) {
      return const QualityDimension(name: 'transcript', score: 0.0, reason: 'No transcript available');
    }
    if (length < 20) {
      return const QualityDimension(name: 'transcript', score: 0.3, reason: 'Very short transcript');
    }
    if (length < 100) {
      return const QualityDimension(name: 'transcript', score: 0.7, reason: 'Brief transcript');
    }
    return const QualityDimension(name: 'transcript', score: 1.0, reason: 'Good transcript');
  }

  QualityDimension _scoreMemoir(Memory memory) {
    if (memory.memoir == null) {
      return const QualityDimension(name: 'memoir', score: 0.0, reason: 'No memoir generated');
    }
    final length = memory.memoir!.text.trim().length;
    if (length < 50) {
      return const QualityDimension(name: 'memoir', score: 0.5, reason: 'Short memoir');
    }
    return const QualityDimension(name: 'memoir', score: 1.0, reason: 'Memoir available');
  }

  QualityDimension _scorePeople(Memory memory) {
    if (memory.people.isEmpty) {
      return const QualityDimension(name: 'people', score: 0.0, reason: 'No people identified');
    }
    if (memory.people.length == 1) {
      return const QualityDimension(name: 'people', score: 0.7, reason: 'One person identified');
    }
    return QualityDimension(name: 'people', score: 1.0, reason: '${memory.people.length} people identified');
  }

  QualityDimension _scorePlaces(Memory memory) {
    if (memory.places.isEmpty) {
      return const QualityDimension(name: 'places', score: 0.0, reason: 'No places identified');
    }
    return QualityDimension(name: 'places', score: 1.0, reason: '${memory.places.length} places identified');
  }

  QualityDimension _scoreTags(Memory memory) {
    if (memory.tags.isEmpty) {
      return const QualityDimension(name: 'tags', score: 0.0, reason: 'No tags');
    }
    if (memory.tags.length < 3) {
      return QualityDimension(name: 'tags', score: 0.5, reason: '${memory.tags.length} tags');
    }
    return QualityDimension(name: 'tags', score: 1.0, reason: '${memory.tags.length} tags');
  }

  QualityDimension _scoreRecording(Memory memory) {
    if (memory.originalRecording == null) {
      return const QualityDimension(name: 'recording', score: 0.0, reason: 'No recording');
    }
    final durationMs = memory.originalRecording!.duration.inMilliseconds;
    if (durationMs < 5000) {
      return const QualityDimension(name: 'recording', score: 0.3, reason: 'Very short recording');
    }
    return const QualityDimension(name: 'recording', score: 1.0, reason: 'Recording available');
  }

  QualityDimension _scoreChapterAssignment(Memory memory) {
    if (memory.chapterId.isEmpty) {
      return const QualityDimension(name: 'chapter', score: 0.0, reason: 'No chapter assigned');
    }
    return const QualityDimension(name: 'chapter', score: 1.0, reason: 'Chapter assigned');
  }
}
