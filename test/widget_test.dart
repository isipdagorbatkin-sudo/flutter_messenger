import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_messenger/main.dart';

void main() {
  testWidgets('shows anime chat list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Anime Messenger'), findsOneWidget);
    expect(find.text('Marin Kitagawa'), findsOneWidget);
    expect(find.text('Mai Sakurajima'), findsOneWidget);
  });

  testWidgets('opens chat detail and toggles mic to send', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Marin Kitagawa'));
    await tester.pumpAndSettle();

    expect(find.text('Marin Kitagawa'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hi!');
    await tester.pump();

    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });
}
