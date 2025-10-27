import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('shows welcome screen and loads classic riddle', (WidgetTester tester) async {
    await tester.pumpWidget(const RiddleApp());

    expect(find.text('Добре дошли!'), findsOneWidget);
    expect(find.text('Класически Гатанки'), findsOneWidget);

    await tester.tap(find.text('Класически Гатанки'));
    await tester.pump();

    expect(find.text('Зареждане на класическа гатанка...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Нова'), findsOneWidget);
    expect(find.text('✨ AI Гатанка'), findsOneWidget);

    const classicQuestions = <String>[
      'Винаги тича, а никога не мърда. Що е то?',
      'Когато го кажеш, то изчезва. Що е то?',
      'Пълна къща, а прозорците стърчат навън. Що е то?',
      'Имам очи, а не виждам. Що е то?',
      'Все върви, а крака няма. Що е то?',
      'Старо кога се роди, младо кога умре. Що е то?',
      'Не пия вода, а без вода умирам. Що е то?',
      'Висока, тънка, глас няма, а песни пее. Що е то?',
      'Глава има, очи няма, крила има, лети не може. Що е то?',
      'Сто зъба, а не хапе. Що е то?',
    ];

    final bool foundQuestion = classicQuestions.any((question) => find.text(question).evaluate().isNotEmpty);
    expect(foundQuestion, isTrue);
  });
}
