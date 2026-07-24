import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_parents_story/screens/landing_screen.dart';
import 'package:my_parents_story/screens/setup_wizard_screen.dart';
import 'package:my_parents_story/screens/profile_type_screen.dart';
import 'package:my_parents_story/screens/profile_screen.dart';
import 'package:my_parents_story/screens/pre_question_screen.dart';
import 'package:my_parents_story/screens/question_screen.dart';
import 'package:my_parents_story/screens/life_journey_screen.dart';
import 'package:my_parents_story/screens/book_preview_screen.dart';
import 'package:my_parents_story/screens/generate_book_screen.dart';
import 'package:my_parents_story/screens/celebration_screen.dart';
import 'package:my_parents_story/screens/share_memory_screen.dart';
import 'package:my_parents_story/screens/legacy_thanks_screen.dart';

import 'package:my_parents_story/models/parent_profile.dart';
import 'package:my_parents_story/models/memory.dart';
import 'package:my_parents_story/models/generated_chapter.dart';
import 'package:hive_test/hive_test.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() async {
    await setUpTestHive();
    await Hive.openBox('profiles');
    await Hive.openBox('responses');
    await Hive.openBox('chapters');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await tearDownTestHive();
  });

  final testSizes = <Size>[
    const Size(320, 568),
    const Size(360, 640),
    const Size(393, 852),
    const Size(412, 892),
    const Size(600, 1024),
    const Size(768, 1024),
    const Size(840, 1200),
    const Size(1024, 768),
    const Size(1280, 800),
    const Size(1440, 900),
    const Size(1600, 900),
  ];

  Widget buildTestApp({
    required Widget child,
    required Size size,
    double textScaleFactor = 1.0,
    bool highContrast = false,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      highContrastTheme: ThemeData.light(),
      themeMode: highContrast ? ThemeMode.light : ThemeMode.system,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScaleFactor),
          highContrast: highContrast,
        ),
        child: child,
      ),
    );
  }

  final dummyProfile =
      ParentProfile(id: '1', name: 'John Doe', parentType: 'father');

  final dummyMemory = Memory(
    id: '1',
    questionId: '1',
    chapterId: '1',
    parentId: '1',
  );

  final dummyBook =
      GeneratedBook(profileId: '1', chapters: [], finalLetter: '');

  final Map<String, Widget Function()> screens = {
    'LandingScreen': () => const LandingScreen(),
    'SetupWizardScreen': () => const SetupWizardScreen(),
    'ProfileTypeScreen': () => const ProfileTypeScreen(),
    'ProfileScreen': () => const ProfileScreen(parentType: 'father'),
    'PreQuestionScreen': () => PreQuestionScreen(
        profile: dummyProfile, chapterId: '1', chapterIndex: 0),
    'QuestionScreen': () =>
        QuestionScreen(profile: dummyProfile, chapterId: '1', chapterIndex: 0),
    'LifeJourneyScreen': () => LifeJourneyScreen(profile: dummyProfile),
    'BookPreviewScreen': () =>
        BookPreviewScreen(profile: dummyProfile, book: dummyBook),
    'GenerateBookScreen': () => GenerateBookScreen(profile: dummyProfile),
    'CelebrationScreen': () =>
        CelebrationScreen(profile: dummyProfile, book: dummyBook),
    'ShareMemoryScreen': () =>
        ShareMemoryScreen(profile: dummyProfile, memory: dummyMemory),
    'LegacyThanksScreen': () =>
        LegacyThanksScreen(profile: dummyProfile, book: dummyBook),
  };

  group('Adaptive Architecture Validation:', () {
    for (final screenEntry in screens.entries) {
      final screenName = screenEntry.key;
      final screenBuilder = screenEntry.value;

      group(screenName, () {
        for (final size in testSizes) {
          testWidgets('Portrait - ${size.width}x${size.height}',
              (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(buildTestApp(
              child: screenBuilder(),
              size: size,
            ));
            await tester.pump(const Duration(seconds: 5));

            expect(tester.takeException(), isNull);

            addTearDown(tester.view.resetPhysicalSize);
          });

          testWidgets('Landscape - ${size.height}x${size.width}',
              (tester) async {
            final landscapeSize = Size(size.height, size.width);
            tester.view.physicalSize = landscapeSize;
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(buildTestApp(
              child: screenBuilder(),
              size: landscapeSize,
            ));
            await tester.pump(const Duration(seconds: 5));

            expect(tester.takeException(), isNull);

            addTearDown(tester.view.resetPhysicalSize);
          });

          testWidgets(
              'Accessibility (200% Text, High Contrast) - ${size.width}x${size.height}',
              (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;

            await tester.pumpWidget(buildTestApp(
              child: screenBuilder(),
              size: size,
              textScaleFactor: 2.0,
              highContrast: true,
            ));
            await tester.pump(const Duration(seconds: 5));

            expect(tester.takeException(), isNull);

            addTearDown(tester.view.resetPhysicalSize);
          });
        }
      });
    }
  });
}
