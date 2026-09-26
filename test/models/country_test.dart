import 'package:flutter_test/flutter_test.dart';
import 'package:projet/models/country.dart';

/// Test unitaire : le modèle [Country] est du Dart pur, donc il se teste sans
/// réseau et sans Firebase. On vérifie le décodage d'un pays tel que
/// REST Countries le renvoie, plus les deux getters affichés à l'écran.
void main() {
  test('Country.fromJson lit un pays de la réponse REST Countries', () {
    // Un élément de "data.objects", limité aux champs demandés par
    // CountriesService (voir sa constante _fields).
    final json = <String, dynamic>{
      'names': {'common': 'Portugal'},
      'codes': {'alpha_2': 'PT'},
      'capitals': [
        {'name': 'Lisbon'},
      ],
      'region': 'Europe',
      'subregion': 'Southern Europe',
      'population': 10305564,
      'languages': [
        {'name': 'Portuguese'},
      ],
      'currencies': [
        {'name': 'Euro', 'symbol': '€'},
      ],
      'calling_codes': ['351'],
      'flag': {'url_png': 'https://flagcdn.com/w320/pt.png'},
    };

    final country = Country.fromJson(json);

    expect(country.code, 'PT');
    expect(country.name, 'Portugal');
    expect(country.capital, 'Lisbon');
    expect(country.region, 'Europe');
    expect(country.languages, ['Portuguese']);
    expect(country.currency, 'Euro (€)');
    expect(country.callingCode, '+351');

    // Getters utilisés par les écrans.
    expect(country.populationText, '10,305,564');
    expect(country.subtitle, 'Lisbon · Southern Europe');

    // Le filtre de la barre de recherche.
    expect(country.matches('por'), isTrue);
    expect(country.matches('japan'), isFalse);
  });
}
