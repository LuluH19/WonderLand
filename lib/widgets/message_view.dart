import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Bloc "titre + explication (+ bouton)" utilisé pour les états vide et
/// erreur : "Nothing saved yet.", "Could not load countries.", etc.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.textGrey)),
          if (buttonLabel != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onPressed, child: Text(buttonLabel!)),
          ],
        ],
      ),
    );
  }
}
