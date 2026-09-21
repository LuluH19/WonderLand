import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Une seule instance d'AuthService pour toute l'app.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Utilisateur connecté (ou `null`). Se met à jour à chaque connexion /
/// déconnexion : c'est ce que le routeur (redirect) écoute.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
