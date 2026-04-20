import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_messenger/main.dart';

void main() {
  testWidgets('shows anime chat list with required characters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Anime Chat'), findsOneWidget);
    expect(find.text('Marin Kitagawa (Марин Китагава)'), findsOneWidget);
    expect(find.text('Mai Sakurajima (Май Сакураджима)'), findsOneWidget);
    expect(find.text("Let's make a new cosplay!"), findsOneWidget);
    expect(find.text('Can you see me?'), findsOneWidget);
  });

  testWidgets('renders unread badge counts for active chats', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
