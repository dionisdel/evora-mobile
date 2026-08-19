import '../core/api_client.dart';
import '../models/documento.dart';

/// Servicio de documentos de actividad.
class ActividadService {
  /// Listar documentos de actividad + documentación del usuario.
  static Future<List<Documento>> listar() async {
    final response = await apiClient.get('/documentos/list');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => Documento.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Obtener URL completa de descarga de un documento.
  static String getDownloadUrl(int documentoId, {String fuente = 'actividad'}) {
    return '$apiBaseUrl/documentos/download?fuente=$fuente&id=$documentoId';
  }
}
