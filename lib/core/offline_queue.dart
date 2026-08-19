import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_item.dart';

/// Cola de sincronización offline.
/// Almacena operaciones pendientes cuando no hay conexión.
/// Máximo 50 elementos. Sincronización FIFO.
class OfflineQueue {
  static const _queueKey = 'evora_offline_queue';
  static const _maxItems = 50;
  static const maxRetries = 3;
  static const _uuid = Uuid();

  /// Añadir elemento a la cola.
  static Future<bool> enqueue(SyncItemType type, Map<String, dynamic> data) async {
    final queue = await getAll();
    if (queue.length >= _maxItems) return false;

    final item = SyncItem(
      id: '${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 7)}',
      type: type,
      status: SyncItemStatus.pending,
      data: data,
      createdAt: DateTime.now().toIso8601String(),
    );

    queue.add(item);
    await _save(queue);
    return true;
  }

  /// Obtener todos los elementos de la cola.
  static Future<List<SyncItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => SyncItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Obtener número de elementos pendientes.
  static Future<int> getPendingCount() async {
    final queue = await getAll();
    return queue.where((item) => item.status == SyncItemStatus.pending).length;
  }

  /// Marcar elemento como en proceso de sincronización.
  static Future<void> markSyncing(String id) async {
    await _updateStatus(id, SyncItemStatus.syncing);
  }

  /// Eliminar elemento sincronizado correctamente.
  static Future<void> remove(String id) async {
    final queue = await getAll();
    queue.removeWhere((item) => item.id == id);
    await _save(queue);
  }

  /// Marcar elemento como fallido. Si supera maxRetries, queda en error.
  static Future<void> markFailed(String id) async {
    final queue = await getAll();
    final item = queue.firstWhere((i) => i.id == id, orElse: () => queue.first);
    if (item.id == id) {
      item.retries += 1;
      item.status =
          item.retries >= maxRetries ? SyncItemStatus.error : SyncItemStatus.pending;
    }
    await _save(queue);
  }

  /// Resetear elementos con error a pendiente.
  static Future<void> resetErrors() async {
    final queue = await getAll();
    for (final item in queue) {
      if (item.status == SyncItemStatus.error) {
        item.status = SyncItemStatus.pending;
        item.retries = 0;
      }
    }
    await _save(queue);
  }

  /// Limpiar toda la cola.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  static Future<void> _updateStatus(String id, SyncItemStatus status) async {
    final queue = await getAll();
    for (final item in queue) {
      if (item.id == id) {
        item.status = status;
        break;
      }
    }
    await _save(queue);
  }

  static Future<void> _save(List<SyncItem> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(queue.map((e) => e.toJson()).toList());
    await prefs.setString(_queueKey, json);
  }
}
