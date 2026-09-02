/// Entidad de dominio que representa un mensaje de la conversación
class MensajeChat {
  final String id;
  final String texto;
  final bool esMio; // true = Usuario (TTS / Derecha), false = Entorno (STT / Izquierda)
  final double velocidad;
  final DateTime fechaHora;

  MensajeChat({
    String? id,
    required this.texto,
    required this.esMio,
    this.velocidad = 1.0,
    DateTime? fechaHora,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        fechaHora = fechaHora ?? DateTime.now();

  MensajeChat copyWith({
    String? id,
    String? texto,
    bool? esMio,
    double? velocidad,
    DateTime? fechaHora,
  }) {
    return MensajeChat(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      esMio: esMio ?? this.esMio,
      velocidad: velocidad ?? this.velocidad,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}
