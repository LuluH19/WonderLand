import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../models/country.dart';
import '../models/itinerary.dart';
import '../providers/auth_providers.dart';
import '../providers/itinerary_providers.dart';
import '../providers/ui_providers.dart';
import '../widgets/day_card.dart';
import '../widgets/message_view.dart';

/// Écran C de la maquette : Gemini génère 3 journées, puis
/// "SAVE TO FAVORITES".
class ItineraryPage extends ConsumerWidget {
  const ItineraryPage({
    super.key,
    required this.country,
    required this.travelStyle,
  });

  final Country country;
  final String travelStyle;

  ItineraryRequest get _request => (
    countryName: country.name,
    capital: country.capital,
    travelStyle: travelStyle,
  );

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    Itinerary itinerary,
  ) async {
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    await ref.read(itineraryRepositoryProvider).save(itinerary, uid);
    if (!context.mounted) return;
    ref.read(itinerarySavedProvider.notifier).state = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved. Readable offline in SAVED.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod lance la génération au premier `watch` et redessine l'écran
    // quand la réponse (ou l'erreur) arrive.
    final itinerary = ref.watch(itineraryProvider(_request));
    final saved = ref.watch(itinerarySavedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          country.name,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'GEMINI · $travelStyle',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: itinerary.when(
        loading: () => const _GeneratingView(),
        error: (error, _) => MessageView(
          title: 'Gemini could not answer.',
          message: '$error',
          buttonLabel: 'RETRY',
          onPressed: () => ref.invalidate(itineraryProvider(_request)),
        ),
        data: (result) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryBox(text: result.summary),
            const SizedBox(height: 16),
            for (final day in result.days) DayCard(day: day),
            const SizedBox(height: 8),
            const Text(
              'Bookmark it and the full plan stays readable offline.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: saved ? null : () => _save(context, ref, result),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(),
                elevation: 0,
              ),
              icon: Icon(saved ? Icons.star : Icons.star_border, size: 18),
              label: Text(
                saved ? 'SAVED' : 'SAVE TO FAVORITES',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bulle sombre avec la requête, puis indicateur de chargement (C1).
class _GeneratingView extends StatelessWidget {
  const _GeneratingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _UserBubble(text: 'Plan me 3 days, my style first.'),
          SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.textDark,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

/// Encadré gris clair avec la phrase d'introduction de Gemini.
class _SummaryBox extends StatelessWidget {
  const _SummaryBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textDark, height: 1.4),
      ),
    );
  }
}
