import 'dart:async';
import 'package:flutter/foundation.dart';

/// Fuente de datos de audio / micrófono para STT
class SttLocalDataSource {
  bool _isListening = false;

  bool get isListening => _isListening;

  Future<void> startListening({required Function(String transcription) onData}) async {
    _isListening = true;
    debugPrint('[STT LocalDataSource] Micrófono iniciado - capturando audio...');
    // Simula captura de audio / integración con motor de reconocimiento
    onData('...escuchando lo que dice la otra persona...');
  }

  Future<void> stopListening() async {
    _isListening = false;
    debugPrint('[STT LocalDataSource] Micrófono detenido');
  }
}
