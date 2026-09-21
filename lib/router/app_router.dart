import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/country.dart';
import '../providers/auth_providers.dart';
import '../providers/ui_providers.dart';
import '../screens/country_page.dart';
import '../screens/itinerary_page.dart';
import '../screens/login_page.dart';
import '../widgets/app_shell.dart';

/// Toutes les routes de l'app au même endroit (GoRouter).
///
/// Le provider observe `authStateProvider` : à chaque connexion ou
/// déconnexion, le routeur est reconstruit et `redirect` renvoie vers le bon
/// écran. Aucun `Navigator.push` dans les écrans : ils font
/// `context.push('/country', extra: country)`.
final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authStateProvider).value;

  final router = GoRouter(
    initialLocation: '/',
    // Garde d'authentification : sans utilisateur on ne voit que /login,
    // avec un utilisateur on ne revoit jamais /login.
    redirect: (context, state) {
      final loggedIn = user != null;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginPage(authService: ref.read(authServiceProvider)),
      ),
      GoRoute(path: '/', builder: (context, state) => const AppShell()),
      // Le pays est passé en `extra` : pas besoin de le recharger par son code.
      GoRoute(
        path: '/country',
        builder: (context, state) =>
            CountryPage(country: state.extra as Country),
      ),
      // Le style de voyage est un query parameter : /itinerary?style=FOOD
      GoRoute(
        path: '/itinerary',
        builder: (context, state) => ItineraryPage(
          country: state.extra as Country,
          travelStyle: state.uri.queryParameters['style'] ?? travelStyles.first,
        ),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
