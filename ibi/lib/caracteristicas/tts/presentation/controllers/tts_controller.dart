import 'package:flutter/foundation.dart';
import 'package:ibi/caracteristicas/tts/data/repositories/frases_recurrentes_repository_impl.dart';
import 'package:ibi/caracteristicas/tts/data/repositories/tts_repository_impl.dart';
import 'package:ibi/caracteristicas/tts/domain/entities/configuracion_tts.dart';
import 'package:ibi/caracteristicas/tts/domain/entities/frase_recurrente.dart';
import 'package:ibi/caracteristicas/tts/domain/repositories/frases_recurrentes_repository.dart';
import 'package:ibi/caracteristicas/tts/domain/repositories/tts_repository.dart';
import 'package:ibi/core/constants/app_constants.dart';

/// Controlador para la síntesis de voz, velocidad y frases rápidas
class TtsController extends ChangeNotifier {
  final TtsRepository _ttsRepository;
  final FrasesRecurrentesRepository _frasesRepository;

  double _velocidadSeleccionada = AppConstants.defaultSpeechRate;
  List<FraseRecurrente> _frases = [];
  bool _cargandoFrases = false;

  TtsController({
    TtsRepository? ttsRepository,
    FrasesRecurrentesRepository? frasesRepository,
  })  : _ttsRepository = ttsRepository ?? TtsRepositoryImpl(),
        _frasesRepository =
            frasesRepository ?? FrasesRecurrentesRepositoryImpl() {
    cargarFrases();
  }

  double get velocidadSeleccionada => _velocidadSeleccionada;
  List<FraseRecurrente> get frases => _frases;
  bool get cargandoFrases => _cargandoFrases;

  void cambiarVelocidad(double nuevaVelocidad) {
    _velocidadSeleccionada = nuevaVelocidad;
    _ttsRepository.actualizarConfiguracion(
      ConfiguracionTts(velocidad: nuevaVelocidad),
    );
    notifyListeners();
  }

  Future<void> hablar(String texto, {double? velocidad}) async {
    final vel = velocidad ?? _velocidadSeleccionada;
    await _ttsRepository.hablar(texto, velocidad: vel);
  }

  Future<void> cargarFrases() async {
    _cargandoFrases = true;
    notifyListeners();

    _frases = await _frasesRepository.obtenerFrases();
    _cargandoFrases = false;
    notifyListeners();
  }

  Future<void> agregarFrase(String texto) async {
    if (texto.trim().isEmpty) return;
    await _frasesRepository.agregarFrase(texto.trim());
    await cargarFrases();
  }

  Future<void> editarFrase(String id, String nuevoTexto) async {
    if (nuevoTexto.trim().isEmpty) return;
    await _frasesRepository.editarFrase(id, nuevoTexto.trim());
    await cargarFrases();
  }

  Future<void> eliminarFrase(String id) async {
    await _frasesRepository.eliminarFrase(id);
    await cargarFrases();
  }
}
