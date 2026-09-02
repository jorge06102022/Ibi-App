import '../../domain/entities/configuracion_tts.dart';
import '../../domain/repositories/tts_repository.dart';
import '../datasources/tts_audio_engine.dart';

/// Implementación del repositorio TTS
class TtsRepositoryImpl implements TtsRepository {
  final TtsAudioEngine _audioEngine;
  ConfiguracionTts _configuracion = const ConfiguracionTts();

  TtsRepositoryImpl({TtsAudioEngine? audioEngine})
      : _audioEngine = audioEngine ?? TtsAudioEngine();

  @override
  Future<void> hablar(String texto, {double velocidad = 1.0}) async {
    _configuracion = _configuracion.copyWith(velocidad: velocidad);
    await _audioEngine.speak(texto, rate: velocidad);
  }

  @override
  Future<void> detener() async {
    await _audioEngine.stop();
  }

  @override
  void actualizarConfiguracion(ConfiguracionTts configuracion) {
    _configuracion = configuracion;
  }

  @override
  ConfiguracionTts obtenerConfiguracion() => _configuracion;
}
