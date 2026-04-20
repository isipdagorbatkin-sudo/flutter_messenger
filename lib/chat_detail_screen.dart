import 'package:flutter/material.dart';

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
  const ChatDetailScreen({
    super.key,
    required this.characterName,
    required this.avatarText,
  });

  final String characterName;
  final String avatarText;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const _imageUrl = 'https://placehold.co/320x200/png?text=Kawaii+Pic';
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
    ChatMessage(isMe: false, type: ChatMessageType.voice, duration: '0:18'),
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
                widget.avatarText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(widget.characterName, overflow: TextOverflow.ellipsis),
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
                      message.isMe ? Alignment.centerRight : Alignment.centerLeft,
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _imageUrl,
            width: 190,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  width: 190,
                  height: 120,
                  color: const Color(0xFFFFF5FB),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_rounded,
                    color: Color(0xFFF05CA8),
                    size: 34,
                  ),
                ),
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
