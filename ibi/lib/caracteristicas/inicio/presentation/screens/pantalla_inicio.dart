import 'package:flutter/material.dart';
import 'package:ibi/caracteristicas/comunicacion/presentation/screens/pantalla_comunicacion.dart';
import 'package:ibi/caracteristicas/tts/presentation/widgets/lista_frases_modal.dart';
import 'package:ibi/core/constants/app_constants.dart';
import 'package:ibi/core/utils/responsive_layout.dart';
import '../widgets/barra_ajustes_rapidos_widget.dart';
import '../widgets/boton_comenzar_widget.dart';
import '../widgets/tarjeta_saludo_widget.dart';

/// Pantalla Principal / Home (WF2 / WF3 Entry)
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
  final String _nombreUsuario = 'Usuario';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.maxContainerWidth(context),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TARJETA DE SALUDO Y LOGO
                TarjetaSaludoWidget(nombreUsuario: _nombreUsuario),

                const Spacer(),

                // BOTON DE INICIO
                BotonComenzarWidget(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PantallaComunicacion(),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // PIE DE PÁGINA: AJUSTES RÁPIDOS
                BarraAjustesRapidosWidget(
                  esModoOscuro: widget.esModoOscuro,
                  onAlternarTema: widget.onAlternarTema,
                  onEditarApodo: widget.onEditarApodo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
