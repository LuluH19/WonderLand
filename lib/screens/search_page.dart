import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../models/country.dart';
import '../providers/country_providers.dart';
import '../widgets/message_view.dart';

/// Écran "Search any country." (parcours-1.png).
///
/// Tout l'état vient de Riverpod : la liste des pays de `countriesProvider`,
/// le texte tapé de `searchQueryProvider`. Le filtrage est fait par le
/// repository, l'écran ne fait qu'afficher.
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesProvider);
    final query = ref.watch(searchQueryProvider);
    final repository = ref.watch(countryRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WONDERLAND',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'Search any country.',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (text) =>
                        ref.read(searchQueryProvider.notifier).state = text,
                    decoration: const InputDecoration(
                      hintText: 'Country name, e.g. Portugal',
                      filled: true,
                      fillColor: AppColors.fieldFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // Les trois états possibles d'un chargement asynchrone.
              child: countries.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => MessageView(
                  title: 'Could not load countries.',
                  message: '$error',
                  buttonLabel: 'RETRY',
                  onPressed: () => ref.invalidate(countriesProvider),
                ),
                data: (all) =>
                    _CountryList(countries: repository.filter(all, query)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryList extends StatelessWidget {
  const _CountryList({required this.countries});

  final List<Country> countries;

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 1,
      color: AppColors.textGrey,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "11 COUNTRIES                REST COUNTRIES".
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${countries.length} COUNTRIES', style: headerStyle),
              const Text('REST COUNTRIES', style: headerStyle),
            ],
          ),
        ),
        Expanded(
          child: countries.isEmpty
              ? const MessageView(
                  title: 'No country found.',
                  message:
                      'Try a country name or a capital, e.g. Portugal, '
                      'Tokyo, Nairobi.',
                )
              : ListView.separated(
                  itemCount: countries.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) =>
                      CountryTile(country: countries[index]),
                ),
        ),
      ],
    );
  }
}

/// Une ligne de la liste : plaque ISO, nom, "capitale · sous-région", flèche.
class CountryTile extends StatelessWidget {
  const CountryTile({super.key, required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: Container(
        width: 40,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: Text(
          country.code,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      title: Text(
        country.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        country.subtitle,
        style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward, color: AppColors.primary),
      onTap: () => context.push('/country', extra: country),
    );
  }
}
