import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE58AE6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF3FB),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFFFE3F7),
          foregroundColor: Color(0xFF5A2C76),
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5A2C76),
          ),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(color: Color(0xFF5F4C71)),
        ),
      ),
      home: const ChatListScreen(),
    );
  }
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const List<ChatItem> chats = [
    ChatItem(
      name: 'Marin Kitagawa (Марин Китагава)',
      message: "Let's make a new cosplay!",
      timestamp: '09:41',
      unreadCount: 3,
      avatarColor: Color(0xFFFFA4D7),
    ),
    ChatItem(
      name: 'Mai Sakurajima (Май Сакураджима)',
      message: 'Can you see me?',
      timestamp: '08:12',
      unreadCount: 1,
      avatarColor: Color(0xFFA5C7FF),
    ),
    ChatItem(
      name: 'Rem',
      message: 'I made tea for you. Take a break ☕',
      timestamp: 'Yesterday',
      unreadCount: 0,
      avatarColor: Color(0xFF9FD9FF),
    ),
    ChatItem(
      name: 'Megumin',
      message: 'Explosion magic is ready! ✨',
      timestamp: 'Yesterday',
      unreadCount: 5,
      avatarColor: Color(0xFFFFC58A),
    ),
    ChatItem(
      name: 'Asuna',
      message: 'Party at 8? I will bring snacks.',
      timestamp: 'Mon',
      unreadCount: 2,
      avatarColor: Color(0xFFFFB4B4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Chat'),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: chat.avatarColor,
              child: Text(
                _initials(chat.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(chat.name),
            subtitle: Text(chat.message, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.timestamp,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    key: ValueKey('unread-${chat.name}'),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _initials(String name) {
    final sanitized = name.replaceAll(RegExp(r'[^A-Za-zА-Яа-яЁё ]'), ' ').trim();
    final words = sanitized
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList();
    if (words.isEmpty) {
      return '?';
    }
    return words.map((word) => word.substring(0, 1).toUpperCase()).join();
  }
}

class ChatItem {
  const ChatItem({
    required this.name,
    required this.message,
    required this.timestamp,
    required this.unreadCount,
    required this.avatarColor,
  });

  final String name;
  final String message;
  final String timestamp;
  final int unreadCount;
  final Color avatarColor;
}
