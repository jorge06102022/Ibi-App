import 'package:flutter/material.dart';

/// Diálogo accesible a pantalla completa para mostrar texto con tipografía de alto contraste y tamaño gigante
class PantallaGiganteDialog extends StatelessWidget {
  final String texto;

  const PantallaGiganteDialog({
    super.key,
    required this.texto,
  });

  static Future<void> show(BuildContext context, String texto) {
    return showDialog(
      context: context,
      builder: (context) => PantallaGiganteDialog(texto: texto),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 32),
          tooltip: 'Cerrar vista gigante',
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
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
