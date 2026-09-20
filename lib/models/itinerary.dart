import 'package:isar_community/isar.dart';

// Ce fichier est généré par `dart run build_runner build` (voir README).
part 'itinerary.g.dart';

/// Une journée d'un itinéraire ("DAY 1 - Alfama & the river").
///
/// `@embedded` : Isar range cet objet à l'intérieur de [Itinerary],
/// il n'a pas de table à lui.
@embedded
class ItineraryDay {
  String title = '';
  String description = '';

  Map<String, dynamic> toMap() => {'title': title, 'description': description};

  static ItineraryDay fromMap(Map<String, dynamic> map) {
    return ItineraryDay()
      ..title = map['title'] as String? ?? ''
      ..description = map['description'] as String? ?? '';
  }
}

/// Itinéraire généré par Gemini puis sauvegardé.
///
/// Sauvegardé deux fois : en local avec Isar (lisible hors-ligne) et dans
/// Firestore sous `users/{uid}/itineraries/{cloudId}`.
@collection
class Itinerary {
  /// Identifiant local Isar (attribué automatiquement).
  Id id = Isar.autoIncrement;

  /// Identifiant du document Firestore, pour pouvoir le supprimer aussi.
  String cloudId = '';

  /// Utilisateur propriétaire (uid Firebase).
  String uid = '';

  /// Pays choisi sur l'écran de recherche ("Portugal").
  String countryName = '';

  /// Capitale / ville de l'itinéraire ("Lisbon").
  String city = '';

  /// Style de voyage sélectionné ("FOOD", "HISTORY", ...).
  String travelStyle = '';

  /// Phrase d'introduction renvoyée par Gemini.
  String summary = '';

  /// Les journées, dans l'ordre.
  List<ItineraryDay> days = [];

  DateTime createdAt = DateTime.now();

  /// Format envoyé à Firestore.
  Map<String, dynamic> toMap() => {
    'countryName': countryName,
    'city': city,
    'travelStyle': travelStyle,
    'summary': summary,
    'days': days.map((d) => d.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Lecture d'un document Firestore (ou de la réponse JSON de Gemini).
  static Itinerary fromMap(Map<String, dynamic> map) {
    final rawDays = map['days'] as List<dynamic>? ?? const [];
    return Itinerary()
      ..countryName = map['countryName'] as String? ?? ''
      ..city = map['city'] as String? ?? ''
      ..travelStyle = map['travelStyle'] as String? ?? ''
      ..summary = map['summary'] as String? ?? ''
      ..days = rawDays
          .map((d) => ItineraryDay.fromMap(Map<String, dynamic>.from(d as Map)))
          .toList()
      ..createdAt =
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now();
  }
}
