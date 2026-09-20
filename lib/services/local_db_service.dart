import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/itinerary.dart';

/// Base de données locale Isar : les favoris restent lisibles sans réseau.
class LocalDbService {
  LocalDbService(this._isar);

  final Isar _isar;

  /// À appeler une seule fois au démarrage (dans `main`).
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open([ItinerarySchema], directory: dir.path);
  }

  /// Flux des favoris d'un utilisateur, du plus récent au plus ancien.
  /// `fireImmediately` : on reçoit la liste tout de suite, puis à chaque
  /// modification.
  Stream<List<Itinerary>> watchAll(String uid) {
    return _isar.itinerarys
        .filter()
        .uidEqualTo(uid)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<List<Itinerary>> getAll(String uid) {
    return _isar.itinerarys.filter().uidEqualTo(uid).findAll();
  }

  /// Toute écriture Isar se fait dans une transaction (`writeTxn`).
  Future<void> save(Itinerary itinerary) {
    return _isar.writeTxn(() => _isar.itinerarys.put(itinerary));
  }

  Future<void> saveAll(List<Itinerary> itineraries) {
    return _isar.writeTxn(() => _isar.itinerarys.putAll(itineraries));
  }

  Future<void> delete(int id) {
    return _isar.writeTxn(() => _isar.itinerarys.delete(id));
  }
}
