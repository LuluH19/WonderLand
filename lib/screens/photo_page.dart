import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/app_colors.dart';
import '../providers/country_providers.dart';
import '../providers/photo_providers.dart';
import '../repositories/photo_repository.dart';
import '../widgets/message_view.dart';

/// Onglet PHOTO : caméra ou galerie, Gemini Vision reconnaît le lieu et le
/// pays, puis un bouton ouvre la fiche du pays.
class PhotoPage extends ConsumerWidget {
  const PhotoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(photoProvider);
    final busy = photo.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const Text(
              'GEMINI VISION',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
            const Text(
              'Where is this?',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Snap a landmark, a dish or a street. Gemini guesses the place '
              'and the country.',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            // Les deux boutons appellent la même méthode avec une source
            // différente.
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_camera,
                    label: 'CAMERA',
                    onPressed: busy
                        ? null
                        : () => ref
                              .read(photoProvider.notifier)
                              .analyze(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library,
                    label: 'GALLERY',
                    onPressed: busy
                        ? null
                        : () => ref
                              .read(photoProvider.notifier)
                              .analyze(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            photo.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => MessageView(
                title: 'Gemini could not analyze the photo.',
                message: '$error',
              ),
              data: (result) => result == null
                  ? const SizedBox.shrink()
                  : _ResultView(result: result),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: const RoundedRectangleBorder(),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}

/// Photo choisie, réponse de Gemini et bouton vers la fiche pays.
class _ResultView extends ConsumerWidget {
  const _ResultView({required this.result});

  final PhotoResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = result.analysis;
    // On cherche le pays deviné dans la liste REST Countries déjà chargée.
    final countries = ref.watch(countriesProvider).value ?? const [];
    final country = ref
        .watch(countryRepositoryProvider)
        .findByName(countries, analysis.countryName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.memory(result.imageBytes, height: 220, fit: BoxFit.cover),
        const SizedBox(height: 16),
        Text(
          analysis.placeName.isEmpty ? 'Unknown place' : analysis.placeName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          analysis.countryName.isEmpty
              ? 'COUNTRY UNKNOWN'
              : analysis.countryName.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          analysis.description,
          style: const TextStyle(color: AppColors.textDark, height: 1.4),
        ),
        const SizedBox(height: 16),
        if (country != null)
          OutlinedButton(
            onPressed: () => context.push('/country', extra: country),
            child: Text('OPEN ${country.name.toUpperCase()}'),
          ),
      ],
    );
  }
}
