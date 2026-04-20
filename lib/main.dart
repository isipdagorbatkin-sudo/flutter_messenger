import 'package:flutter/material.dart';
import 'package:flutter_messenger/chat_detail_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF7B8D9),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFDDF0),
          foregroundColor: Color(0xFF5A3C54),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const ChatListScreen(),
    );
  }
}

class ChatCharacter {
  const ChatCharacter({
    required this.name,
    required this.avatarText,
    required this.lastMessage,
  });

  final String name;
  final String avatarText;
  final String lastMessage;
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const List<ChatCharacter> _characters = [
    ChatCharacter(
      name: 'Marin Kitagawa',
      avatarText: 'M',
      lastMessage: 'Let\'s cosplay this weekend! ✨',
    ),
    ChatCharacter(
      name: 'Mai Sakurajima',
      avatarText: 'M',
      lastMessage: 'I\'ll wait for your message 🌙',
    ),
    ChatCharacter(
      name: 'Zero Two',
      avatarText: 'Z',
      lastMessage: 'Darling, are you there? 💕',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime Messenger')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _characters.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final character = _characters[index];
          return Material(
            color: const Color(0xFFFFEAF5),
            borderRadius: BorderRadius.circular(18),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFF7B8D9),
                child: Text(
                  character.avatarText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              title: Text(
                character.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5A3C54),
                ),
              ),
              subtitle: Text(
                character.lastMessage,
                style: const TextStyle(color: Color(0xFF8B6B84)),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (_) => ChatDetailScreen(
                          characterName: character.name,
                          avatarText: character.avatarText,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
