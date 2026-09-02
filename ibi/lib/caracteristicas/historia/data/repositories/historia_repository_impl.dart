import '../../domain/entities/mensaje_chat.dart';
import '../../domain/entities/sesion_conversacion.dart';
import '../../domain/repositories/historia_repository.dart';
import '../datasources/historia_local_datasource.dart';

/// Implementación del repositorio de Historia
class HistoriaRepositoryImpl implements HistoriaRepository {
  final HistoriaLocalDataSource _dataSource;

  HistoriaRepositoryImpl({HistoriaLocalDataSource? dataSource})
      : _dataSource = dataSource ?? HistoriaLocalDataSource();

  @override
  Future<List<MensajeChat>> obtenerMensajesActivos() async {
    return _dataSource.getActiveMessages();
  }

  @override
  Future<void> guardarMensaje(MensajeChat mensaje) async {
    await _dataSource.saveMessage(mensaje);
  }

  @override
  Future<void> guardarSesion(SesionConversacion sesion) async {
    await _dataSource.saveSession(sesion);
  }

  @override
  Future<List<SesionConversacion>> obtenerSesionesGuardadas() async {
    return _dataSource.getSavedSessions();
  }

  @override
  Future<void> limpiarConversacionActiva() async {
    await _dataSource.clearActiveMessages();
  }
}
