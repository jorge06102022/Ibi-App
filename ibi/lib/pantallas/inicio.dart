import 'package:flutter/material.dart';
import 'lif.dart';
import 'com.dart';

// El Home
class PantallaInicio extends StatefulWidget {
  final bool esModoOscuro;
  final VoidCallback onAlternarTema;
  final VoidCallback onEditarApodo;

  const PantallaInicio({
    super.key,
    required this.esModoOscuro,
    required this.onAlternarTema,
    required this.onEditarApodo,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  String nombreUsuario = 'Usuario';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ibi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, size: 32),
            tooltip: 'Frases Recurrentes',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ListaFrasesModal(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool esPantallaAncha = constraints.maxWidth > 600;

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: esPantallaAncha ? 600 : double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TARJETA DE SALUDO Y LOGO
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Icon(
                              Icons.accessibility_new_rounded,
                              size: 36,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, $nombreUsuario',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Presiona comenzar, y vive la experiencia de comunicación ibi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // BOTON
                    Center(
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(28.0),
                        elevation: 6,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28.0),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PantallaComunicacion(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 320, minHeight: 180),
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Comenzar',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // PIE DE PÁGINA: AJUSTES RÁPIDOS
                    Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onAlternarTema,
                          icon: Icon(
                            widget.esModoOscuro ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                            size: 20,
                          ),
                          label: Text(
                            widget.esModoOscuro ? 'Modo Claro' : 'Modo Oscuro',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),

                        TextButton.icon(
                          onPressed: widget.onEditarApodo,
                          icon: const Icon(Icons.edit_rounded, size: 20),
                          label: const Text('Editar apodo'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}