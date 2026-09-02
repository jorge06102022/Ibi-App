import 'package:flutter/material.dart';
import 'package:ibi/caracteristicas/historia/presentation/controllers/conversacion_controller.dart';
import 'package:ibi/caracteristicas/historia/presentation/widgets/lista_mensajes_widget.dart';
import 'package:ibi/caracteristicas/stt/presentation/controllers/stt_controller.dart';
import 'package:ibi/caracteristicas/traduc_senas/presentation/controllers/traductor_senas_controller.dart';
import 'package:ibi/caracteristicas/traduc_senas/presentation/widgets/visor_avatar_senas.dart';
import 'package:ibi/caracteristicas/tts/presentation/controllers/tts_controller.dart';
import 'package:ibi/caracteristicas/tts/presentation/widgets/selector_velocidad_tts.dart';
import '../widgets/barra_inferior_comunicacion.dart';

/// Pantalla Principal de Comunicación Activa (WF3)
class PantallaComunicacion extends StatefulWidget {
  const PantallaComunicacion({super.key});

  @override
  State<PantallaComunicacion> createState() => _PantallaComunicacionState();
}

class _PantallaComunicacionState extends State<PantallaComunicacion> {
  final TextEditingController _textController = TextEditingController();

  late final ConversacionController _conversacionController;
  late final TtsController _ttsController;
  late final SttController _sttController;
  late final TraductorSenasController _senasController;

  @override
  void initState() {
    super.initState();
    _conversacionController = ConversacionController();
    _ttsController = TtsController();
    _sttController = SttController();
    _senasController = TraductorSenasController();

    _conversacionController.addListener(_actualizar);
    _ttsController.addListener(_actualizar);
    _sttController.addListener(_actualizar);
    _senasController.addListener(_actualizar);
  }

  @override
  void dispose() {
    _textController.dispose();
    _conversacionController.removeListener(_actualizar);
    _ttsController.removeListener(_actualizar);
    _sttController.removeListener(_actualizar);
    _senasController.removeListener(_actualizar);

    _conversacionController.dispose();
    _ttsController.dispose();
    _sttController.dispose();
    _senasController.dispose();
    super.dispose();
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  // 1. Envío de mensaje escrito por el usuario (TTS - Lado Derecho)
  void _enviarMensajeUsuario() {
    final texto = _textController.text.trim();
    if (texto.isNotEmpty) {
      final velocidad = _ttsController.velocidadSeleccionada;
      _conversacionController.agregarMensajeUsuario(texto, velocidad: velocidad);
      _ttsController.hablar(texto, velocidad: velocidad);
      _textController.clear();
    }
  }

  // 2. Alternar micrófono para capturar voz externa (STT - Lado Izquierdo)
  void _alternarMicrofono() {
    _sttController.alternarEscucha(
      onMensajeCapturado: (transcripcion) {
        _conversacionController.agregarMensajeEntorno(transcripcion);
      },
    );
  }

  // 3. Traducir frase a Lengua de Señas
  void _traducirASenas(String texto) {
    _senasController.traducir(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Selector de Velocidad de Voz (1.0x, 1.2x, 1.5x)
          SelectorVelocidadTts(
            velocidadActual: _ttsController.velocidadSeleccionada,
            onVelocidadCambiada: (nuevaVelocidad) {
              _ttsController.cambiarVelocidad(nuevaVelocidad);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Visor de Señas / Avatar (si está activo)
          VisorAvatarSenas(controller: _senasController),

          // ÁREA CENTRAL: Lista de burbujas (Chat)
          Expanded(
            child: _conversacionController.cargando
                ? const Center(child: CircularProgressIndicator())
                : ListaMensajesWidget(
                    mensajes: _conversacionController.mensajes,
                    onReproducirTts: (texto, vel) =>
                        _ttsController.hablar(texto, velocidad: vel),
                    onTraducirSenas: _traducirASenas,
                  ),
          ),

          // BARRA INFERIOR: Entrada de Texto (TTS) y Botón de Micrófono (STT)
          BarraInferiorComunicacion(
            textController: _textController,
            estaEscuchando: _sttController.estaEscuchando,
            onAlternarMicrofono: _alternarMicrofono,
            onEnviarMensaje: _enviarMensajeUsuario,
          ),
        ],
      ),
    );
  }
}
