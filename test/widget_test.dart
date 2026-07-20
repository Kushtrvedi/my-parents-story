import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/services/storage_service.dart';
import 'package:my_parents_story/services/template_book_service.dart';
import 'package:my_parents_story/services/local_storage.dart';
import 'package:my_parents_story/models/parent_profile.dart';
import 'package:my_parents_story/models/response.dart';
import 'package:my_parents_story/models/generated_chapter.dart';
import 'package:my_parents_story/data/questions.dart';
import 'package:my_parents_story/l10n/translations.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    storageService = StorageService();
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

      final response = storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'What is your earliest memory?',
        answer: 'I remember playing in the garden.',
      );

      expect(response.answer, equals('I remember playing in the garden.'));
      expect(response.hasAnswer, isTrue);
    });

    test('retrieves responses for a category', () {
      final profile = storageService.createProfile(
        name: 'Category Test',
        parentType: 'dad',
      );

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'Question 1',
        answer: 'Answer 1',
      );

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 1,
        question: 'Question 2',
        answer: 'Answer 2',
      );

      final responses = storageService.getResponsesForCategory(
        profile.id,
        'Childhood',
      );

      expect(responses.length, equals(2));
    });

    test('tracks completion progress', () {
      final profile = storageService.createProfile(
        name: 'Progress Test',
        parentType: 'mom',
      );

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'Q1',
        answer: 'A1',
      );

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Family',
        questionIndex: 0,
        question: 'Q1',
        answer: 'A1',
      );

      final progress = storageService.getCompletionProgress(profile.id);
      expect(progress['Childhood'], equals(1));
      expect(progress['Family'], equals(1));
    });

    test('deletes a profile and its responses', () {
      final profile = storageService.createProfile(
        name: 'Delete Test',
        parentType: 'mom',
      );

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'Q1',
        answer: 'A1',
      );

      storageService.deleteProfile(profile.id);

      final retrieved = storageService.getProfile(profile.id);
      expect(retrieved, isNull);
    });
  });

  group('QuestionDatabase', () {
    test('has exactly 12 categories', () {
      expect(QuestionDatabase.categories.length, equals(12));
    });

    test('has 300 total questions', () {
      expect(QuestionDatabase.totalQuestions, equals(300));
    });

    test('each category has exactly 25 questions', () {
      for (final category in QuestionDatabase.categories) {
        final questions = QuestionDatabase.getQuestionsForCategory(category);
        expect(
          questions.length,
          equals(25),
          reason: '$category should have 25 questions',
        );
      }
    });

    test('questions are not empty strings', () {
      for (final category in QuestionDatabase.categories) {
        final questions = QuestionDatabase.getQuestionsForCategory(category);
        for (final question in questions) {
          expect(question.isNotEmpty, isTrue, reason: 'Question should not be empty');
        }
      }
    });
  });

  group('Translations', () {
    test('loads English translations', () {
      T.load('en');
      expect(T.tr('appTitle'), isNot('appTitle'));
      expect(T.tr('tagline'), isNot('tagline'));
    });

    test('loads Hindi translations', () {
      T.load('hi');
      expect(T.tr('appTitle'), isNot('appTitle'));
      expect(T.tr('tagline'), isNot('tagline'));
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

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'What is your earliest memory?',
        answer: 'I remember the garden behind our house.',
      );

      final bookService = TemplateBookService(storageService);
      final responses = storageService.getResponsesForCategory(
        profile.id,
        'Childhood',
      );

      final content = bookService.generateChapter(
        profile,
        'Childhood',
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

      storageService.saveResponse(
        profileId: profile.id,
        category: 'Childhood',
        questionIndex: 0,
        question: 'Q1',
        answer: 'A meaningful answer about my life.',
      );

      final bookService = TemplateBookService(storageService);
      final allResponses = storageService.getResponsesForProfile(profile.id);

      final letter = bookService.generateFinalLetter(profile, allResponses);

      expect(letter.isNotEmpty, isTrue);
      expect(letter.contains('Letter Test'), isTrue);
      expect(letter.contains('Dear Family'), isTrue);
    });

    test('generates all chapters', () {
      final profile = storageService.createProfile(
        name: 'All Chapters Test',
        parentType: 'mom',
      );

      final bookService = TemplateBookService(storageService);
      final chapters = bookService.generateAllChapters(profile);

      expect(chapters.length, equals(12));
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

    test('StoryResponse toMap and fromMap', () {
      final response = StoryResponse(
        id: 'resp-id',
        profileId: 'profile-id',
        category: 'Childhood',
        questionIndex: 5,
        question: 'Test question?',
        answer: 'Test answer.',
      );

      final map = response.toMap();
      final restored = StoryResponse.fromMap(map);

      expect(restored.answer, equals('Test answer.'));
      expect(restored.category, equals('Childhood'));
      expect(restored.questionIndex, equals(5));
    });

    test('GeneratedChapter toMap and fromMap', () {
      final chapter = GeneratedChapter(
        id: 'ch-id',
        profileId: 'profile-id',
        category: 'Childhood',
        chapterNumber: 1,
        title: 'Childhood',
        content: 'Chapter content here.',
      );

      final map = chapter.toMap();
      final restored = GeneratedChapter.fromMap(map);

      expect(restored.title, equals('Childhood'));
      expect(restored.content, equals('Chapter content here.'));
      expect(restored.chapterNumber, equals(1));
    });
  });
}
