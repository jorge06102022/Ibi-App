import 'package:flutter/material.dart';

/// Recuadro estilizado con el logotipo de IBI
class LogoCardWidget extends StatelessWidget {
  const LogoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            size: 64,
            color: primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Logotipo de IBI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
