import 'package:flutter/material.dart';
import 'package:flutter_messenger/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anime Messenger',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A102B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF120A20),
          foregroundColor: Color(0xFFFFB8E6),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8FD6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
