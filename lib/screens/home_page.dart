import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/itinerary.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Firestore en temps réel : c'est la preuve que Auth + base sont branchés.
/// À remplacer par la navigation Search / Saved quand ces écrans existeront.
class HomePage extends StatelessWidget {
  HomePage({
    super.key,
    required this.authService,
    FirestoreService? firestoreService,
  }) : firestoreService = firestoreService ?? FirestoreService();

  final AuthService authService;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    final uid = user?.uid ?? '';
    final label = authService.isGuest
        ? 'Guest · anon ${uid.substring(0, uid.length.clamp(0, 4))}...'
        : user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Saved',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bandeau de compte : "SIGNED IN  ana@... | SIGN OUT".
          Container(
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
                  onPressed: authService.signOut,
                  child: const Text('SIGN OUT'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Itinerary>>(
              stream: firestoreService.watchItineraries(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                final items = snapshot.data;
                if (items == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nothing saved yet.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Generate an itinerary and bookmark it. '
                          'It stays here without a connection.',
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return ListTile(
                      title: Text('${it.city} · ${it.days.length} days'),
                      subtitle: Text('${it.countryName} · ${it.travelStyle}'),
                      trailing: TextButton(
                        onPressed: () =>
                            firestoreService.deleteItinerary(uid, it.id),
                        child: const Text('REMOVE'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
