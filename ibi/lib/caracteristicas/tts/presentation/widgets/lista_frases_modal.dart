import 'package:flutter/material.dart';
import 'package:ibi/caracteristicas/tts/domain/entities/frase_recurrente.dart';
import 'package:ibi/caracteristicas/tts/presentation/controllers/tts_controller.dart';
import 'package:ibi/core/constants/app_colors.dart';
import 'package:ibi/core/widgets/pantalla_gigante_dialog.dart';
import 'opciones_frase_modal.dart';

/// Modal bottom sheet para consultar, agregar y gestionar Frases Recurrentes ("Hablar")
class ListaFrasesModal extends StatefulWidget {
  final TtsController? ttsController;

  const ListaFrasesModal({
    super.key,
    this.ttsController,
  });

  @override
  State<ListaFrasesModal> createState() => _ListaFrasesModalState();
}

class _ListaFrasesModalState extends State<ListaFrasesModal> {
  late final TtsController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.ttsController != null) {
      _controller = widget.ttsController!;
    } else {
      _controller = TtsController();
      _ownsController = true;
    }
    _controller.addListener(_actualizar);
  }

  @override
  void dispose() {
    _controller.removeListener(_actualizar);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  void _dialogoAgregarOEditar({FraseRecurrente? frase}) {
    final textController = TextEditingController(text: frase?.texto ?? '');
    final esEdicion = frase != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar frase' : 'Nueva frase recurrente'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Escriba la frase aquí...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final texto = textController.text.trim();
              if (texto.isNotEmpty) {
                if (esEdicion) {
                  _controller.editarFrase(frase.id, texto);
                } else {
                  _controller.agregarFrase(texto);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    final frases = _controller.frases;

    return Container(
      decoration: BoxDecoration(
        color: esOscuro ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // BARRA SUPERIOR DE ACCIONES (Cerrar X, Título y Agregar +)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 28),
                tooltip: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Frases Recurrentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Agregar nueva frase',
                onPressed: () => _dialogoAgregarOEditar(),
              ),
            ],
          ),
          const Divider(height: 24),

          // LISTA DE FRASES
          Flexible(
            child: _controller.cargandoFrases
                ? const Center(child: CircularProgressIndicator())
                : frases.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No tienes frases guardadas',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: frases.length,
                        itemBuilder: (context, index) {
                          final frase = frases[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            decoration: BoxDecoration(
                              color: esOscuro
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16.0),
                              onLongPress: () {
                                OpcionesFraseModal.show(
                                  context: context,
                                  frase: frase,
                                  onEditar: () =>
                                      _dialogoAgregarOEditar(frase: frase),
                                  onEliminar: () =>
                                      _controller.eliminarFrase(frase.id),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  children: [
                                    // Texto de la frase
                                    Expanded(
                                      child: Text(
                                        frase.texto,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ),

                                    // Botón 1: Play (Reproducir TTS)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: AppColors.actionTeal,
                                      ),
                                      tooltip: 'Reproducir frase',
                                      onPressed: () {
                                        _controller.hablar(frase.texto);
                                      },
                                    ),

                                    // Botón 2: Ojo (Ver frase en pantalla gigante)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.visibility_rounded,
                                        color: AppColors.actionBlue,
                                      ),
                                      tooltip: 'Ver frase completa',
                                      onPressed: () {
                                        PantallaGiganteDialog.show(
                                            context, frase.texto);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
