import '../core/api_client.dart';
import '../models/ficha_visita.dart';

/// Servicio de cuestionarios (peticiones_fichas_visita).
class CuestionarioService {
  /// Obtener ficha de visita de una petición.
  static Future<FichaResponse> getFicha(int peticionId) async {
    final response = await apiClient.get(
      '/farmacias/cuestionario-get',
      queryParameters: {'peticion_id': peticionId},
    );
    return FichaResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Guardar/actualizar ficha de visita.
  /// Con validar=true se valida y cierra la ficha.
  static Future<void> guardarFicha(
    int peticionId,
    Map<String, dynamic> datos,
  ) async {
    await apiClient.post('/farmacias/cuestionario-post', data: {
      'peticion_id': peticionId,
      ...datos,
    });
  }
}
