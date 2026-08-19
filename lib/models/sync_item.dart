/// Elemento de la cola de sincronización offline.
enum SyncItemType { fichaVisita, foto, cerrarActividad }

enum SyncItemStatus { pending, syncing, error }

class SyncItem {
  final String id;
  final SyncItemType type;
  SyncItemStatus status;
  final Map<String, dynamic> data;
  final String createdAt;
  int retries;

  SyncItem({
    required this.id,
    required this.type,
    required this.status,
    required this.data,
    required this.createdAt,
    this.retries = 0,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      status: _parseStatus(json['status'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      createdAt: json['created_at'] as String,
      retries: json['retries'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'data': data,
        'created_at': createdAt,
        'retries': retries,
      };

  static SyncItemType _parseType(String type) {
    switch (type) {
      case 'fichaVisita':
      case 'ficha_visita':
        return SyncItemType.fichaVisita;
      case 'foto':
        return SyncItemType.foto;
      case 'cerrarActividad':
      case 'cerrar_actividad':
        return SyncItemType.cerrarActividad;
      default:
        return SyncItemType.fichaVisita;
    }
  }

  static SyncItemStatus _parseStatus(String status) {
    switch (status) {
      case 'syncing':
        return SyncItemStatus.syncing;
      case 'error':
        return SyncItemStatus.error;
      default:
        return SyncItemStatus.pending;
    }
  }
}
