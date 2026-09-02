import '../entities/estado_stt.dart';

/// Contrato abstracto del repositorio de Voz a Texto (STT)
abstract class SttRepository {
  /// Inicia la escucha y captura de audio del micrófono
  Future<void> iniciarEscucha({required Function(String texto) onResultado});

  /// Detiene la escucha activa
  Future<void> detenerEscucha();

  /// Obtiene el estado actual del reconocimiento
  EstadoStt obtenerEstado();
}
