import 'package:ibi/caracteristicas/tts/domain/entities/frase_recurrente.dart';
import 'package:ibi/core/constants/app_constants.dart';

/// Almacenamiento local de frases recurrentes
class FrasesLocalDataSource {
  final List<FraseRecurrente> _frases = [];

  FrasesLocalDataSource() {
    _inicializarFrasesPorDefecto();
  }

  void _inicializarFrasesPorDefecto() {
    for (int i = 0; i < AppConstants.defaultPhrases.length; i++) {
      _frases.add(
        FraseRecurrente(
          id: 'frase_$i',
          texto: AppConstants.defaultPhrases[i],
        ),
      );
    }
  }

  Future<List<FraseRecurrente>> getPhrases() async {
    return List.unmodifiable(_frases);
  }

  Future<void> addPhrase(String text) async {
    final nueva = FraseRecurrente(
      id: 'frase_${DateTime.now().millisecondsSinceEpoch}',
      texto: text,
    );
    _frases.add(nueva);
  }

  Future<void> updatePhrase(String id, String newText) async {
    final index = _frases.indexWhere((f) => f.id == id);
    if (index != -1) {
      _frases[index] = _frases[index].copyWith(texto: newText);
    }
  }

  Future<void> deletePhrase(String id) async {
    _frases.removeWhere((f) => f.id == id);
  }
}
