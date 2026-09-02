import 'package:flutter/material.dart';

/// Botón principal de llamada a la acción para iniciar la comunicación
class BotonComenzarWidget extends StatelessWidget {
  final VoidCallback onTap;

  const BotonComenzarWidget({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(28.0),
        elevation: 6,
        child: InkWell(
          borderRadius: BorderRadius.circular(28.0),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 320, minHeight: 180),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Comenzar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
