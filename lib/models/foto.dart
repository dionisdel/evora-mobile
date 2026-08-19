/// Modelo de foto / adjunto (peticiones_adjuntos).
class Foto {
  final int id;
  final int peticionId;
  final String? tipo;
  final String? nombre;
  final String? mimeType;
  final bool fotoFicha;
  final String urlThumbnail;
  final String urlFull;
  final String fecha;

  const Foto({
    required this.id,
    required this.peticionId,
    this.tipo,
    this.nombre,
    this.mimeType,
    required this.fotoFicha,
    required this.urlThumbnail,
    required this.urlFull,
    required this.fecha,
  });

  factory Foto.fromJson(Map<String, dynamic> json) {
    return Foto(
      id: json['id'] as int,
      peticionId: json['peticion_id'] as int,
      tipo: json['tipo'] as String?,
      nombre: json['nombre'] as String?,
      mimeType: json['mime_type'] as String?,
      fotoFicha: json['foto_ficha'] as bool? ?? false,
      urlThumbnail: json['url_thumbnail'] as String? ?? '',
      urlFull: json['url_full'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
    );
  }
}

/// Respuesta paginada de galería.
class GaleriaResponse {
  final List<Foto> fotos;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  const GaleriaResponse({
    required this.fotos,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory GaleriaResponse.fromJson(Map<String, dynamic> json) {
    return GaleriaResponse(
      fotos: (json['fotos'] as List<dynamic>?)
              ?.map((e) => Foto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
