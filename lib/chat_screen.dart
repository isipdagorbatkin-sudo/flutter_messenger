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
      return const Scaffold(body: Center(child: Text('Please sign in first')));
    }
    final chatId = buildPrivateChatId(user.uid, widget.peerId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Hero(
              tag: 'avatar-${widget.peerId}',
              child: _ChatAvatar(
                peerAvatarUrl: widget.peerAvatarUrl,
                peerName: widget.peerName,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.peerName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF120923), Color(0xFF241638), Color(0xFF140D24)],
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
                    return const _ChatEmptyState();
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data();
                      final messageText = (data['text'] as String?)?.trim();
                      final isMe = data['senderId'] == user.uid;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isMe
                                  ? const [Color(0xFF8D6BFF), Color(0xFFFF79C9)]
                                  : const [Color(0xFF2F1E46), Color(0xFF3B2559)],
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 5),
                              bottomRight: Radius.circular(isMe ? 5 : 18),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe ? 'You' : widget.peerName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isMe
                                      ? const Color(0xFF321A42)
                                      : const Color(0xFF8EEFFF),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                messageText != null && messageText.isNotEmpty
                                    ? messageText
                                    : '[Message unavailable]',
                                style: TextStyle(
                                  color: isMe
                                      ? const Color(0xFF210C31)
                                      : const Color(0xFFEFDFFF),
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
              decoration: const BoxDecoration(
                color: Color(0xCC150D25),
                border: Border(top: BorderSide(color: Color(0x552D1E43))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          fillColor: const Color(0xFF2A1940),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF8FD6),
                              width: 1.3,
                            ),
                          ),
                        ),
                        style: const TextStyle(color: Color(0xFFFFE8FA)),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF71C6), Color(0xFF7D6CFF)],
                        ),
                      ),
                      child: IconButton(
                        onPressed: hasText ? _sendMessage : null,
                        icon: const Icon(Icons.send_rounded),
                        color: Colors.white,
                        disabledColor: const Color(0xFF9185A2),
                      ),
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

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.peerAvatarUrl, required this.peerName});

  final String? peerAvatarUrl;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    if (peerAvatarUrl != null && peerAvatarUrl!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(peerAvatarUrl!));
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF7BCB), Color(0xFF6EE5FF)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        buildAvatarInitial(peerName),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.forum_rounded, color: Color(0xFF7AE8FF), size: 52),
            const SizedBox(height: 10),
            const Text(
              'No messages yet',
              style: TextStyle(
                color: Color(0xFFFFE8FA),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Say hi and start your conversation 💫',
              style: TextStyle(color: Color(0xFFBFA9D9)),
            ),
          ],
        ),
      ),
    );
  }
}
