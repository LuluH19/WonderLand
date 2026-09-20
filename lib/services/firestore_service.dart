import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/itinerary.dart';

/// Lecture / écriture Cloud Firestore.
///
/// Structure : `users/{uid}/itineraries/{cloudId}`.
/// Chaque utilisateur (email ou invité) ne voit que sa sous-collection, ce que
/// les règles de sécurité (`firestore.rules`) imposent aussi côté serveur.
class FirestoreService {
  CollectionReference<Map<String, dynamic>> _itineraries(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('itineraries');

  /// Génère un identifiant de document (fonctionne même hors-ligne).
  String newId(String uid) => _itineraries(uid).doc().id;

  /// Tous les favoris du cloud, du plus récent au plus ancien.
  Future<List<Itinerary>> getAll(String uid) async {
    final snapshot = await _itineraries(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Itinerary.fromMap(doc.data())..cloudId = doc.id)
        .toList();
  }

  /// Écrit (ou remplace) le document `cloudId`.
  ///
  /// Une erreur (règles de sécurité, compte supprimé...) est avalée : le favori
  /// est déjà dans Isar, l'app ne doit pas planter pour le cloud.
  Future<void> save(String uid, Itinerary itinerary) async {
    try {
      await _itineraries(uid).doc(itinerary.cloudId).set(itinerary.toMap());
    } catch (_) {
      // Ignoré volontairement.
    }
  }

  Future<void> delete(String uid, String cloudId) async {
    try {
      await _itineraries(uid).doc(cloudId).delete();
    } catch (_) {
      // Ignoré volontairement.
    }
  }
}
