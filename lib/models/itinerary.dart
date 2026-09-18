/// Une journée d'un itinéraire généré par Gemini ("DAY 1 - Alfama & the river").
class ItineraryDay {
  const ItineraryDay({required this.title, required this.description});

  final String title;
  final String description;

  Map<String, dynamic> toMap() => {'title': title, 'description': description};

  factory ItineraryDay.fromMap(Map<String, dynamic> map) => ItineraryDay(
    title: map['title'] as String? ?? '',
    description: map['description'] as String? ?? '',
  );
}

/// Itinéraire sauvegardé dans les favoris ("Lisbon · 3 days · Portugal · Food").
/// Stocké dans Firestore sous `users/{uid}/itineraries/{id}`.
class Itinerary {
  const Itinerary({
    required this.id,
    required this.countryName,
    required this.city,
    required this.travelStyle,
    required this.summary,
    required this.days,
    required this.createdAt,
  });

  /// Identifiant du document Firestore.
  final String id;

  /// Pays choisi sur l'écran de recherche ("Portugal").
  final String countryName;

  /// Capitale / ville de l'itinéraire ("Lisbon").
  final String city;

  /// Style de voyage sélectionné ("Food", "History", "Nature", "Nightlife").
  final String travelStyle;

  /// Phrase d'introduction renvoyée par Gemini.
  final String summary;

  /// Les journées, dans l'ordre.
  final List<ItineraryDay> days;

  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'countryName': countryName,
    'city': city,
    'travelStyle': travelStyle,
    'summary': summary,
    'days': days.map((d) => d.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Itinerary.fromMap(String id, Map<String, dynamic> map) => Itinerary(
    id: id,
    countryName: map['countryName'] as String? ?? '',
    city: map['city'] as String? ?? '',
    travelStyle: map['travelStyle'] as String? ?? '',
    summary: map['summary'] as String? ?? '',
    days: (map['days'] as List<dynamic>? ?? const [])
        .map((d) => ItineraryDay.fromMap(Map<String, dynamic>.from(d as Map)))
        .toList(),
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
