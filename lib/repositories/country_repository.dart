import '../models/country.dart';
import '../services/countries_service.dart';

/// Source de vérité pour les pays : va chercher la liste via l'API et
/// contient la logique de recherche (les widgets n'ont rien à calculer).
class CountryRepository {
  CountryRepository(this._service);

  final CountriesService _service;

  /// Tous les pays, triés par nom (appel réseau).
  Future<List<Country>> getAll() => _service.fetchAll();

  /// Filtre en mémoire sur le nom ou la capitale ("por" -> Portugal).
  List<Country> filter(List<Country> all, String query) {
    return all.where((country) => country.matches(query)).toList();
  }

  /// Retrouve le pays deviné par Gemini Vision, `null` si aucun ne correspond.
  Country? findByName(List<Country> all, String name) {
    final wanted = name.trim().toLowerCase();
    if (wanted.isEmpty) return null;
    for (final country in all) {
      if (country.name.toLowerCase() == wanted) return country;
    }
    return null;
  }
}
