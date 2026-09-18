import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../services/auth_service.dart';

/// Écoute `authStateChanges` : dès qu'un utilisateur se connecte (email ou
/// invité) on affiche l'app ; dès qu'il se déconnecte, on revient au login
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Firebase restaure la session précédente au démarrage : on attend
        // la première valeur avant de choisir un écran.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == null) {
          return LoginPage(authService: authService);
        }
        return HomePage(authService: authService);
      },
    );
  }
}
