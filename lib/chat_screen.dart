import 'package:flutter/material.dart';

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.avatarUrl,
    required this.isMe,
  });

  final String sender;
  final String text;
  final String avatarUrl;
  final bool isMe;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _maiAvatar =
      'https://upload.wikimedia.org/wikipedia/en/thumb/5/5a/Mai_Sakurajima.jpg/320px-Mai_Sakurajima.jpg';
  static const _marinAvatar =
      'https://upload.wikimedia.org/wikipedia/en/thumb/a/a0/Marin_Kitagawa.png/320px-Marin_Kitagawa.png';

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      sender: 'Marin Kitagawa',
      text: 'I found the cutest cosplay idea for us ✨',
      avatarUrl: _marinAvatar,
      isMe: false,
    ),
    const ChatMessage(
      sender: 'Mai Sakurajima',
      text: 'Send me the details. I\'m curious 🌙',
      avatarUrl: _maiAvatar,
      isMe: true,
    ),
    const ChatMessage(
      sender: 'Marin Kitagawa',
      text: 'Meet me after school and I will show everything 💖',
      avatarUrl: _marinAvatar,
      isMe: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        sender: 'Mai Sakurajima',
        text: text,
        avatarUrl: _maiAvatar,
        isMe: true,
      ));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Messenger'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A102B), Color(0xFF2A1A45), Color(0xFF3A2056)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final bubbleColor =
                      message.isMe
                          ? const Color(0xFFD2A4FF)
                          : const Color(0xFFFFB8E6);
                  return Align(
                    alignment:
                        message.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!message.isMe)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(message.avatarUrl),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.sender,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3B2353),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  message.text,
                                  style: const TextStyle(
                                    color: Color(0xFF2D163F),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (message.isMe)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(message.avatarUrl),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              color: const Color(0xFF120A20),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(color: Color(0xFFBFA9D9)),
                          filled: true,
                          fillColor: const Color(0xFF2B1A45),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFFFFE8FA)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: hasText ? _sendMessage : null,
                      icon: const Icon(Icons.send_rounded),
                      color: const Color(0xFFFF8FD6),
                      disabledColor: const Color(0xFF67557F),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
