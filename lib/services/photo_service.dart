import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Ouvre l'appareil photo ou la galerie et renvoie l'image en octets.
class PhotoService {
  final ImagePicker _picker = ImagePicker();

  /// Renvoie `null` si l'utilisateur annule.
  /// L'image est réduite (1024 px, qualité 80) pour l'envoyer vite à Gemini.
  Future<Uint8List?> pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (file == null) return null;
    return file.readAsBytes();
  }
}
