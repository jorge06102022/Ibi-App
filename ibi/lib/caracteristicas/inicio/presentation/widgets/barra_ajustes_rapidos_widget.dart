import 'package:flutter/material.dart';

/// Barra de ajustes rápidos (Alternar tema, Editar apodo)
class BarraAjustesRapidosWidget extends StatelessWidget {
  final bool esModoOscuro;
  final VoidCallback onAlternarTema;
  final VoidCallback onEditarApodo;

  const BarraAjustesRapidosWidget({
    super.key,
    required this.esModoOscuro,
    required this.onAlternarTema,
    required this.onEditarApodo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: onAlternarTema,
              icon: Icon(
                esModoOscuro
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                size: 20,
              ),
              label: Text(
                esModoOscuro ? 'Modo Claro' : 'Modo Oscuro',
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
            TextButton.icon(
              onPressed: onEditarApodo,
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text('Editar apodo'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
