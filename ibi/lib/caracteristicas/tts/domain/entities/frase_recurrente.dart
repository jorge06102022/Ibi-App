/// Entidad que representa una frase recurrente / rápida
class FraseRecurrente {
  final String id;
  final String texto;
  final String? categoria;

  const FraseRecurrente({
    required this.id,
    required this.texto,
    this.categoria,
  });

  FraseRecurrente copyWith({
    String? id,
    String? texto,
    String? categoria,
  }) {
    return FraseRecurrente(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      categoria: categoria ?? this.categoria,
    );
  }
}
