import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'widgets/auth_gate.dart';

Future<void> main() async {
  // Nécessaire pour Firebase Auth / Firestore : à garder.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WonderLand',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      // L'AuthGate choisit LoginPage ou l'app selon la session Firebase.
      home: AuthGate(authService: AuthService()),
    );
  }
}
