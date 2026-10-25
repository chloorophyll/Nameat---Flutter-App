import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Shows the login screen or the app, depending on whether someone is signed in.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const Scaffold(body: Center(child: AppLogo(size: 88)));
    }
    return auth.isLoggedIn ? const HomeShell() : const LoginScreen();
  }
}
