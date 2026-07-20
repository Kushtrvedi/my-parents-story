import 'package:flutter_test/flutter_test.dart';
import 'package:my_parents_story/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MyParentsStoryApp());
    expect(find.text("Every Parent Carries\nA Library Inside Them."), findsOneWidget);
  });
}
