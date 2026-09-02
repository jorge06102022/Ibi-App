import '../../domain/entities/frase_recurrente.dart';
import '../../domain/repositories/frases_recurrentes_repository.dart';
import '../datasources/frases_local_datasource.dart';

/// Implementación del repositorio de frases recurrentes
class FrasesRecurrentesRepositoryImpl implements FrasesRecurrentesRepository {
  final FrasesLocalDataSource _dataSource;

  FrasesRecurrentesRepositoryImpl({FrasesLocalDataSource? dataSource})
      : _dataSource = dataSource ?? FrasesLocalDataSource();

  @override
  Future<List<FraseRecurrente>> obtenerFrases() async {
    return _dataSource.getPhrases();
  }

  @override
  Future<void> agregarFrase(String texto) async {
    await _dataSource.addPhrase(texto);
  }

  @override
  Future<void> editarFrase(String id, String nuevoTexto) async {
    await _dataSource.updatePhrase(id, nuevoTexto);
  }

  @override
  Future<void> eliminarFrase(String id) async {
    await _dataSource.deletePhrase(id);
  }
}
