import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_parents_story/services/storage_service.dart';
import 'package:my_parents_story/services/template_book_service.dart';
import 'package:my_parents_story/models/parent_profile.dart';
import 'package:my_parents_story/models/memory.dart';
import 'package:my_parents_story/models/generated_chapter.dart';
import 'package:my_parents_story/models/question.dart';
import 'package:my_parents_story/data/questions.dart';
import 'package:my_parents_story/l10n/translations.dart';

void main() {
  late StorageService storageService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(dir.path);
    await Hive.openBox('profiles');
    await Hive.openBox('responses');
    await Hive.openBox('chapters');
    await Hive.openBox('settings');
  });

  setUp(() async {
    storageService = StorageService();
    await Hive.box('profiles').clear();
    await Hive.box('responses').clear();
    await Hive.box('chapters').clear();
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('StorageService', () {
    test('creates a parent profile', () {
      final profile = storageService.createProfile(
        name: 'Test Parent',
        parentType: 'mom',
        birthYear: '1955',
        city: 'Mumbai',
      );

      expect(profile.name, equals('Test Parent'));
      expect(profile.parentType, equals('mom'));
      expect(profile.birthYear, equals('1955'));
      expect(profile.city, equals('Mumbai'));
      expect(profile.id.isNotEmpty, isTrue);
    });

    test('retrieves a profile by id', () {
      final profile = storageService.createProfile(
        name: 'Retrieve Test',
        parentType: 'dad',
      );

      final retrieved = storageService.getProfile(profile.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Retrieve Test'));
    });

    test('lists all profiles', () {
      storageService.createProfile(name: 'Parent 1', parentType: 'mom');
      storageService.createProfile(name: 'Parent 2', parentType: 'dad');

      final profiles = storageService.getAllProfiles();
      expect(profiles.length, greaterThanOrEqualTo(2));
    });

    test('saves a response', () {
      final profile = storageService.createProfile(
        name: 'Response Test',
        parentType: 'mom',
      );

      final memory = storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'I remember playing in the garden.',
      );

      expect(memory.answer, equals('I remember playing in the garden.'));
      expect(memory.hasAnswer, isTrue);
    });

    test('retrieves responses for a chapter', () {
      final profile = storageService.createProfile(
        name: 'Category Test',
        parentType: 'dad',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'Answer 1',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q02',
        originalTranscript: 'Answer 2',
      );

      final responses = storageService.getMemoriesForChapter(
        profile.id,
        'ch01',
      );

      expect(responses.length, equals(2));
    });

    test('tracks completion progress', () {
      final profile = storageService.createProfile(
        name: 'Progress Test',
        parentType: 'mom',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'A1',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch02',
        questionId: 'ch02_q01',
        originalTranscript: 'A1',
      );

      final progress = storageService.getCompletionProgress(profile.id);
      expect(progress['ch01'], equals(1));
      expect(progress['ch02'], equals(1));
    });

    test('deletes a profile and its responses', () {
      final profile = storageService.createProfile(
        name: 'Delete Test',
        parentType: 'mom',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'A1',
      );

      storageService.deleteProfile(profile.id);

      final retrieved = storageService.getProfile(profile.id);
      expect(retrieved, isNull);
    });
  });

  group('QuestionDatabase', () {
    test('has exactly 20 chapters', () {
      expect(QuestionDatabase.chapters.length, equals(20));
    });

    test('has 300 total questions', () {
      expect(QuestionDatabase.totalQuestions, equals(300));
    });

    test('each chapter has exactly 15 questions', () {
      for (final chapter in QuestionDatabase.chapters) {
        final questions = QuestionDatabase.getQuestionsForChapter(chapter.id);
        expect(
          questions.length,
          equals(15),
          reason: '${chapter.title} should have 15 questions',
        );
      }
    });

    test('questions are not empty strings', () {
      for (final question in QuestionDatabase.questions) {
        expect(question.question.isNotEmpty, isTrue, reason: 'Question should not be empty');
      }
    });

    test('all question IDs are unique', () {
      final ids = QuestionDatabase.questions.map((q) => q.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, equals(uniqueIds.length), reason: 'All question IDs must be unique');
    });

    test('all question IDs follow format ch##_##', () {
      final idPattern = RegExp(r'^ch\d{2}_q\d{2}$');
      for (final question in QuestionDatabase.questions) {
        expect(
          idPattern.hasMatch(question.id),
          isTrue,
          reason: 'Question ID ${question.id} does not match format ch##_##',
        );
      }
    });

    test('chapters have valid IDs', () {
      final validIds = ['ch01', 'ch02', 'ch03', 'ch04', 'ch05', 'ch06', 'ch07', 'ch08', 'ch09', 'ch10',
        'ch11', 'ch12', 'ch13', 'ch14', 'ch15', 'ch16', 'ch17', 'ch18', 'ch19', 'ch20'];
      for (final chapter in QuestionDatabase.chapters) {
        expect(validIds.contains(chapter.id), isTrue, reason: 'Chapter ID ${chapter.id} is not valid');
      }
    });

    test('questions reference valid chapter IDs', () {
      final validChapterIds = QuestionDatabase.chapters.map((c) => c.id).toSet();
      for (final question in QuestionDatabase.questions) {
        expect(
          validChapterIds.contains(question.chapterId),
          isTrue,
          reason: 'Question ${question.id} references invalid chapter ${question.chapterId}',
        );
      }
    });
  });

  group('Translations', () {
    test('loads English translations', () {
      T.load('en');
      expect(T.tr('tagline'), isNot('tagline'));
      expect(T.tr('saveResponse'), equals('Save this memory'));
    });

    test('loads Hindi translations', () {
      T.load('hi');
      expect(T.tr('tagline'), isNot('tagline'));
      expect(T.tr('saveResponse'), equals('इस याद को सहेजें'));
    });

    test('returns key if translation missing', () {
      T.load('en');
      expect(T.tr('nonexistent_key'), equals('nonexistent_key'));
    });
  });

  group('TemplateBookService', () {
    test('generates a chapter from responses', () {
      final profile = storageService.createProfile(
        name: 'Template Test',
        parentType: 'mom',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'I remember the garden behind our house.',
      );

      final bookService = TemplateBookService(storageService);
      final responses = storageService.getMemoriesForChapter(
        profile.id,
        'ch01',
      );

      final content = bookService.generateChapter(
        profile,
        'ch01',
        responses,
      );

      expect(content.isNotEmpty, isTrue);
      expect(content.contains('garden'), isTrue);
    });

    test('generates a final letter', () {
      final profile = storageService.createProfile(
        name: 'Letter Test',
        parentType: 'dad',
      );

      storageService.saveMemory(
        profileId: profile.id,
        chapterId: 'ch01',
        questionId: 'ch01_q01',
        originalTranscript: 'A meaningful answer about my life.',
      );

      final bookService = TemplateBookService(storageService);
      final allResponses = storageService.getMemoriesForProfile(profile.id);

      final letter = bookService.generateFinalLetter(profile, allResponses);

      expect(letter.isNotEmpty, isTrue);
      expect(letter.contains('Letter Test'), isTrue);
      expect(letter.contains('Dear Family'), isTrue);
    });

    test('generates all 20 chapters', () {
      final profile = storageService.createProfile(
        name: 'All Chapters Test',
        parentType: 'mom',
      );

      final bookService = TemplateBookService(storageService);
      final chapters = bookService.generateAllChapters(profile);

      expect(chapters.length, equals(20));
    });
  });

  group('Models', () {
    test('ParentProfile toMap and fromMap', () {
      final profile = ParentProfile(
        id: 'test-id',
        name: 'Model Test',
        parentType: 'mom',
        birthYear: '1960',
        city: 'Delhi',
      );

      final map = profile.toMap();
      final restored = ParentProfile.fromMap(map);

      expect(restored.name, equals('Model Test'));
      expect(restored.parentType, equals('mom'));
      expect(restored.birthYear, equals('1960'));
      expect(restored.city, equals('Delhi'));
    });

    test('Memory toMap and fromMap', () {
      final memory = Memory(
        id: 'mem-id',
        parentId: 'profile-id',
        chapterId: 'ch01',
        questionId: 'ch01_q06',
        originalTranscript: 'Test answer.',
      );

      final map = memory.toMap();
      final restored = Memory.fromMap(map);

      expect(restored.answer, equals('Test answer.'));
      expect(restored.chapterId, equals('ch01'));
      expect(restored.questionId, equals('ch01_q06'));
    });

    test('GeneratedChapter toMap and fromMap', () {
      final chapter = GeneratedChapter(
        id: 'ch-id',
        profileId: 'profile-id',
        category: 'ch01',
        chapterNumber: 1,
        title: 'Roots and Family Origins',
        content: 'Chapter content here.',
      );

      final map = chapter.toMap();
      final restored = GeneratedChapter.fromMap(map);

      expect(restored.title, equals('Roots and Family Origins'));
      expect(restored.content, equals('Chapter content here.'));
      expect(restored.chapterNumber, equals(1));
    });

    test('Question model toMap and fromMap', () {
      final question = Question(
        id: 'ch01_q01',
        chapterId: 'ch01',
        chapterNumber: 1,
        questionNumber: 1,
        question: 'Where does your family come from?',
        purpose: 'Establishes family roots',
        expectedMemoryType: ExpectedMemoryType.factual,
        emotionalTone: EmotionalTone.warm,
        estimatedDuration: EstimatedDuration.medium,
        searchTags: ['family', 'origins'],
        people: ['parents'],
        places: ['hometown'],
        difficulty: Difficulty.easy,
        priority: QuestionPriority.core,
        followUps: ['Can you tell me more?', 'What do you remember?'],
      );

      final map = question.toMap();
      final restored = Question.fromMap(map);

      expect(restored.id, equals('ch01_q01'));
      expect(restored.question, equals('Where does your family come from?'));
      expect(restored.emotionalTone, equals(EmotionalTone.warm));
      expect(restored.followUps.length, equals(2));
    });

    test('Chapter model toMap and fromMap', () {
      final chapter = Chapter(
        number: 1,
        id: 'ch01',
        title: 'Roots and Family Origins',
        description: 'Exploring where your family came from.',
        icon: '🌳',
      );

      final map = chapter.toMap();
      final restored = Chapter.fromMap(map);

      expect(restored.title, equals('Roots and Family Origins'));
      expect(restored.id, equals('ch01'));
      expect(restored.icon, equals('🌳'));
    });
  });
}
