import 'package:flutter/material.dart';
import 'package:ibi/caracteristicas/historia/domain/entities/mensaje_chat.dart';
import 'package:ibi/core/constants/app_colors.dart';
import 'package:ibi/core/widgets/pantalla_gigante_dialog.dart';

/// Widget para renderizar una burbuja de mensaje individual (TTS usuario o STT entorno)
class BurbujaMensajeWidget extends StatelessWidget {
  final MensajeChat mensaje;
  final Function(String texto, double velocidad)? onReproducirTts;
  final Function(String texto)? onTraducirSenas;

  const BurbujaMensajeWidget({
    super.key,
    required this.mensaje,
    this.onReproducirTts,
    this.onTraducirSenas,
  });

  @override
  Widget build(BuildContext context) {
    final esMio = mensaje.esMio;
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: esMio
              ? Theme.of(context).colorScheme.primary
              : (esOscuro
                  ? AppColors.bubbleDarkReceiver
                  : AppColors.bubbleLightReceiver),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0),
            bottomLeft: Radius.circular(esMio ? 20.0 : 4.0),
            bottomRight: Radius.circular(esMio ? 4.0 : 20.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          // Presión larga: Expande la burbuja a Pantalla Gigante
          onLongPress: () => PantallaGiganteDialog.show(context, mensaje.texto),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mensaje.texto,
                  style: TextStyle(
                    fontSize: 16,
                    color: esMio
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón Play para reproducir la frase de nuevo (TTS)
                    if (esMio) ...[
                      GestureDetector(
                        onTap: () {
                          if (onReproducirTts != null) {
                            onReproducirTts!(mensaje.texto, mensaje.velocidad);
                          }
                        },
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${mensaje.velocidad}x',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],

                    // Botón para traducir mensaje del entorno a Lengua de Señas
                    if (!esMio && onTraducirSenas != null) ...[
                      GestureDetector(
                        onTap: () => onTraducirSenas!(mensaje.texto),
                        child: Icon(
                          Icons.sign_language_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
