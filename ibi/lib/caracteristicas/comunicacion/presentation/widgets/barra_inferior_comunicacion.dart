import 'package:flutter/material.dart';
import 'package:ibi/caracteristicas/stt/presentation/widgets/boton_microfono_stt.dart';
import 'package:ibi/caracteristicas/tts/presentation/widgets/campo_texto_tts.dart';
import 'package:ibi/core/constants/app_colors.dart';

/// Barra inferior de interacción que une el micrófono STT y el campo de texto TTS
class BarraInferiorComunicacion extends StatelessWidget {
  final TextEditingController textController;
  final bool estaEscuchando;
  final VoidCallback onAlternarMicrofono;
  final VoidCallback onEnviarMensaje;

  const BarraInferiorComunicacion({
    super.key,
    required this.textController,
    required this.estaEscuchando,
    required this.onAlternarMicrofono,
    required this.onEnviarMensaje,
  });

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: esOscuro ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón Escuchar (Micrófono STT)
            BotonMicrofonoStt(
              estaEscuchando: estaEscuchando,
              onPressed: onAlternarMicrofono,
            ),

            // Entrada de Texto y Envío TTS
            Expanded(
              child: CampoTextoTts(
                controller: textController,
                onEnviar: onEnviarMensaje,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
