import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.userId,
  });

  final String sender;
  final String text;
  final String userId;
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.messagesStream,
    this.onSendMessage,
    this.currentUserId,
  });

  final Stream<List<ChatMessage>>? messagesStream;
  final Future<void> Function(String text)? onSendMessage;
  final String? currentUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  Stream<List<ChatMessage>> _firestoreMessagesStream() {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final username = (data['username'] as String?)?.trim();
        final email = (data['email'] as String?)?.trim();
        final sender = (username?.isNotEmpty ?? false)
            ? username!
            : (email?.isNotEmpty ?? false)
                ? email!
                : 'Unknown';

        return ChatMessage(
          sender: sender,
          text: ((data['text'] as String?) ?? '').trim(),
          userId: (data['userId'] as String?) ?? '',
        );
      }).where((message) => message.text.isNotEmpty).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (widget.onSendMessage != null) {
      await widget.onSendMessage!(text);
      if (!mounted) {
        return;
      }
      setState(_controller.clear);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Please sign in to send messages')),
        );
      return;
    }

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'username': user.displayName ?? '',
      'email': user.email ?? '',
    });

    if (!mounted) {
      return;
    }
    setState(_controller.clear);
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    final messageStream = widget.messagesStream ?? _firestoreMessagesStream();
    final currentUserId = widget.currentUserId ?? FirebaseAuth.instance.currentUser?.uid;

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
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Row(
                children: [
                  _StyleAvatar(name: 'Marin Kitagawa', color: Color(0xFFFF8FD6)),
                  SizedBox(width: 10),
                  _StyleAvatar(name: 'Mai Sakurajima', color: Color(0xFFB589FF)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: messageStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load messages',
                        style: TextStyle(color: Color(0xFFFFC2E8)),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8FD6),
                      ),
                    );
                  }

                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Start the conversation ✨',
                        style: TextStyle(color: Color(0xFFC6B2DF)),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.userId == currentUserId;
                      return _MessageBubble(
                        sender: message.sender,
                        text: message.text,
                        isMe: isMe,
                      );
                    },
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
                        onSubmitted: (_) => _sendMessage(),
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

class _StyleAvatar extends StatelessWidget {
  const _StyleAvatar({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x44120A20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: color.withOpacity(0.25),
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? const Color(0xFFD2A4FF) : const Color(0xFFFFB8E6);
    final titleColor = isMe ? const Color(0xFF4D1F6F) : const Color(0xFF5A1F4D);
    final textColor = isMe ? const Color(0xFF331147) : const Color(0xFF3A1333);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
