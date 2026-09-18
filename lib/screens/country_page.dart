import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../models/country.dart';
import '../providers/ui_providers.dart';
import 'itinerary_page.dart';

/// Fiche pays de la maquette (parcours-2.png) : bandeau drapeau, six faits
/// en grille 2x3, puis le choix du style de voyage et le bouton Gemini.
class CountryPage extends StatelessWidget {
  const CountryPage({super.key, required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _FlagBanner(country: country),
          _FactsGrid(country: country),
          _TravelStyleSection(country: country),
        ],
      ),
    );
  }
}

/// Bandeau sombre : drapeau en filigrane, bouton BACK, sous-région et nom.
class _FlagBanner extends StatelessWidget {
  const _FlagBanner({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    // Pas de hauteur fixe : la barre de statut (SafeArea) et un nom de pays
    // long doivent pouvoir pousser le bandeau vers le bas sans déborder.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 220),
      child: ColoredBox(
        color: AppColors.textDark,
        child: Stack(
          children: [
            if (country.flagUrl.isNotEmpty)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.network(
                    country.flagUrl,
                    fit: BoxFit.cover,
                    // Pas de réseau ou URL cassée : on garde juste le fond.
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textDark,
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text(
                        'BACK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      country.subregion.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      country.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grille 2 colonnes : CAPITAL / POPULATION, LANGUAGES / CURRENCY,
/// REGION / CALLING CODE.
class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('CAPITAL', country.capital),
      ('POPULATION', country.populationText),
      ('LANGUAGES', country.languages.join(', ')),
      ('CURRENCY', country.currency),
      (
        'REGION',
        country.subregion.isEmpty ? country.region : country.subregion,
      ),
      ('CALLING CODE', country.callingCode),
    ];

    return Column(
      children: [
        for (var i = 0; i < facts.length; i += 2)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Fact(label: facts[i].$1, value: facts[i].$2),
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                  Expanded(
                    child: _Fact(
                      label: facts[i + 1].$1,
                      value: facts[i + 1].$2,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Choix du style de voyage puis bouton qui ouvre l'écran itinéraire.
/// La puce sélectionnée vit dans `travelStyleProvider` (pas de setState).
class _TravelStyleSection extends ConsumerWidget {
  const _TravelStyleSection({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(travelStyleProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TRAVEL STYLE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in travelStyles)
                _StyleChip(
                  label: style,
                  selected: style == selected,
                  onTap: () =>
                      ref.read(travelStyleProvider.notifier).state = style,
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, thickness: 1),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ItineraryPage(country: country, travelStyle: selected),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
              elevation: 0,
            ),
            child: const Text(
              'GENERATE 3-DAY ITINERARY  →',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gemini uses the country, its capital and your travel style.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFBEEEA) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.textDark : const Color(0xFFE8A79A),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: selected ? AppColors.textDark : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
