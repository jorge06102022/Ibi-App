import 'package:flutter/foundation.dart';
import '../../domain/entities/senas_traduccion.dart';
import '../../domain/repositories/traductor_senas_repository.dart';
import '../../data/repositories/traductor_senas_repository_impl.dart';

/// Controlador para traducir texto a señas y coordinar el visor/avatar
class TraductorSenasController extends ChangeNotifier {
  final TraductorSenasRepository _repository;
  SenasTraduccion? _traduccionActual;
  bool _estaProcesando = false;

  TraductorSenasController({TraductorSenasRepository? repository})
      : _repository = repository ?? TraductorSenasRepositoryImpl();

  SenasTraduccion? get traduccionActual => _traduccionActual;
  bool get estaProcesando => _estaProcesando;

  Future<void> traducir(String texto) async {
    if (texto.trim().isEmpty) return;

    _estaProcesando = true;
    notifyListeners();

    _traduccionActual = await _repository.traducirTextoASenas(texto.trim());
    _estaProcesando = false;
    notifyListeners();
  }

  void limpiar() {
    _traduccionActual = null;
    notifyListeners();
  }
}
