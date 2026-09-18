class Country {
  const Country({
    required this.code,
    required this.name,
    required this.capital,
    required this.region,
    required this.subregion,
    required this.population,
    required this.languages,
    required this.currency,
    required this.callingCode,
    required this.flagUrl,
  });

  /// Code ISO alpha-2, affiché dans la plaque ("PT").
  final String code;

  /// Nom courant ("Portugal").
  final String name;

  /// Capitale principale de chaque pays via l' API
  final String capital;

  /// Continent.
  final String region;

  /// Sous-région ("Southern Europe").
  final String subregion;

  // Population totale
  final int population;

  /// Noms des langues ("Portuguese").
  final List<String> languages;

  /// Monnaie principale formatée ("Euro (€)"), vide si inconnue.
  final String currency;

  /// Indicatif téléphonique ("+351"), vide si inconnu.
  final String callingCode;

  /// PNG du drapeau, vide si absent.
  final String flagUrl;

  String get subtitle =>
      [capital, subregion].where((s) => s.isNotEmpty).join(' · ');

  /// 10305564 -> "10,305,564", comme sur la maquette.
  String get populationText {
    final digits = population.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// `true` si [query] apparaît dans le nom ou la capitale (insensible à la
  /// casse). C'est le filtre "por" -> Portugal de la maquette.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || capital.toLowerCase().contains(q);
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    final names = json['names'] as Map<String, dynamic>? ?? const {};
    final codes = json['codes'] as Map<String, dynamic>? ?? const {};
    final capitals = json['capitals'] as List<dynamic>? ?? const [];
    final languages = json['languages'] as List<dynamic>? ?? const [];
    final currencies = json['currencies'] as List<dynamic>? ?? const [];
    final callingCodes = json['calling_codes'] as List<dynamic>? ?? const [];
    final flag = json['flag'] as Map<String, dynamic>? ?? const {};

    return Country(
      code: codes['alpha_2'] as String? ?? '',
      name: names['common'] as String? ?? '',
      capital: capitals.isEmpty
          ? ''
          : (capitals.first as Map<String, dynamic>)['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
      subregion: json['subregion'] as String? ?? '',
      population: (json['population'] as num?)?.toInt() ?? 0,
      languages: languages
          .map((l) => (l as Map<String, dynamic>)['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList(),
      currency: _formatCurrency(currencies),
      callingCode: callingCodes.isEmpty ? '' : '+${callingCodes.first}',
      flagUrl: flag['url_png'] as String? ?? '',
    );
  }

  static String _formatCurrency(List<dynamic> currencies) {
    if (currencies.isEmpty) return '';
    final first = currencies.first as Map<String, dynamic>;
    final name = first['name'] as String? ?? '';
    final symbol = first['symbol'] as String? ?? '';
    if (name.isEmpty) return symbol;
    return symbol.isEmpty ? name : '$name ($symbol)';
  }
}
