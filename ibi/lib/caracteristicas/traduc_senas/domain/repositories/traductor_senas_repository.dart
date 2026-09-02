import '../entities/senas_traduccion.dart';

/// Contrato abstracto para la traducción de lenguaje natural a lengua de señas
abstract class TraductorSenasRepository {
  /// Traduce una frase o texto a estructura de señas / glosas
  Future<SenasTraduccion> traducirTextoASenas(String texto);

  /// Obtiene señas predefinidas o animaciones disponibles
  Future<List<SenasTraduccion>> obtenerVocabularioDisponible();
}
