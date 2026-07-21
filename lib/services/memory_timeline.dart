import '../models/memory.dart';
import '../core/utils/utils.dart';

class TimelineEntry {
  final int? year;
  final List<Memory> memories;

  const TimelineEntry({required this.year, required this.memories});

  int get sortKey => year ?? 9999;
}

class MemoryTimeline {
  final List<TimelineEntry> entries;
  final int? earliestYear;
  final int? latestYear;
  final int totalMemories;
  final List<int> missingYears;

  const MemoryTimeline({
    required this.entries,
    this.earliestYear,
    this.latestYear,
    required this.totalMemories,
    required this.missingYears,
  });

  factory MemoryTimeline.fromMemories(List<Memory> memories, {int? birthYear}) {
    if (memories.isEmpty) {
      return const MemoryTimeline(
        entries: [],
        totalMemories: 0,
        missingYears: [],
      );
    }

    final yearGroups = <int, List<Memory>>{};

    for (final memory in memories) {
      final year = _extractYear(memory, birthYear: birthYear);
      if (year != null) {
        yearGroups.putIfAbsent(year, () => []).add(memory);
      }
    }

    if (yearGroups.isEmpty) {
      return MemoryTimeline(
        entries: [TimelineEntry(year: null, memories: memories)],
        totalMemories: memories.length,
        missingYears: [],
      );
    }

    final sortedYears = yearGroups.keys.toList()..sort();
    final entries = sortedYears.map((year) {
      final yearMemories = yearGroups[year]!..sort((a, b) => a.chapterId.compareTo(b.chapterId));
      return TimelineEntry(year: year, memories: yearMemories);
    }).toList();

    final missingYears = <int>[];
    if (sortedYears.length > 1) {
      for (var y = sortedYears.first; y <= sortedYears.last; y++) {
        if (!yearGroups.containsKey(y)) {
          missingYears.add(y);
        }
      }
    }

    return MemoryTimeline(
      entries: entries,
      earliestYear: sortedYears.first,
      latestYear: sortedYears.last,
      totalMemories: memories.length,
      missingYears: missingYears,
    );
  }

  static int? _extractYear(Memory memory, {int? birthYear}) {
    final text = memory.answer;
    if (text.isEmpty) return null;

    final explicitYear = DateExtractor.extractYear(text);
    if (explicitYear != null) return explicitYear;

    final age = DateExtractor.extractAge(text);
    if (age != null && birthYear != null) {
      return birthYear + age;
    }

    return null;
  }

  List<Memory> getMemoriesForYear(int year) {
    for (final entry in entries) {
      if (entry.year == year) return entry.memories;
    }
    return [];
  }

  List<Memory> getMemoriesNearYear(int year, {int range = 2}) {
    return entries
        .where((e) => e.year != null && (e.year! - year).abs() <= range)
        .expand((e) => e.memories)
        .toList();
  }
}
