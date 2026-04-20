import 'package:flutter/material.dart';

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
                    builder: (_) => ChatDetailScreen(character: character),
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

enum ChatMessageType { text, image, voice }

class ChatMessage {
  const ChatMessage({
    required this.isMe,
    required this.type,
    this.text,
    this.duration,
  });

  final bool isMe;
  final ChatMessageType type;
  final String? text;
  final String? duration;
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.character});

  final ChatCharacter character;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  String _draft = '';

  static const List<ChatMessage> _mockMessages = [
    ChatMessage(
      isMe: false,
      type: ChatMessageType.text,
      text: 'Hey! Ready for anime night? 🌸',
    ),
    ChatMessage(
      isMe: true,
      type: ChatMessageType.text,
      text: 'Always ready! What are we watching?',
    ),
    ChatMessage(isMe: false, type: ChatMessageType.image),
    ChatMessage(
      isMe: false,
      type: ChatMessageType.voice,
      duration: '0:18',
    ),
    ChatMessage(
      isMe: true,
      type: ChatMessageType.text,
      text: 'That voice note is adorable 💖',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFF7B8D9),
              child: Text(
                widget.character.avatarText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.character.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              itemCount: _mockMessages.length,
              itemBuilder: (context, index) {
                final message = _mockMessages[index];
                return Align(
                  alignment:
                      message.isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          message.isMe
                              ? const Color(0xFFFFD2EA)
                              : const Color(0xFFEBD9FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildMessageContent(message),
                  ),
                );
              },
            ),
          ),
          _ChatInputBar(
            controller: _controller,
            hasText: _draft.trim().isNotEmpty,
            onChanged: (value) => setState(() => _draft = value),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case ChatMessageType.text:
        return Text(
          message.text ?? '',
          style: const TextStyle(color: Color(0xFF4A3A53), fontSize: 15),
        );
      case ChatMessageType.image:
        return Container(
          width: 190,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFB6DE)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_rounded, color: Color(0xFFF05CA8), size: 34),
              SizedBox(height: 6),
              Text('Cute anime image'),
            ],
          ),
        );
      case ChatMessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFF05CA8)),
            const SizedBox(width: 8),
            Text('▁▂▃▅▇  ${message.duration ?? ''}'),
          ],
        );
    }
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.hasText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      color: const Color(0xFFFFEAF6),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.photo_camera_rounded),
              color: const Color(0xFFF05CA8),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Type a kawaii message...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {},
              icon: Icon(
                hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: const Color(0xFFF05CA8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
