import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../screens/login_page.dart';
import 'app_shell.dart';

/// Écoute `authStateProvider` : dès qu'un utilisateur se connecte (email ou
/// invité) on affiche l'app ; dès qu'il se déconnecte, on revient au login.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Firebase restaure la session précédente au démarrage : on attend
      // la première valeur avant de choisir un écran.
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Erreur : $error'))),
      data: (user) {
        if (user == null) {
          return LoginPage(authService: ref.watch(authServiceProvider));
        }
        return const AppShell();
      },
    );
  }
}
