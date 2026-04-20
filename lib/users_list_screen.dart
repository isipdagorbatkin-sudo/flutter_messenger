import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/chat_screen.dart';
import 'package:flutter_messenger/chat_utils.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key, required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Friends ✨'),
        actions: [
          IconButton(
            onPressed: FirebaseAuth.instance.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF120923), Color(0xFF27163B), Color(0xFF140D24)],
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
              return const Center(child: _UsersEmptyState());
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final userData = users[index].data();
                final avatarUrl = userData['imageUrl'] as String?;
                final displayName = buildDisplayName(userData);
                final userId = users[index].id;

                return Material(
                  color: const Color(0x7A2D1A44),
                  elevation: 3,
                  shadowColor: const Color(0x4014D6E9),
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (_, __, ___) => ChatScreen(
                                peerId: userId,
                                peerName: displayName,
                                peerAvatarUrl: avatarUrl,
                              ),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Hero(
                        tag: 'avatar-$userId',
                        child: _ProfileAvatar(
                          imageUrl: avatarUrl,
                          displayName: displayName,
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          color: Color(0xFFFFE8FA),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text(
                        'Tap to open private chat',
                        style: TextStyle(color: Color(0xFFBCA3D6)),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF73ECFF),
                        size: 16,
                      ),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.displayName});

  final String? imageUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(backgroundImage: NetworkImage(imageUrl!), radius: 24);
    }

    return Container(
      width: 48,
      height: 48,
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
        buildAvatarInitial(displayName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _UsersEmptyState extends StatelessWidget {
  const _UsersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.people_alt_outlined, color: Color(0xFF7AE8FF), size: 52),
          SizedBox(height: 12),
          Text(
            'No friends found yet',
            style: TextStyle(
              color: Color(0xFFFFE8FA),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Invite someone to register and start chatting 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFBFA9D9)),
          ),
        ],
      ),
    );
  }
}
