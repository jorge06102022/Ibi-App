import 'package:flutter/foundation.dart';
import '../../domain/entities/estado_stt.dart';
import '../../domain/repositories/stt_repository.dart';
import '../../data/repositories/stt_repository_impl.dart';

/// Controlador para la interacción con el micrófono y flujo STT
class SttController extends ChangeNotifier {
  final SttRepository _repository;
  EstadoStt _estado = const EstadoStt();

  SttController({SttRepository? repository})
      : _repository = repository ?? SttRepositoryImpl();

  EstadoStt get estado => _estado;
  bool get estaEscuchando => _estado.estaEscuchando;

  Future<void> alternarEscucha({required Function(String texto) onMensajeCapturado}) async {
    if (estaEscuchando) {
      await _repository.detenerEscucha();
      _estado = _repository.obtenerEstado();
      notifyListeners();
    } else {
      await _repository.iniciarEscucha(
        onResultado: (texto) {
          _estado = _repository.obtenerEstado();
          notifyListeners();
          onMensajeCapturado(texto);
        },
      );
      _estado = _repository.obtenerEstado();
      notifyListeners();
    }
  }

  Future<void> detener() async {
    if (estaEscuchando) {
      await _repository.detenerEscucha();
      _estado = _repository.obtenerEstado();
      notifyListeners();
    }
  }
}
