import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/models/memory.dart';
import 'package:my_parents_story/models/parent_profile.dart';
import 'package:my_parents_story/models/voice_recording.dart';
import 'package:my_parents_story/models/photo.dart';

void main() {
  group('Model Serialization Tests', () {
    test('ParentProfile serialization and deserialization', () {
      final profile = ParentProfile(
        id: '123',
        name: 'Jane Doe',
        parentType: 'mom',
        birthYear: '1960',
        city: 'New York',
      );

      final map = profile.toMap();
      final fromMap = ParentProfile.fromMap(map);

      expect(fromMap.id, '123');
      expect(fromMap.name, 'Jane Doe');
      expect(fromMap.parentType, 'mom');
      expect(fromMap.birthYear, '1960');
      expect(fromMap.city, 'New York');
    });

    test('VoiceRecording serialization and deserialization', () {
      final recording = VoiceRecording(
        id: 'rec_1',
        file: 'recordings/rec_1.m4a',
        duration: const Duration(seconds: 45),
        language: 'en',
      );

      final map = recording.toMap();
      final fromMap = VoiceRecording.fromMap(map);

      expect(fromMap.id, 'rec_1');
      expect(fromMap.file, 'recordings/rec_1.m4a');
      expect(fromMap.duration.inSeconds, 45);
      expect(fromMap.language, 'en');
    });

    test('Memory serialization and deserialization', () {
      final memory = Memory(
        id: 'mem_1',
        parentId: '123',
        chapterId: 'childhood',
        questionId: 'q_1',
        originalTranscript: 'This is my transcript.',
      );

      final map = memory.toMap();
      final fromMap = Memory.fromMap(map);

      expect(fromMap.id, 'mem_1');
      expect(fromMap.parentId, '123');
      expect(fromMap.chapterId, 'childhood');
      expect(fromMap.questionId, 'q_1');
      expect(fromMap.questionId, 'q_1');
      expect(fromMap.originalTranscript, 'This is my transcript.');
      expect(fromMap.hasAnswer, true);
    });

    test('Photo serialization and deserialization', () {
      final date = DateTime(2023, 1, 1);
      final photo = Photo(
        id: 'photo_1',
        path: 'photos/photo_1.jpg',
        caption: 'A sunny day',
        takenDate: date,
        people: ['Mom', 'Dad'],
      );

      final map = photo.toMap();
      final fromMap = Photo.fromMap(map);

      expect(fromMap.id, 'photo_1');
      expect(fromMap.path, 'photos/photo_1.jpg');
      expect(fromMap.caption, 'A sunny day');
      expect(fromMap.takenDate.toIso8601String(), date.toIso8601String());
      expect(fromMap.people, ['Mom', 'Dad']);
    });
  });
}
