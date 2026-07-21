import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/services/local_storage.dart';
import 'package:my_parents_story/services/storage_service.dart';

void main() {
  late StorageService storageService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('my_parents_story_test');
    await LocalStorage.init(testPath: tempDir.path);
    storageService = StorageService();
  });

  tearDown(() async {
    await LocalStorage.clearAll();
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('StorageService Tests', () {
    test('Can create and retrieve a profile', () {
      final profile = storageService.createProfile(
        name: 'Test Mom',
        parentType: 'mom',
        birthYear: '1970',
      );

      final retrieved = storageService.getProfile(profile.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Mom');
    });

    test('Can save and retrieve a memory', () {
      final profile = storageService.createProfile(
        name: 'Test Dad',
        parentType: 'dad',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'childhood',
        questionId: 'q_1',
        originalTranscript: 'My childhood memory.',
      );

      final retrieved = storageService.getMemory(profile.id, 'childhood', 'q_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.originalTranscript, 'My childhood memory.');
    });
  });
}
