import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../models/itinerary.dart';
import '../providers/auth_providers.dart';
import '../providers/itinerary_providers.dart';
import '../widgets/day_card.dart';
import '../widgets/message_view.dart';

/// Écran D de la maquette : bandeau de compte puis favoris (lus dans Isar).
class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedItinerariesProvider);
    final count = saved.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '$count ${count == 1 ? 'ITINERARY' : 'ITINERARIES'} · '
                    'AVAILABLE OFFLINE',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const _AccountBanner(),
            Expanded(
              child: saved.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => MessageView(
                  title: 'Could not read favorites.',
                  message: '$error',
                ),
                data: (items) => items.isEmpty
                    ? const MessageView(
                        title: 'Nothing saved yet.',
                        message:
                            'Generate an itinerary and bookmark it. It stays '
                            'here without a connection.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _SavedCard(itinerary: items[index]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "SIGNED IN  ana@... | SIGN OUT".
class _AccountBanner extends ConsumerWidget {
  const _AccountBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final user = ref.watch(authStateProvider).value;
    final uid = user?.uid ?? '';
    final label = (user?.isAnonymous ?? true)
        ? 'Guest · anon ${uid.substring(0, uid.length.clamp(0, 4))}...'
        : user?.email ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIGNED IN',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: AppColors.textGrey,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: auth.signOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }
}

/// Carte "Lisbon · 3 days" avec le résumé des journées et REMOVE.
class _SavedCard extends ConsumerWidget {
  const _SavedCard({required this.itinerary});

  final Itinerary itinerary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${itinerary.city} · ${itinerary.days.length} days',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.read(itineraryRepositoryProvider).delete(itinerary),
                child: const Text('REMOVE'),
              ),
            ],
          ),
          Text(
            '${itinerary.countryName} · ${itinerary.travelStyle} · saved offline',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          for (final day in itinerary.days) DayCard(day: day),
        ],
      ),
    );
  }
}
