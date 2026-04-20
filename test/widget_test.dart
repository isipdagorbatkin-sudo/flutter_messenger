import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_messenger/chat_screen.dart';

void main() {
  testWidgets('shows anime themed chat screen with decorative avatars only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(
          messagesStream: Stream.empty(),
          currentUserId: 'me',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Anime Messenger'), findsOneWidget);
    expect(find.text('Marin Kitagawa'), findsWidgets);
    expect(find.text('Mai Sakurajima'), findsWidgets);
    expect(find.text('I found the cutest cosplay idea for us ✨'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('send button enables with text and calls send callback', (
    WidgetTester tester,
  ) async {
    String? sentText;
    await tester.pumpWidget(
      MaterialApp(
        home: ChatScreen(
          messagesStream: Stream.value(const []),
          currentUserId: 'me',
          onSendMessage: (text) async => sentText = text,
        ),
      ),
    );
    await tester.pump();

    IconButton sendButton = tester.widget(find.byIcon(Icons.send_rounded));
    expect(sendButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'See you at the anime cafe!');
    await tester.pump();

    sendButton = tester.widget(find.byIcon(Icons.send_rounded));
    expect(sendButton.onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(sentText, 'See you at the anime cafe!');
  });
}
