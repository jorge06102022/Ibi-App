import '../../domain/entities/senas_traduccion.dart';
import '../../domain/repositories/traductor_senas_repository.dart';
import '../datasources/traductor_senas_datasource.dart';

/// Implementación del repositorio de traducción a señas
class TraductorSenasRepositoryImpl implements TraductorSenasRepository {
  final TraductorSenasDataSource _dataSource;

  TraductorSenasRepositoryImpl({TraductorSenasDataSource? dataSource})
      : _dataSource = dataSource ?? TraductorSenasDataSource();

  @override
  Future<SenasTraduccion> traducirTextoASenas(String texto) async {
    return _dataSource.translate(texto);
  }

  @override
  Future<List<SenasTraduccion>> obtenerVocabularioDisponible() async {
    return [];
  }
}
