/// Respuesta de la API al obtener una ficha.
class FichaResponse {
  final Map<String, dynamic> ficha;
  final bool exists;
  final String? tipoInstalacion;

  const FichaResponse({
    required this.ficha,
    required this.exists,
    this.tipoInstalacion,
  });

  factory FichaResponse.fromJson(Map<String, dynamic> json) {
    return FichaResponse(
      ficha: json['ficha'] as Map<String, dynamic>? ?? {},
      exists: json['exists'] as bool? ?? false,
      tipoInstalacion: json['tipo_instalacion'] as String?,
    );
  }
}
