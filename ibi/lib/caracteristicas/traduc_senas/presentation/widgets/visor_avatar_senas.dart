import 'package:flutter/material.dart';
import 'package:ibi/core/constants/app_colors.dart';
import '../controllers/traductor_senas_controller.dart';

/// Visor visual para el Avatar / Glosas de Lengua de Señas
class VisorAvatarSenas extends StatelessWidget {
  final TraductorSenasController controller;

  const VisorAvatarSenas({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final traduccion = controller.traduccionActual;
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    if (traduccion == null && !controller.estaProcesando) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: esOscuro ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.sign_language_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Traducción a Lengua de Señas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: controller.limpiar,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (controller.estaProcesando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (traduccion != null) ...[
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: traduccion.glosas.map((glosa) {
                return Chip(
                  label: Text(
                    glosa,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
