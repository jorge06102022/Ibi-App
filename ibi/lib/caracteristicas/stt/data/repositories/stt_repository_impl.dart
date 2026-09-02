import '../../domain/entities/estado_stt.dart';
import '../../domain/repositories/stt_repository.dart';
import '../datasources/stt_local_datasource.dart';

/// Implementación del repositorio STT
class SttRepositoryImpl implements SttRepository {
  final SttLocalDataSource _dataSource;
  EstadoStt _estado = const EstadoStt();

  SttRepositoryImpl({SttLocalDataSource? dataSource})
      : _dataSource = dataSource ?? SttLocalDataSource();

  @override
  Future<void> iniciarEscucha({required Function(String texto) onResultado}) async {
    _estado = _estado.copyWith(tipo: EstadoSttTipo.escuchando);
    await _dataSource.startListening(
      onData: (transcripcion) {
        _estado = _estado.copyWith(
          tipo: EstadoSttTipo.escuchando,
          textoTranscrito: transcripcion,
        );
        onResultado(transcripcion);
      },
    );
  }

  @override
  Future<void> detenerEscucha() async {
    await _dataSource.stopListening();
    _estado = _estado.copyWith(tipo: EstadoSttTipo.inactivo);
  }

  @override
  EstadoStt obtenerEstado() => _estado;
}
