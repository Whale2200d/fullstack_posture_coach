import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key, AuthService? authService}) : _authService = authService;

  final AuthService? _authService;
  final ProfileService _profileService = ProfileService.inMemory();

  @override
  Widget build(BuildContext context) {
    // Firebase 설정이 없는 플랫폼(예: web/macos)에서도 앱이 깨지지 않도록 폴백.
    if (Firebase.apps.isEmpty) {
      return HomeScreen(profileService: _profileService);
    }

    final authService = _authService ?? AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authService: authService);
        }

        return HomeScreen(authService: authService, profileService: _profileService);
      },
    );
  }
}

