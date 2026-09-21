import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../models/photo_analysis.dart';
import '../services/gemini_service.dart';
import '../services/photo_service.dart';

/// Prend une photo (caméra ou galerie) et la fait analyser par Gemini Vision.
class PhotoRepository {
  PhotoRepository({required this.photos, required this.gemini});

  final PhotoService photos;
  final GeminiService gemini;

  /// Renvoie `null` si l'utilisateur ferme le sélecteur sans choisir d'image.
  Future<PhotoResult?> pickAndAnalyze(ImageSource source) async {
    final bytes = await photos.pick(source);
    if (bytes == null) return null;
    final analysis = await gemini.analyzePhoto(bytes);
    return PhotoResult(imageBytes: bytes, analysis: analysis);
  }
}

/// L'image choisie (pour l'afficher) et ce que Gemini en a compris.
class PhotoResult {
  const PhotoResult({required this.imageBytes, required this.analysis});

  final Uint8List imageBytes;
  final PhotoAnalysis analysis;
}
