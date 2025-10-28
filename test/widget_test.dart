import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('switch language to English and load a classic riddle', (WidgetTester tester) async {
    await tester.pumpWidget(const RiddleApp());

    expect(find.text('Език'), findsOneWidget);
    expect(find.text('Добре дошли!'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Classic Riddles'), findsOneWidget);

    await tester.tap(find.text('Classic Riddles'));
    await tester.pump();

    expect(find.text('Loading a classic riddle...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('New'), findsOneWidget);
    expect(find.text('✨ AI Riddle'), findsOneWidget);

    const englishQuestions = <String>[
      'What has keys but can’t open locks?',
      'I speak without a mouth and hear without ears. What am I?',
      'What can travel around the world while staying in a corner?',
      'What has a heart that doesn’t beat?',
      'The more of this there is, the less you see. What is it?',
      'What has cities, but no houses; forests, but no trees; and water, but no fish?',
      'I have branches, but no fruit, trunk, or leaves. What am I?',
      'What building has the most stories?',
      'What is so fragile that saying its name breaks it?',
      'What runs around a backyard yet never moves?',
      'I shave every day, but my beard stays the same. Who am I?',
      'I’m light as a feather, yet the strongest person can’t hold me for five minutes.',
      'What has many teeth, but can’t bite?',
      'If you drop me I’m sure to crack, but give me a smile and I’ll always smile back.',
      'What begins with T, finishes with T, and has T inside it?',
    ];

    final bool foundQuestion = englishQuestions.any((question) => find.text(question).evaluate().isNotEmpty);
    expect(foundQuestion, isTrue);
  });
}
