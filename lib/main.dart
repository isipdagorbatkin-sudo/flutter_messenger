import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_messenger/users_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A102B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF120A20),
          foregroundColor: Color(0xFFFFB8E6),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8FD6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Please sign in to open your chats 💖',
                style: TextStyle(color: Color(0xFFFFB8E6)),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return UsersListScreen(currentUserId: user.uid);
      },
    );
  }
}
