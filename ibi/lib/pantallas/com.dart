import 'package:flutter/material.dart';

class MensajeChat {
  final String texto;
  final bool esMio; // true = Lado Derecho (TTS/Tú), false = Lado Izquierdo (STT/Entorno)
  double velocidad;

  MensajeChat({
    required this.texto,
    required this.esMio,
    this.velocidad = 1.0,
  });
}

// PANTALLA WF3: Comunicación Activa (com.dart)
class PantallaComunicacion extends StatefulWidget {
  const PantallaComunicacion({super.key});

  @override
  State<PantallaComunicacion> createState() => _PantallaComunicacionState();
}

class _PantallaComunicacionState extends State<PantallaComunicacion> {
  final TextEditingController _textController = TextEditingController();
  final List<MensajeChat> _mensajes = [
    MensajeChat(texto: 'Hola, ¿en qué puedo ayudarte hoy?', esMio: false),
    MensajeChat(texto: 'Hola, necesito consultar sobre un servicio', esMio: true, velocidad: 1.0),
  ];

  bool _estaEscuchando = false;
  double _velocidadSeleccionada = 1.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 1. Modal para ver la frase en pantalla completa / gigante
  void _mostrarTextoGigante(String texto) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42, // Letra gigante accesible
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. Función para enviar lo escrito por el usuario (Lado Derecho)
  void _enviarMensaje() {
    final texto = _textController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _mensajes.add(
          MensajeChat(
            texto: texto,
            esMio: true,
            velocidad: _velocidadSeleccionada,
          ),
        );
        _textController.clear();
      });
      debugPrint('Reproduciendo TTS a velocidad ${_velocidadSeleccionada}x: $texto');
    }
  }

  // 3. Simulación de escuchar voz externa (STT - Lado Izquierdo)
  void _alternarEscuchar() {
    setState(() {
      _estaEscuchando = !_estaEscuchando;
      if (_estaEscuchando) {
        // Simulación: agregamos un mensaje capturado por el micrófono
        _mensajes.add(
          MensajeChat(
            texto: '...escuchando lo que dice la otra persona...',
            esMio: false,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Selector de Velocidad de Voz (1.0x, 1.2x, 1.5x)
          PopupMenuButton<double>(
            initialValue: _velocidadSeleccionada,
            tooltip: 'Velocidad de Voz',
            icon: Row(
              children: [
                const Icon(Icons.speed_rounded, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_velocidadSeleccionada}x',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            onSelected: (double nuevaVelocidad) {
              setState(() {
                _velocidadSeleccionada = nuevaVelocidad;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1.0, child: Text('Normal (1.0x)')),
              const PopupMenuItem(value: 1.2, child: Text('Rápido (1.2x)')),
              const PopupMenuItem(value: 1.5, child: Text('Muy Rápido (1.5x)')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // ÁREA CENTRAL: Lista de burbujas (Chat)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esMio = msg.esMio;

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
                          : (esOscuro ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20.0),
                        topRight: const Radius.circular(20.0),
                        bottomLeft: Radius.circular(esMio ? 20.0 : 4.0),
                        bottomRight: Radius.circular(esMio ? 4.0 : 20.0),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.0),
                      // Presión larga: Expande la burbuja a Pantalla Gigante
                      onLongPress: () => _mostrarTextoGigante(msg.texto),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.texto,
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
                                // Botón Play para reproducir la frase de nuevo
                                if (esMio) ...[
                                  GestureDetector(
                                    onTap: () {
                                      debugPrint('Reproduciendo a ${msg.velocidad}x: ${msg.texto}');
                                    },
                                    child: Icon(
                                      Icons.play_circle_fill_rounded,
                                      size: 22,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${msg.velocidad}x',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
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
              },
            ),
          ),

          // BARRA INFERIOR: Entrada de Texto (TTS) y Botón de Micrófono (STT)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: esOscuro ? const Color(0xFF1E293B) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón Escuchar (Micrófono STT)
                  IconButton(
                    icon: Icon(
                      _estaEscuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _estaEscuchando ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    tooltip: _estaEscuchando ? 'Detener micrófono' : 'Escuchar entorno (STT)',
                    onPressed: _alternarEscuchar,
                  ),

                  // Caja para escribir tu mensaje
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escriba lo que desea decir...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                      ),
                    ),
                  ),

                  // Botón Play (Enviar y Vocalizar TTS)
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 36,
                    ),
                    tooltip: 'Vocalizar frase (TTS)',
                    onPressed: _enviarMensaje,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}