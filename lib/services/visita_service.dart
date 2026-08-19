import '../core/api_client.dart';

/// Servicio de visitas.
/// "Abrir visita" = crear/iniciar la ficha de visita.
/// "Cerrar visita" = cerrar actividad.
class VisitaService {
  /// Registrar inicio de visita (crear ficha si no existe).
  static Future<int> abrir(int peticionId) async {
    final response = await apiClient.post(
      '/visitas/abrir',
      data: {'peticion_id': peticionId},
    );
    return response.data['data']['ficha_id'] as int;
  }

  /// Registrar cierre de visita (cerrar actividad).
  static Future<void> cerrar(int peticionId) async {
    await apiClient.post(
      '/visitas/cerrar',
      data: {'peticion_id': peticionId},
    );
  }
}
