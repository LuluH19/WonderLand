import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';

/// Écran "Sign in" de la maquette (docs/Image-Design/signin.png).

/// Trois chemins : email + mot de passe, invité, et Google / Apple.
/// Le [AuthService] est injecté pour pouvoir tester l'écran sans Firebase.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authService});

  final AuthService? authService;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthService _auth = widget.authService ?? AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// `false` : connexion ; `true` : création de compte.
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Exécute une action Firebase en gérant le spinner et le message d'erreur.
  /// Pas de navigation ici : le routeur réagit à authStateChanges (redirect).
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = AuthService.describeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueWithEmail() {
    final email = _emailController.text;
    final password = _passwordController.text;
    if (email.trim().isEmpty || password.isEmpty) {
      setState(() => _error = 'Email et mot de passe requis.');
      return;
    }
    _run(
      () => _isSignUp
          ? _auth.signUpWithEmail(email: email, password: password)
          : _auth.signInWithEmail(email: email, password: password),
    );
  }

  void _forgotPassword() {
    final email = _emailController.text;
    if (email.trim().isEmpty) {
      setState(() => _error = 'Saisis ton email pour réinitialiser.');
      return;
    }
    _run(() async {
      await _auth.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé.')),
        );
      }
    });
  }

  /// Apple n'est disponible que sur iPhone / iPad / Mac
  bool get _appleAvailable =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'WONDERLAND',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              Text(
                _isSignUp ? 'Sign up.' : 'Sign in.',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your itineraries are bookmarked to your account and stay '
                'readable offline.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),
              _field(
                _emailController,
                'Email',
                'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _field(
                _passwordController,
                'Password',
                '6 caractères minimum',
                obscure: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.primary)),
              ],
              const SizedBox(height: 16),
              _primaryButton(
                _isSignUp ? 'CREATE ACCOUNT  →' : 'CONTINUE WITH EMAIL  →',
                onPressed: _loading ? null : _continueWithEmail,
              ),
              const SizedBox(height: 8),
              // Deux liens l'un sous l'autre : côte à côte ils débordaient
              // sur les petits écrans.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                            _isSignUp = !_isSignUp;
                            _error = null;
                          }),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Sign Up",
                    ),
                  ),
                  if (!_isSignUp)
                    TextButton(
                      onPressed: _loading ? null : _forgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 16),
              _outlinedButton(
                'CONTINUE WITH GOOGLE',
                onPressed: _loading ? null : () => _run(_auth.signInWithGoogle),
              ),
              if (_appleAvailable) ...[
                const SizedBox(height: 8),
                _outlinedButton(
                  'CONTINUE WITH APPLE',
                  onPressed: _loading
                      ? null
                      : () => _run(_auth.signInWithApple),
                ),
              ],
              const SizedBox(height: 48),
              TextButton(
                onPressed: _loading ? null : () => _run(_auth.signInAsGuest),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'SKIP - CONTINUE AS GUEST  →',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'Guest mode signs you in anonymously; you can attach an email '
                'later from Saved.',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              if (_loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: !_loading,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.fieldFill,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _primaryButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _outlinedButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(),
          alignment: Alignment.centerLeft,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
