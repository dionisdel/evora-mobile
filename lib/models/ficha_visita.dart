/// Respuesta de la API al obtener una ficha.
class FichaResponse {
  final Map<String, dynamic> ficha;
  final bool exists;
  final String? tipoInstalacion;
  final bool isDynamic;
  final Map<String, dynamic>? cuestionario;
  final Map<String, dynamic>? respuestas;

  const FichaResponse({
    required this.ficha,
    required this.exists,
    this.tipoInstalacion,
    this.isDynamic = false,
    this.cuestionario,
    this.respuestas,
  });

  factory FichaResponse.fromJson(Map<String, dynamic> json) {
    final legacy = json['legacy'];
    final isDynamic = legacy == false && json['cuestionario'] != null;

    // respuestas puede ser Map (con datos) o List vacía (sin datos)
    Map<String, dynamic>? respuestas;
    if (isDynamic && json['respuestas'] != null) {
      if (json['respuestas'] is Map) {
        respuestas = json['respuestas'] as Map<String, dynamic>;
      } else {
        respuestas = {}; // Array vacío → mapa vacío
      }
    }

    return FichaResponse(
      ficha: json['ficha'] as Map<String, dynamic>? ?? {},
      exists: json['exists'] as bool? ?? false,
      tipoInstalacion: json['tipo_instalacion'] as String?,
      isDynamic: isDynamic,
      cuestionario: isDynamic ? json['cuestionario'] as Map<String, dynamic>? : null,
      respuestas: respuestas,
    );
  }
}
