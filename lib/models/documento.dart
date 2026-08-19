/// Modelo de documento (actividades + documentación).
class Documento {
  final int id;
  final String nombre;
  final String tipo; // 'pdf', 'doc', 'imagen', 'video'
  final String? formato;
  final String urlDownload;
  final String fecha;
  final String fuente; // 'actividad' | 'documentacion'
  final String categoria;
  final String descripcion;

  const Documento({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.formato,
    required this.urlDownload,
    required this.fecha,
    required this.fuente,
    required this.categoria,
    required this.descripcion,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'doc',
      formato: json['formato'] as String?,
      urlDownload: json['url_download'] as String? ?? '',
      fecha: json['fecha'] as String? ?? '',
      fuente: json['fuente'] as String? ?? 'actividad',
      categoria: json['categoria'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
    );
  }
}
