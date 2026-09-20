import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../models/itinerary.dart';
import '../models/photo_analysis.dart';

/// Appels à Gemini via Firebase AI Logic (pas de clé API dans l'app).
///
/// On demande toujours une réponse en JSON avec un schéma : Gemini renvoie
/// alors exactement les champs attendus, faciles à lire avec `jsonDecode`.
class GeminiService {
  /// Modèle utilisé pour le texte et pour les images.
  static const modelName = 'gemini-3.5-flash-lite';

  GenerativeModel _model(Schema schema) {
    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );
  }

  /// Envoie la requête et transforme la réponse JSON en Map.
  Future<Map<String, dynamic>> _ask(Schema schema, List<Part> parts) async {
    final GenerateContentResponse response;
    try {
      response = await _model(schema).generateContent([Content.multi(parts)]);
    } catch (e) {
      // Pas de réseau, App Check refusé, modèle saturé... on rend un message
      // court que l'écran peut afficher tel quel.
      throw GeminiException('Gemini est indisponible : $e');
    }
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw const GeminiException('Gemini a renvoyé une réponse vide.');
    }
    return jsonDecode(text) as Map<String, dynamic>;
  }

  /// "GENERATE 3-DAY ITINERARY" : 3 journées dans la capitale du pays.
  Future<Itinerary> generateItinerary({
    required String countryName,
    required String capital,
    required String travelStyle,
  }) async {
    final schema = Schema.object(
      properties: {
        'city': Schema.string(),
        'summary': Schema.string(),
        'days': Schema.array(
          items: Schema.object(
            properties: {
              'title': Schema.string(),
              'description': Schema.string(),
            },
          ),
        ),
      },
    );
    final prompt =
        'Plan me 3 days in ${capital.isEmpty ? countryName : capital}, '
        '$countryName, focused on ${travelStyle.toLowerCase()}. '
        'Answer in English. "city" is the city name. "summary" is one short '
        'sentence. "days" has exactly 3 items: "title" like '
        '"DAY 1 - Alfama & the river", "description" with morning, afternoon '
        'and evening in 2 or 3 sentences.';

    final json = await _ask(schema, [TextPart(prompt)]);
    return Itinerary.fromMap(json)
      ..countryName = countryName
      ..travelStyle = travelStyle;
  }

  /// Gemini Vision : reconnaît le lieu et le pays sur une photo.
  Future<PhotoAnalysis> analyzePhoto(Uint8List imageBytes) async {
    final schema = Schema.object(
      properties: {
        'placeName': Schema.string(),
        'countryName': Schema.string(),
        'description': Schema.string(),
      },
    );
    const prompt =
        'Look at this travel photo. Identify the landmark, dish or place '
        '("placeName") and the country it is in ("countryName", the common '
        'English name, e.g. "Portugal"). Explain in 2 or 3 sentences '
        '("description"). Use an empty string when you are not sure.';

    final json = await _ask(schema, [
      const TextPart(prompt),
      InlineDataPart('image/jpeg', imageBytes),
    ]);
    return PhotoAnalysis.fromMap(json);
  }
}

/// Erreur lisible affichée telle quelle à l'écran.
class GeminiException implements Exception {
  const GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}
