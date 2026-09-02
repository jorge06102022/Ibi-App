/// Entidad para la configuración de síntesis de voz (TTS)
class ConfiguracionTts {
  final double velocidad;
  final double tono;
  final double volumen;
  final String idioma;

  const ConfiguracionTts({
    this.velocidad = 1.0,
    this.tono = 1.0,
    this.volumen = 1.0,
    this.idioma = 'es-ES',
  });

  ConfiguracionTts copyWith({
    double? velocidad,
    double? tono,
    double? volumen,
    String? idioma,
  }) {
    return ConfiguracionTts(
      velocidad: velocidad ?? this.velocidad,
      tono: tono ?? this.tono,
      volumen: volumen ?? this.volumen,
      idioma: idioma ?? this.idioma,
    );
  }
}
