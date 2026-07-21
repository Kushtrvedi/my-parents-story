import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/models/memory.dart';
import 'package:my_parents_story/services/memory_search.dart';

void main() {
  group('MemorySearchEngine Tests', () {
    late MemorySearchEngine searchEngine;
    late List<Memory> testMemories;

    setUp(() {
      searchEngine = MemorySearchEngine();
      testMemories = [
        Memory(
          id: '1',
          parentId: 'p1',
          chapterId: 'childhood',
          questionId: 'q1',
          originalTranscript: 'We used to play outside in the sunshine.',
        ),
        Memory(
          id: '2',
          parentId: 'p1',
          chapterId: 'career',
          questionId: 'q2',
          originalTranscript: 'My first job was in a small local shop.',
        ),
        Memory(
          id: '3',
          parentId: 'p1',
          chapterId: 'family',
          questionId: 'q3',
          originalTranscript: 'Sunday dinners were the best memory of my youth.',
        ),
      ];
    });

    test('Search finds exact match in transcript', () {
      final results = searchEngine.searchSimple('sunshine', testMemories);
      expect(results.length, 1);
      expect(results.first.id, '1');
    });

    test('Search finds partial match case-insensitive', () {
      final results = searchEngine.searchSimple('SHOP', testMemories);
      expect(results.length, 1);
      expect(results.first.id, '2');
    });

    test('Search returns empty for no match', () {
      final results = searchEngine.searchSimple('astronaut', testMemories);
      expect(results.isEmpty, true);
    });

    test('Search finds multiple results', () {
      final results = searchEngine.searchSimple('my', testMemories);
      // id 2 ('My first job...') and id 3 ('...memory of my youth.')
      expect(results.length, 2);
    });
  });
}
