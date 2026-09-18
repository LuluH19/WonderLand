import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/country.dart';

/// Appels HTTP vers REST Countries v5.
///
/// L'API demande une clé (plan gratuit sur https://restcountries.com/sign-up)
/// envoyée en `Authorization: Bearer`. La clé est lue à la compilation depuis
/// `REST_COUNTRIES_API_KEY` : lancer l'app avec
/// `flutter run --dart-define-from-file=.env`.
///
/// Le plan gratuit limite chaque page à 100 pays, donc on enchaîne les pages
/// (`offset`) jusqu'à ce que `meta.more` soit `false` pour avoir les ~250 pays.
class CountriesService {
  CountriesService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey =
          apiKey ?? const String.fromEnvironment('REST_COUNTRIES_API_KEY');

  final http.Client _client;
  final String _apiKey;

  static const _baseUrl = 'https://api.restcountries.com/countries/v5';

  /// Seuls les champs utilisés par [Country] : la réponse est bien plus légère.
  static const _fields =
      'names.common,codes.alpha_2,capitals.name,region,subregion,population,'
      'languages.name,currencies,calling_codes,flag.url_png';

  /// Taille de page maximale du plan gratuit.
  static const _pageSize = 100;

  /// Tous les pays, triés par nom. Lève une [CountriesException] lisible en
  /// cas de clé manquante, de refus de l'API ou de réponse inattendue.
  Future<List<Country>> fetchAll() async {
    if (_apiKey.isEmpty) {
      throw const CountriesException(
        'Clé REST_COUNTRIES_API_KEY manquante : renseigne .env et lance '
        'flutter run --dart-define-from-file=.env',
      );
    }

    final countries = <Country>[];
    var offset = 0;
    var more = true;
    while (more) {
      final page = await _fetchPage(offset);
      countries.addAll(page.countries);
      more = page.more;
      offset += _pageSize;
    }

    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }

  Future<_Page> _fetchPage(int offset) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'limit': '$_pageSize',
        'offset': '$offset',
        'response_fields': _fields,
      },
    );
    final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $_apiKey'},
      );
    } on http.ClientException catch (e) {
      // DNS ou connexion impossible : l'appareil n'a pas d'accès Internet.
      throw CountriesException('Pas de connexion réseau (${e.message}).');
    }
    if (response.statusCode != 200) {
      throw CountriesException(
        'REST Countries a répondu ${response.statusCode} : ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final objects = data['objects'] as List<dynamic>? ?? const [];
    final meta = data['meta'] as Map<String, dynamic>? ?? const {};

    return _Page(
      countries: objects
          .map((o) => Country.fromJson(o as Map<String, dynamic>))
          .toList(),
      more: meta['more'] as bool? ?? false,
    );
  }
}

class _Page {
  const _Page({required this.countries, required this.more});
  final List<Country> countries;
  final bool more;
}

/// Erreur métier affichée telle quelle à l'écran.
class CountriesException implements Exception {
  const CountriesException(this.message);
  final String message;

  @override
  String toString() => message;
}
