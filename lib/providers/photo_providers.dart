import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../repositories/photo_repository.dart';
import '../services/photo_service.dart';
import 'itinerary_providers.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(
    photos: PhotoService(),
    gemini: ref.watch(geminiServiceProvider),
  );
});

/// Résultat de la dernière photo analysée.
///
/// Un `AsyncNotifier` parce que c'est un bouton qui déclenche le travail
/// (et pas l'ouverture de l'écran). `state` passe par loading, puis data
/// ou error : l'écran affiche le bon état avec `.when()`.
class PhotoNotifier extends AutoDisposeAsyncNotifier<PhotoResult?> {
  @override
  Future<PhotoResult?> build() async => null; // rien au départ

  Future<void> analyze(ImageSource source) async {
    final previous = state.value;
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(photoRepositoryProvider)
          .pickAndAnalyze(source);
      // Sélecteur fermé sans choisir : on garde le résultat précédent.
      state = AsyncData(result ?? previous);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final photoProvider =
    AsyncNotifierProvider.autoDispose<PhotoNotifier, PhotoResult?>(
      PhotoNotifier.new,
    );
