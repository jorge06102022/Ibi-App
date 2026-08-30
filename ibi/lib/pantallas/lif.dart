import 'package:flutter/material.dart';

// PANTALLA WF2: Lista de Frases Recurrentes (lif.dart)
class ListaFrasesModal extends StatefulWidget {
  const ListaFrasesModal({super.key});

  @override
  State<ListaFrasesModal> createState() => _ListaFrasesModalState();
}

class _ListaFrasesModalState extends State<ListaFrasesModal> {
  // Lista de prueba con frases precargadas
  final List<String> _frases = [
    'Buenos días, soy...',
    'Necesito ayuda con esto, por favor',
    '¿Cuál es el precio de este producto?',
    'Muchas gracias por su atención',
  ];

  // Mantener presionado
  void _mostrarOpcionesFrase(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Opciones de la frase',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('Editar frase'),
                  onTap: () {
                    Navigator.pop(context);
                    debugPrint('Editar frase en índice $index');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  title: const Text('Eliminar frase'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _frases.removeAt(index);
                    });
                    debugPrint('Frase eliminada');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: esOscuro ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. BARRA SUPERIOR DE ACCIONES (Cerrar X  y  Agregar +)
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
                onPressed: () {
                  debugPrint('Agregar nueva frase');
                },
              ),
            ],
          ),
          const Divider(height: 24),

          // 2. LISTA DE FRASES
          Flexible(
            child: _frases.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No tienes frases guardadas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _frases.length,
                    itemBuilder: (context, index) {
                      final frase = _frases[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: esOscuro ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          // Al mantener presionado salen Editar / Eliminar
                          onLongPress: () => _mostrarOpcionesFrase(context, index),
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
                                    frase,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),

                                // Botón 1: Play (Reproducir)
                                IconButton(
                                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.teal),
                                  tooltip: 'Reproducir frase',
                                  onPressed: () {
                                    debugPrint('Reproduciendo: $frase');
                                  },
                                ),

                                // Botón 2: Ojo (Ver frase amplia)
                                IconButton(
                                  icon: const Icon(Icons.visibility_rounded, color: Colors.blueAccent),
                                  tooltip: 'Ver frase completa',
                                  onPressed: () {
                                    debugPrint('Ver frase ampliada: $frase');
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