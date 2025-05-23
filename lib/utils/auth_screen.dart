import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:line_skip/screens/auth/login_screen.dart';
import 'package:line_skip/screens/home/home_screen.dart';
import 'package:line_skip/screens/profile/edit_profile_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

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

        if (snapshot.hasData) {
          final User? user = snapshot.data;

          if (user!.displayName == null || user.displayName!.isEmpty) {
            return EditProfileScreen();
          } else {
            return const HomeScreen();
          }
        }

        return LoginScreen();
      },
    );
  }
}
