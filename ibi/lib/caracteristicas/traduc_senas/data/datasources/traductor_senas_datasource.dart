import 'package:flutter/foundation.dart';
import '../../domain/entities/senas_traduccion.dart';

/// Fuente de datos para el motor / diccionario de traducción de señas
class TraductorSenasDataSource {
  Future<SenasTraduccion> translate(String text) async {
    debugPrint('[TraductorSenasDataSource] Procesando texto para señas: "$text"');
    
    // Divide en palabras/glosas simplificadas
    final tokens = text
        .toUpperCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();

    return SenasTraduccion(
      textoOriginal: text,
      glosas: tokens,
      disponible: true,
    );
  }
}
