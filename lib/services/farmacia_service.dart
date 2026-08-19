import '../core/api_client.dart';
import '../models/farmacia.dart';

/// Parámetros de búsqueda de farmacias.
class BusquedaParams {
  final String? externalId;
  final String? nombre;
  final String? direccion;
  final String? poblacion;
  final String? provincia;

  const BusquedaParams({
    this.externalId,
    this.nombre,
    this.direccion,
    this.poblacion,
    this.provincia,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (externalId?.isNotEmpty == true) params['external_id'] = externalId;
    if (nombre?.isNotEmpty == true) params['nombre'] = nombre;
    if (direccion?.isNotEmpty == true) params['direccion'] = direccion;
    if (poblacion?.isNotEmpty == true) params['poblacion'] = poblacion;
    if (provincia?.isNotEmpty == true) params['provincia'] = provincia;
    return params;
  }

  bool get isEmpty => toQueryParams().isEmpty;
}

/// Servicio de farmacias (peticiones_visibilidad).
class FarmaciaService {
  /// Buscar farmacias con filtros de texto.
  /// Solo devuelve las asignadas al usuario autenticado.
  static Future<List<Farmacia>> buscar(BusquedaParams params) async {
    final response = await apiClient.get(
      '/farmacias/list',
      queryParameters: params.toQueryParams(),
    );
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => Farmacia.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Obtener detalle de una farmacia.
  static Future<FarmaciaDetalle> getDetalle(int peticionId) async {
    final response = await apiClient.get(
      '/farmacias/detail',
      queryParameters: {'id': peticionId},
    );
    return FarmaciaDetalle.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
