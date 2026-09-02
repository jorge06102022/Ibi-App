import 'package:flutter/material.dart';
import '../../domain/entities/frase_recurrente.dart';

/// Modal para opciones de frase rápida (Editar, Eliminar)
class OpcionesFraseModal extends StatelessWidget {
  final FraseRecurrente frase;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const OpcionesFraseModal({
    super.key,
    required this.frase,
    required this.onEditar,
    required this.onEliminar,
  });

  static void show({
    required BuildContext context,
    required FraseRecurrente frase,
    required VoidCallback onEditar,
    required VoidCallback onEliminar,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => OpcionesFraseModal(
        frase: frase,
        onEditar: onEditar,
        onEliminar: onEliminar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onEditar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              title: const Text('Eliminar frase'),
              onTap: () {
                Navigator.pop(context);
                onEliminar();
              },
            ),
          ],
        ),
      ),
    );
  }
}
