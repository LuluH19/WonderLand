import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Onglet actif du bas : 0 = SEARCH, 1 = PHOTO, 2 = SAVED.
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Styles de voyage proposés sur la fiche pays.
const travelStyles = ['FOOD', 'CULTURE', 'NATURE', 'HISTORY', 'NIGHTLIFE'];

/// Puce sélectionnée sur la fiche pays.
final travelStyleProvider = StateProvider<String>((ref) => travelStyles.first);

/// `true` une fois l'itinéraire affiché sauvegardé (le bouton passe à
/// "SAVED"). `autoDispose` : remis à `false` quand on quitte l'écran.
final itinerarySavedProvider = StateProvider.autoDispose<bool>((ref) => false);
