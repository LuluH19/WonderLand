/// Ce que Gemini Vision a reconnu sur une photo.
class PhotoAnalysis {
  const PhotoAnalysis({
    required this.placeName,
    required this.countryName,
    required this.description,
  });

  /// Lieu ou monument reconnu ("Tour Eiffel"), vide si inconnu.
  final String placeName;

  /// Pays deviné ("France"), vide si Gemini n'est pas sûr.
  final String countryName;

  /// Deux ou trois phrases d'explication.
  final String description;

  /// Lecture de la réponse JSON de Gemini.
  factory PhotoAnalysis.fromMap(Map<String, dynamic> map) => PhotoAnalysis(
    placeName: map['placeName'] as String? ?? '',
    countryName: map['countryName'] as String? ?? '',
    description: map['description'] as String? ?? '',
  );
}
