import 'package:flutter/material.dart';
import 'package:ibi/core/constants/app_colors.dart';

/// Botón interactivo de micrófono para Speech-to-Text
class BotonMicrofonoStt extends StatelessWidget {
  final bool estaEscuchando;
  final VoidCallback onPressed;

  const BotonMicrofonoStt({
    super.key,
    required this.estaEscuchando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          estaEscuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
          key: ValueKey<bool>(estaEscuchando),
          color: estaEscuchando
              ? AppColors.micActive
              : Theme.of(context).colorScheme.primary,
          size: 28,
        ),
      ),
      tooltip: estaEscuchando
          ? 'Detener micrófono'
          : 'Escuchar entorno (STT)',
      onPressed: onPressed,
    );
  }
}
