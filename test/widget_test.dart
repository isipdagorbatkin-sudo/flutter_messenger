import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_messenger/main.dart';

void main() {
  testWidgets('shows anime themed chat screen elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Anime Messenger'), findsOneWidget);
    expect(find.text('Marin Kitagawa'), findsWidgets);
    expect(find.text('Mai Sakurajima'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('send button enables with text and appends message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    IconButton sendButton = tester.widget(find.byIcon(Icons.send_rounded));
    expect(sendButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'See you at the anime cafe!');
    await tester.pump();

    sendButton = tester.widget(find.byIcon(Icons.send_rounded));
    expect(sendButton.onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(find.text('See you at the anime cafe!'), findsOneWidget);
  });
}
