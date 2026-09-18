import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../providers/ui_providers.dart';
import '../screens/photo_page.dart';
import '../screens/saved_page.dart';
import '../screens/search_page.dart';

/// Les onglets du bas : SEARCH | PHOTO | SAVED, avec un trait rouge au-dessus
/// de l'onglet actif. Les écrans restent montés (IndexedStack) pour ne pas
/// recharger la liste des pays à chaque changement d'onglet.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [SearchPage(), PhotoPage(), SavedPage()],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: const SafeArea(
          top: false,
          child: Row(
            children: [
              _Tab(label: 'SEARCH', index: 0),
              _Tab(label: 'PHOTO', index: 1),
              _Tab(label: 'SAVED', index: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends ConsumerWidget {
  const _Tab({required this.label, required this.index});

  final String label;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(currentTabProvider) == index;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(currentTabProvider.notifier).state = index,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 3,
                color: active ? AppColors.primary : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              fontSize: 12,
              color: active ? AppColors.primary : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}
