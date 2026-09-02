import 'package:flutter/material.dart';
import '../../domain/entities/mensaje_chat.dart';
import 'burbuja_mensaje_widget.dart';

/// Widget que despliega la lista de mensajes de la conversación
class ListaMensajesWidget extends StatelessWidget {
  final List<MensajeChat> mensajes;
  final Function(String texto, double velocidad)? onReproducirTts;
  final Function(String texto)? onTraducirSenas;

  const ListaMensajesWidget({
    super.key,
    required this.mensajes,
    this.onReproducirTts,
    this.onTraducirSenas,
  });

  @override
  Widget build(BuildContext context) {
    if (mensajes.isEmpty) {
      return Center(
        child: Text(
          'No hay mensajes aún',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: mensajes.length,
      itemBuilder: (context, index) {
        final msg = mensajes[index];
        return BurbujaMensajeWidget(
          mensaje: msg,
          onReproducirTts: onReproducirTts,
          onTraducirSenas: onTraducirSenas,
        );
      },
    );
  }
}
