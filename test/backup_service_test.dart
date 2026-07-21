import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/services/local_storage.dart';
import 'package:my_parents_story/services/storage_service.dart';
import 'package:my_parents_story/services/backup_service.dart';

void main() {
  late StorageService storageService;
  late BackupService backupService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('my_parents_story_backup_test');
    await LocalStorage.init(testPath: tempDir.path);
    storageService = StorageService();
    backupService = BackupService(storageService);
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

  group('BackupService Tests', () {
    test('Export and import preserves data', () async {
      // 1. Setup data
      final profile = storageService.createProfile(
        name: 'Grandpa',
        parentType: 'grandpa',
      );
      
      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'youth',
        questionId: 'q_2',
        originalTranscript: 'A long time ago...',
      );

      // 2. Export
      final jsonExport = await backupService.exportToJson();
      expect(jsonExport, contains('Grandpa'));
      expect(jsonExport, contains('A long time ago...'));

      // 3. Clear storage to simulate fresh install
      await LocalStorage.clearAll();
      final profilesAfterClear = storageService.getAllProfiles();
      expect(profilesAfterClear.isEmpty, true);

      // 4. Import
      final success = await backupService.importFromJson(jsonExport);
      expect(success, true);

      // 5. Verify restored data
      final restoredProfiles = storageService.getAllProfiles();
      expect(restoredProfiles.length, 1);
      expect(restoredProfiles.first.name, 'Grandpa');

      final restoredMemories = storageService.getMemoriesForProfile(restoredProfiles.first.id);
      expect(restoredMemories.length, 1);
      expect(restoredMemories.first.originalTranscript, 'A long time ago...');
    });
  });
}
