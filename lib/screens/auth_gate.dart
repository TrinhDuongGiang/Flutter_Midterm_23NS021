
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Wait for Firebase to restore the authentication state.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F8FF),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7977E8),
              ),
            ),
          );
        }

        // Handle unexpected authentication stream errors.
        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final user = snapshot.data;

        // Only the configured admin can access the dashboard.
        if (user != null && user.uid == AuthService.adminUid) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
