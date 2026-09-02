import 'package:flutter/material.dart';

/// Selector Popup para cambiar la velocidad de síntesis de voz (1.0x, 1.2x, 1.5x)
class SelectorVelocidadTts extends StatelessWidget {
  final double velocidadActual;
  final ValueChanged<double> onVelocidadCambiada;

  const SelectorVelocidadTts({
    super.key,
    required this.velocidadActual,
    required this.onVelocidadCambiada,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: velocidadActual,
      tooltip: 'Velocidad de Voz',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed_rounded, size: 20),
          const SizedBox(width: 4),
          Text(
            '${velocidadActual}x',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
      onSelected: onVelocidadCambiada,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 1.0, child: Text('Normal (1.0x)')),
        PopupMenuItem(value: 1.2, child: Text('Rápido (1.2x)')),
        PopupMenuItem(value: 1.5, child: Text('Muy Rápido (1.5x)')),
      ],
    );
  }
}
