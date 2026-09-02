import '../entities/configuracion_tts.dart';

/// Contrato abstracto para el motor de síntesis de voz (TTS)
abstract class TtsRepository {
  /// Vocaliza un texto con la configuración dada
  Future<void> hablar(String texto, {double velocidad = 1.0});

  /// Detiene la reproducción de audio actual
  Future<void> detener();

  /// Actualiza la configuración de síntesis
  void actualizarConfiguracion(ConfiguracionTts configuracion);

  /// Obtiene la configuración actual
  ConfiguracionTts obtenerConfiguracion();
}
