/// Entidad que representa la traducción de un texto a glosas/secuencia de Lengua de Señas
class SenasTraduccion {
  final String textoOriginal;
  final List<String> glosas;
  final String? urlAnimacionAvatar;
  final bool disponible;

  const SenasTraduccion({
    required this.textoOriginal,
    required this.glosas,
    this.urlAnimacionAvatar,
    this.disponible = true,
  });

  SenasTraduccion copyWith({
    String? textoOriginal,
    List<String>? glosas,
    String? urlAnimacionAvatar,
    bool? disponible,
  }) {
    return SenasTraduccion(
      textoOriginal: textoOriginal ?? this.textoOriginal,
      glosas: glosas ?? this.glosas,
      urlAnimacionAvatar: urlAnimacionAvatar ?? this.urlAnimacionAvatar,
      disponible: disponible ?? this.disponible,
    );
  }
}
