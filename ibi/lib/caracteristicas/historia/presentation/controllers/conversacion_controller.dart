import 'package:flutter/foundation.dart';
import '../../domain/entities/mensaje_chat.dart';
import '../../domain/repositories/historia_repository.dart';
import '../../data/repositories/historia_repository_impl.dart';

/// Controlador para la gestión de mensajes y flujo del chat en tiempo real
class ConversacionController extends ChangeNotifier {
  final HistoriaRepository _repository;
  List<MensajeChat> _mensajes = [];
  bool _cargando = false;

  ConversacionController({HistoriaRepository? repository})
      : _repository = repository ?? HistoriaRepositoryImpl() {
    cargarMensajes();
  }

  List<MensajeChat> get mensajes => _mensajes;
  bool get cargando => _cargando;

  Future<void> cargarMensajes() async {
    _cargando = true;
    notifyListeners();

    _mensajes = await _repository.obtenerMensajesActivos();
    _cargando = false;
    notifyListeners();
  }

  Future<void> agregarMensajeUsuario(String texto, {double velocidad = 1.0}) async {
    final nuevoMensaje = MensajeChat(
      texto: texto,
      esMio: true,
      velocidad: velocidad,
    );
    await _repository.guardarMensaje(nuevoMensaje);
    await cargarMensajes();
  }

  Future<void> agregarMensajeEntorno(String texto) async {
    final nuevoMensaje = MensajeChat(
      texto: texto,
      esMio: false,
    );
    await _repository.guardarMensaje(nuevoMensaje);
    await cargarMensajes();
  }

  Future<void> limpiarConversacion() async {
    await _repository.limpiarConversacionActiva();
    await cargarMensajes();
  }
}
