import '../../domain/entities/mensaje_chat.dart';
import '../../domain/entities/sesion_conversacion.dart';

/// Fuente de datos local en memoria / almacenamiento para el historial de conversaciones
class HistoriaLocalDataSource {
  final List<MensajeChat> _mensajesActivos = [
    MensajeChat(
      texto: 'Hola, ¿en qué puedo ayudarte hoy?',
      esMio: false,
    ),
    MensajeChat(
      texto: 'Hola, necesito consultar sobre un servicio',
      esMio: true,
      velocidad: 1.0,
    ),
  ];

  final List<SesionConversacion> _sesionesGuardadas = [];

  Future<List<MensajeChat>> getActiveMessages() async {
    return List.unmodifiable(_mensajesActivos);
  }

  Future<void> saveMessage(MensajeChat message) async {
    _mensajesActivos.add(message);
  }

  Future<void> saveSession(SesionConversacion session) async {
    _sesionesGuardadas.add(session);
  }

  Future<List<SesionConversacion>> getSavedSessions() async {
    return List.unmodifiable(_sesionesGuardadas);
  }

  Future<void> clearActiveMessages() async {
    _mensajesActivos.clear();
  }
}
