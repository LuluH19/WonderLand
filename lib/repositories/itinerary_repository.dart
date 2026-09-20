import '../models/itinerary.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';
import '../services/local_db_service.dart';

/// Orchestration des itinéraires : génération Gemini + double sauvegarde
/// (Isar en local, Firestore dans le cloud).
class ItineraryRepository {
  ItineraryRepository({
    required this.gemini,
    required this.localDb,
    required this.firestore,
  });

  final GeminiService gemini;
  final LocalDbService localDb;
  final FirestoreService firestore;

  Future<Itinerary> generate({
    required String countryName,
    required String capital,
    required String travelStyle,
  }) {
    return gemini.generateItinerary(
      countryName: countryName,
      capital: capital,
      travelStyle: travelStyle,
    );
  }

  /// Les favoris viennent toujours d'Isar : ça marche en mode avion.
  Stream<List<Itinerary>> watchSaved(String uid) => localDb.watchAll(uid);

  /// "SAVE TO FAVORITES".
  Future<void> save(Itinerary itinerary, String uid) async {
    itinerary.uid = uid;
    itinerary.cloudId = firestore.newId(uid);
    await localDb.save(itinerary);
    // Pas de `await` : hors-ligne, Firestore garde l'écriture en attente et
    // l'enverra tout seul au retour du réseau. L'écran n'attend pas.
    firestore.save(uid, itinerary);
  }

  /// "REMOVE".
  Future<void> delete(Itinerary itinerary) async {
    await localDb.delete(itinerary.id);
    firestore.delete(itinerary.uid, itinerary.cloudId); // pas de await non plus
  }

  /// Récupère dans Isar les favoris présents dans le cloud mais pas encore
  /// sur ce téléphone (nouvel appareil, réinstallation). Silencieux si
  /// hors-ligne : la liste locale suffit.
  Future<void> syncFromCloud(String uid) async {
    try {
      final cloud = await firestore.getAll(uid);
      final local = await localDb.getAll(uid);
      final knownIds = local.map((it) => it.cloudId).toSet();
      final missing = cloud
          .where((it) => !knownIds.contains(it.cloudId))
          .map((it) => it..uid = uid)
          .toList();
      if (missing.isNotEmpty) await localDb.saveAll(missing);
    } catch (_) {
      // Pas de réseau : on garde les données locales.
    }
  }
}
