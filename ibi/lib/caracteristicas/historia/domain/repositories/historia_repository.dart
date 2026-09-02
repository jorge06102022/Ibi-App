import '../entities/mensaje_chat.dart';
import '../entities/sesion_conversacion.dart';

/// Contrato abstracto para el almacenamiento y persistencia del historial de conversaciones
abstract class HistoriaRepository {
  /// Obtiene los mensajes de la conversación activa
  Future<List<MensajeChat>> obtenerMensajesActivos();

  /// Guarda un nuevo mensaje en la conversación actual
  Future<void> guardarMensaje(MensajeChat mensaje);

  /// Guarda una sesión de conversación completa en el historial
  Future<void> guardarSesion(SesionConversacion sesion);

  /// Obtiene la biblioteca de conversaciones archivadas
  Future<List<SesionConversacion>> obtenerSesionesGuardadas();

  /// Limpia la conversación activa
  Future<void> limpiarConversacionActiva();
}
