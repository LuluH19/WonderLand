import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../models/itinerary.dart';
import '../repositories/itinerary_repository.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';
import '../services/local_db_service.dart';
import 'auth_providers.dart';

/// L'instance Isar est ouverte dans `main` avant `runApp`, puis fournie ici
/// avec `isarProvider.overrideWithValue(isar)`.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider doit être surchargé dans main.dart');
});

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final itineraryRepositoryProvider = Provider<ItineraryRepository>((ref) {
  return ItineraryRepository(
    gemini: ref.watch(geminiServiceProvider),
    localDb: LocalDbService(ref.watch(isarProvider)),
    firestore: FirestoreService(),
  );
});

/// Paramètres d'une génération. Un "record" Dart : deux requêtes avec les
/// mêmes valeurs sont égales, donc Riverpod réutilise le même résultat.
typedef ItineraryRequest = ({
  String countryName,
  String capital,
  String travelStyle,
});

/// Génération Gemini. `.family` : un résultat par requête.
/// `.autoDispose` : oublié quand on quitte l'écran (nouvelle génération
/// la prochaine fois).
final itineraryProvider = FutureProvider.autoDispose
    .family<Itinerary, ItineraryRequest>((ref, request) {
      return ref
          .watch(itineraryRepositoryProvider)
          .generate(
            countryName: request.countryName,
            capital: request.capital,
            travelStyle: request.travelStyle,
          );
    });

/// Favoris de l'utilisateur connecté, lus dans Isar (donc hors-ligne aussi).
/// Au passage on rapatrie ceux du cloud qui manqueraient en local.
final savedItinerariesProvider = StreamProvider<List<Itinerary>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  final repository = ref.watch(itineraryRepositoryProvider);
  repository.syncFromCloud(uid);
  return repository.watchSaved(uid);
});
