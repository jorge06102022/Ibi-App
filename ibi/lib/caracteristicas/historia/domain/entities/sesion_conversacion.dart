import 'mensaje_chat.dart';

/// Entidad para representar una sesión o biblioteca de conversaciones
class SesionConversacion {
  final String id;
  final String titulo;
  final DateTime fechaInicio;
  final List<MensajeChat> mensajes;

  const SesionConversacion({
    required this.id,
    required this.titulo,
    required this.fechaInicio,
    required this.mensajes,
  });

  SesionConversacion copyWith({
    String? id,
    String? titulo,
    DateTime? fechaInicio,
    List<MensajeChat>? mensajes,
  }) {
    return SesionConversacion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      mensajes: mensajes ?? this.mensajes,
    );
  }
}
