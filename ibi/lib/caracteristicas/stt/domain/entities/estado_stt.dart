/// Estado del sistema Speech-to-Text (STT)
enum EstadoSttTipo {
  inactivo,
  escuchando,
  procesando,
  error,
}

class EstadoStt {
  final EstadoSttTipo tipo;
  final String textoTranscrito;
  final String? mensajeError;

  const EstadoStt({
    this.tipo = EstadoSttTipo.inactivo,
    this.textoTranscrito = '',
    this.mensajeError,
  });

  bool get estaEscuchando => tipo == EstadoSttTipo.escuchando;

  EstadoStt copyWith({
    EstadoSttTipo? tipo,
    String? textoTranscrito,
    String? mensajeError,
  }) {
    return EstadoStt(
      tipo: tipo ?? this.tipo,
      textoTranscrito: textoTranscrito ?? this.textoTranscrito,
      mensajeError: mensajeError ?? this.mensajeError,
    );
  }
}
