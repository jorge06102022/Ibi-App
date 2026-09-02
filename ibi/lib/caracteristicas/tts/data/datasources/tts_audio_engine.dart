import 'package:flutter/foundation.dart';

/// Motor de reproducción de audio y síntesis de voz
class TtsAudioEngine {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> speak(String text, {double rate = 1.0}) async {
    _isPlaying = true;
    debugPrint('[TTS Audio Engine] Reproduciendo a ${rate}x: "$text"');
    // Simula tiempo de vocalización
    await Future.delayed(const Duration(milliseconds: 400));
    _isPlaying = false;
  }

  Future<void> stop() async {
    _isPlaying = false;
    debugPrint('[TTS Audio Engine] Reproducción detenida');
  }
}
