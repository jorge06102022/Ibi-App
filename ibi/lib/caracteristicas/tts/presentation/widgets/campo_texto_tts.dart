import 'package:flutter/material.dart';

/// Campo de texto optimizado para escribir frases que se reproducirán vía TTS
class CampoTextoTts extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;

  const CampoTextoTts({
    super.key,
    required this.controller,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onEnviar(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Escriba lo que desea decir...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.play_circle_fill_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 36,
          ),
          tooltip: 'Vocalizar frase (TTS)',
          onPressed: onEnviar,
        ),
      ],
    );
  }
}
