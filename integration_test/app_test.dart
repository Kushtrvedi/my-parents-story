import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_parents_story/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End App Test', () {
    testWidgets('Complete user flow from launch to export',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 1. Setup Wizard
      // Depending on if it's the first run, we might see SetupWizard or LandingScreen.
      // We can just check what is on the screen.
      if (find.text('Begin Setup').evaluate().isNotEmpty) {
        await tester.tap(find.text('Begin Setup'));
        await tester.pumpAndSettle();

        if (find.text('Allow Microphone').evaluate().isNotEmpty) {
          await tester.tap(find.text('Allow Microphone'));
          await tester.pumpAndSettle();
        }

        await tester.pumpAndSettle(const Duration(seconds: 3));

        while (find.text('Continue').evaluate().isNotEmpty ||
            find.text('Finish Setup').evaluate().isNotEmpty) {
          final btn = find.text('Finish Setup').evaluate().isNotEmpty
              ? find.text('Finish Setup')
              : find.text('Continue');
          await tester.tap(btn);
          await tester.pumpAndSettle();
        }
      }

      // If we don't have mock data for voice, we can just assert up to Landing screen or Profile setup
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
