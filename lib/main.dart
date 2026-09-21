import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_colors.dart';
import 'firebase_options.dart';
import 'providers/auth_providers.dart';
import 'providers/itinerary_providers.dart';
import 'services/local_db_service.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase (Auth, Firestore, Gemini via Firebase AI Logic).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? const AppleDebugProvider()
        : const AppleDeviceCheckProvider(),
  );

  // 2. Base locale Isar (favoris hors-ligne).
  final isar = await LocalDbService.open();

  // 3. ProviderScope rend tous les providers Riverpod disponibles.
  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firebase restaure la session précédente au démarrage : on attend la
    // première valeur avant de brancher le routeur (sinon le login
    // apparaîtrait une fraction de seconde).
    if (ref.watch(authStateProvider).isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'WonderLand',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      // GoRouter choisit l'écran (login ou app) et gère les pages empilées.
      routerConfig: ref.watch(routerProvider),
    );
  }
}
