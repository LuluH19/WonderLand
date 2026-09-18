import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/itinerary.dart';

/// Carte grise d'une journée : "DAY 1 - Alfama & the river" + description.
class DayCard extends StatelessWidget {
  const DayCard({super.key, required this.day});

  final ItineraryDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.fieldFill,
        border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            day.description,
            style: const TextStyle(color: AppColors.textDark, height: 1.4),
          ),
        ],
      ),
    );
  }
}
