import '../entities/frase_recurrente.dart';

/// Contrato abstracto para la persistencia y gestión de frases recurrentes ("Hablar")
abstract class FrasesRecurrentesRepository {
  /// Obtiene la lista de todas las frases guardadas
  Future<List<FraseRecurrente>> obtenerFrases();

  /// Agrega una nueva frase rápida
  Future<void> agregarFrase(String texto);

  /// Edita una frase existente por ID
  Future<void> editarFrase(String id, String nuevoTexto);

  /// Elimina una frase por ID
  Future<void> eliminarFrase(String id);
}
