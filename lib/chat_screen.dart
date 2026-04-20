import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/chat_utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
  });

  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>> _messagesCollection(String chatId) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages');

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    final user = _currentUser;
    if (text.isEmpty || user == null) {
      return;
    }
    final chatId = buildPrivateChatId(user.uid, widget.peerId);

    await _messagesCollection(chatId).add({
      'text': text,
      'senderId': user.uid,
      'receiverId': widget.peerId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final hasText = _controller.text.trim().isNotEmpty;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in first'),
        ),
      );
    }
    final chatId = buildPrivateChatId(user.uid, widget.peerId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFF8FD6),
              backgroundImage:
                  widget.peerAvatarUrl != null && widget.peerAvatarUrl!.isNotEmpty
                      ? NetworkImage(widget.peerAvatarUrl!)
                      : null,
              child:
                  widget.peerAvatarUrl == null || widget.peerAvatarUrl!.isEmpty
                      ? Text(
                        buildAvatarInitial(widget.peerName),
                        style: const TextStyle(color: Color(0xFF2D163F)),
                      )
                      : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.peerName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    _messagesCollection(chatId)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Say hi! 💫',
                        style: TextStyle(color: Color(0xFFBFA9D9), fontSize: 16),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data();
                      final messageText = (data['text'] as String?)?.trim();
                      final isMe = data['senderId'] == user.uid;
                      final bubbleColor =
                          isMe
                              ? const Color(0xFFD2A4FF)
                              : const Color(0xFFFFB8E6);

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                isMe ? 'You' : widget.peerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3B2353),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                messageText != null && messageText.isNotEmpty
                                    ? messageText
                                    : '[Message unavailable]',
                                style: const TextStyle(
                                  color: Color(0xFF2D163F),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        onSubmitted: (_) => _sendMessage(),
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
