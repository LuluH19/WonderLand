import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// on donne ce jeton à Firebase via
/// `signInWithCredential`, qui crée ou retrouve l'utilisateur Firebase.
class AuthService {
  /// [auth] est injectable pour les tests ; par défaut on prend l'instance
  /// globale, résolue paresseusement pour ne pas exiger Firebase.initializeApp
  /// au simple `new AuthService()`.
  AuthService({FirebaseAuth? auth})
    : _auth = auth; // ignore: prefer_initializing_formals

  FirebaseAuth? _auth;
  FirebaseAuth get _instance => _auth ??= FirebaseAuth.instance;

  /// Utilisateur courant, `null` si personne n'est connecté.
  User? get currentUser => _instance.currentUser;

  /// Identifiant de l'utilisateur courant (utilisé comme clé Firestore).
  String? get uid => currentUser?.uid;

  /// `true` si l'utilisateur est un invité (connexion anonyme).
  bool get isGuest => currentUser?.isAnonymous ?? false;

  /// Flux émis à chaque connexion / déconnexion. C'est ce que l'AuthGate
  /// écoute pour choisir entre LoginPage et l'application.
  Stream<User?> get authStateChanges => _instance.authStateChanges();

  /// "SKIP - CONTINUE AS GUEST" : compte anonyme, sans saisie.
  Future<User?> signInAsGuest() async {
    final credential = await _instance.signInAnonymously();
    return credential.user;
  }

  /// "CONTINUE WITH EMAIL" : connexion avec un compte existant.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// "Don't have an account? Sign Up" : création de compte.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Transforme un compte invité en compte email sans perdre ses favoris :
  /// l'uid reste le même, donc les documents Firestore restent rattachés.
  Future<User?> linkGuestToEmail({
    required String email,
    required String password,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Aucun utilisateur connecté à rattacher.');
    }
    final credential = await user.linkWithCredential(
      EmailAuthProvider.credential(email: email.trim(), password: password),
    );
    return credential.user;
  }

  /// "CONTINUE WITH GOOGLE".
  ///
  /// Renvoie `null` si l'utilisateur ferme la fenêtre sans choisir de compte
  /// (ce n'est pas une erreur, on ne montre rien).
  Future<User?> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    // initialize() lit google-services.json (Android) et Info.plist (iOS).
    // On ne l'appelle qu'une fois par lancement de l'app.
    if (!_googleInitialized) {
      await google.initialize();
      _googleInitialized = true;
    }

    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await _instance.signInWithCredential(credential);
    return result.user;
  }

  bool _googleInitialized = false;

  /// "CONTINUE WITH APPLE" (iOS / macOS uniquement).
  ///
  /// Apple exige un "nonce" : une chaîne aléatoire qu'on envoie hachée à Apple
  /// et en clair à Firebase, pour prouver que le jeton reçu est bien le nôtre.
  /// Renvoie `null` si l'utilisateur annule.
  Future<User?> signInWithApple() async {
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final AuthorizationCredentialAppleID apple;
    try {
      apple = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }

    final credential = OAuthProvider('apple.com')
        .credential(idToken: apple.identityToken, rawNonce: rawNonce);
    final result = await _instance.signInWithCredential(credential);
    return result.user;
  }

  /// Chaîne aléatoire de 32 caractères pour le nonce Apple.
  static String _randomNonce() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// "Forgot Password?" : Firebase envoie l'email de réinitialisation.
  Future<void> sendPasswordReset(String email) {
    return _instance.sendPasswordResetEmail(email: email.trim());
  }

  /// "SIGN OUT" depuis l'écran Saved.
  ///
  /// On déconnecte aussi Google, sinon au prochain "CONTINUE WITH GOOGLE" le
  /// même compte serait repris sans afficher le choix des comptes.
  Future<void> signOut() async {
    if (_googleInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await _instance.signOut();
  }

  /// Traduit les codes d'erreur Firebase en message lisible pour l'UI.
  static String describeError(Object error) {
    if (error is GoogleSignInException) {
      return error.code == GoogleSignInExceptionCode.clientConfigurationError
          ? 'Google Sign-In mal configuré (SHA-1 ou google-services.json).'
          : 'Connexion Google impossible (${error.code.name}).';
    }
    if (error is SignInWithAppleAuthorizationException) {
      return 'Connexion Apple impossible (${error.code.name}).';
    }
    if (error is! FirebaseAuthException) {
      return 'Une erreur est survenue. Réessaie.';
    }
    switch (error.code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Mot de passe trop court (6 caractères minimum).';
      case 'network-request-failed':
        return 'Pas de connexion réseau.';
      case 'too-many-requests':
        return 'Trop de tentatives, réessaie plus tard.';
      case 'operation-not-allowed':
        return 'Ce mode de connexion n\'est pas activé dans la console Firebase.';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cet email via un autre fournisseur.';
      default:
        return error.message ?? 'Erreur d\'authentification (${error.code}).';
    }
  }
}
