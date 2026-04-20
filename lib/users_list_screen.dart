import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/chat_screen.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key, required this.currentUserId});

  final String currentUserId;

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '?';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Friends ✨'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A102B), Color(0xFF2A1A45), Color(0xFF3A2056)],
          ),
        ),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('username')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'Cannot load users now.',
                  style: TextStyle(color: Color(0xFFBFA9D9)),
                ),
              );
            }

            final users =
                snapshot.data!.docs
                    .where((doc) => doc.id != currentUserId)
                    .toList(growable: false);

            if (users.isEmpty) {
              return const Center(
                child: Text(
                  'No friends found yet 🌸',
                  style: TextStyle(color: Color(0xFFBFA9D9), fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final userData = users[index].data();
                final name = (userData['username'] as String?)?.trim();
                final avatarUrl = userData['imageUrl'] as String?;
                final displayName =
                    (name == null || name.isEmpty)
                        ? (userData['email'] as String? ?? 'Unknown user')
                        : name;

                return Card(
                  color: const Color(0xFF2B1A45),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                peerId: users[index].id,
                                peerName: displayName,
                                peerAvatarUrl: avatarUrl,
                              ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF8FD6),
                      backgroundImage:
                          avatarUrl != null && avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                      child:
                          avatarUrl == null || avatarUrl.isEmpty
                              ? Text(
                                _initial(displayName),
                                style: const TextStyle(color: Color(0xFF2D163F)),
                              )
                              : null,
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(color: Color(0xFFFFE8FA)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
