import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/itinerary.dart';

/// Lecture / écriture Cloud Firestore.
///
/// Structure : `users/{uid}/itineraries/{itineraryId}`.
/// Chaque utilisateur (email ou invité) ne voit que sa sous-collection, ce que
/// les règles de sécurité (`firestore.rules`) imposent aussi côté serveur.
///
/// Le cache hors-ligne est activé par défaut sur Android / iOS : les favoris
/// restent lisibles sans réseau et les écritures sont rejouées à la reconnexion,
/// ce qui correspond au "AVAILABLE OFFLINE" de la maquette.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore; // ignore: prefer_initializing_formals

  FirebaseFirestore? _firestore;
  FirebaseFirestore get _db => _firestore ??= FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itineraries(String uid) =>
      _db.collection('users').doc(uid).collection('itineraries');

  /// Flux des favoris d'un utilisateur, du plus récent au plus ancien.
  /// Se met à jour tout seul à chaque ajout / suppression.
  Stream<List<Itinerary>> watchItineraries(String uid) {
    return _itineraries(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Itinerary.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Lecture unique (utile pour les tests ou un rafraîchissement manuel).
  Future<List<Itinerary>> getItineraries(String uid) async {
    final snapshot = await _itineraries(uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Itinerary.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// "SAVE TO FAVORITES" : crée le document et renvoie l'itinéraire avec
  /// l'id attribué par Firestore.
  Future<Itinerary> saveItinerary(String uid, Itinerary itinerary) async {
    final doc = _itineraries(uid).doc();
    await doc.set(itinerary.toMap());
    return Itinerary.fromMap(doc.id, itinerary.toMap());
  }

  /// "REMOVE" depuis l'écran Saved.
  Future<void> deleteItinerary(String uid, String itineraryId) {
    return _itineraries(uid).doc(itineraryId).delete();
  }
}
