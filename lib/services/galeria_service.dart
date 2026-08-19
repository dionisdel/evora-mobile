import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/foto.dart';

/// Servicio de galería de fotos.
class GaleriaService {
  /// Listar fotos de una petición (paginadas).
  static Future<GaleriaResponse> listar(int peticionId, {int page = 1}) async {
    final response = await apiClient.get(
      '/galeria/list',
      queryParameters: {'peticion_id': peticionId, 'page': page},
    );
    return GaleriaResponse.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Subir foto asociada a una petición.
  static Future<int> subir(
    int peticionId,
    String filePath, {
    String tipo = 'foto_visita',
  }) async {
    final fileName = filePath.split('/').last;

    final formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(filePath, filename: fileName),
      'peticion_id': peticionId.toString(),
      'tipo': tipo,
    });

    final response = await apiClient.post(
      '/galeria/upload',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return response.data['data']['foto_id'] as int;
  }

  /// Obtener URL de thumbnail para una foto.
  static String getThumbUrl(int fotoId) {
    return '$apiBaseUrl/galeria/thumb?id=$fotoId';
  }

  /// Obtener URL completa para una foto.
  static String getFullUrl(int fotoId) {
    return '$apiBaseUrl/galeria/thumb?id=$fotoId&full=1';
  }
}
