import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/country.dart';
import '../repositories/country_repository.dart';
import '../services/countries_service.dart';

final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  return CountryRepository(CountriesService());
});

/// Liste complète des pays, chargée une seule fois depuis REST Countries.
/// `FutureProvider` donne un `AsyncValue` : loading / data / error.
final countriesProvider = FutureProvider<List<Country>>((ref) {
  return ref.watch(countryRepositoryProvider).getAll();
});

/// Texte tapé dans la barre de recherche.
final searchQueryProvider = StateProvider<String>((ref) => '');
