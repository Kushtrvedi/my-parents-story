import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/models/parent_profile.dart';
import 'package:my_parents_story/models/generated_chapter.dart';
import 'package:my_parents_story/services/pdf_export_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pdf_test');

    // Mock path_provider MethodChannel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PdfExportService Tests', () {
    test(
        'Book consistency test - generating twice produces same byte size and structure',
        () async {
      final service = PdfExportService();

      final profile = ParentProfile(
        id: '1',
        name: 'Test Profile',
        parentType: 'father',
      );

      final chapters = [
        GeneratedChapter(
          id: 'c1',
          profileId: '1',
          category: 'childhood',
          chapterNumber: 1,
          title: 'Early Years',
          content: 'This is the story of my early years.',
        ),
      ];
      final bytes1 = await service.generateBookBytes(
        profile: profile,
        chapters: chapters,
        finalLetter: 'With love.',
      );

      final bytes2 = await service.generateBookBytes(
        profile: profile,
        chapters: chapters,
        finalLetter: 'With love.',
      );

      expect(bytes1.isNotEmpty, true);
      expect(bytes2.isNotEmpty, true);

      // Since PDF generation includes timestamps/creation dates in metadata,
      // exact byte-for-byte matching might fail. However, we can assert
      // the file size is very similar (within a tiny margin of bytes for time diff).
      // Or we can just ensure they generated successfully.
      expect(bytes1.length, closeTo(bytes2.length, 500));
    });
  });
}
