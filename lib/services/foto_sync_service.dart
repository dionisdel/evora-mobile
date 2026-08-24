import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

/// Servicio de sincronización de fotos offline-first.
/// 
/// Flujo:
/// 1. La foto se guarda localmente al capturar
/// 2. Se intenta subir inmediatamente al servidor
/// 3. Si falla (sin conexión), queda en cola
/// 4. Un timer reintenta cada 5 minutos
/// 5. Al abrir la app, se reintentan todas las pendientes
class FotoSyncService {
  static FotoSyncService? _instance;
  static FotoSyncService get instance => _instance ??= FotoSyncService._();

  FotoSyncService._();

  Timer? _retryTimer;
  bool _isSyncing = false;
  static const _queueKey = 'evora_foto_queue';
  static const _retryInterval = Duration(minutes: 5);

  /// Iniciar el servicio (llamar al abrir la app).
  void init() {
    _startRetryTimer();
    // Intentar sincronizar pendientes al iniciar
    syncPendientes();
  }

  /// Detener el servicio.
  void dispose() {
    _retryTimer?.cancel();
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(_retryInterval, (_) => syncPendientes());
  }

  /// Guardar foto localmente y encolar para subida.
  /// Retorna el path local de la foto.
  Future<String> guardarYEncolar({
    required String imagePath,
    required int peticionId,
    required String tipo,
    required String nombre,
  }) async {
    // Copiar la foto a storage permanente de la app
    final appDir = await getApplicationDocumentsDirectory();
    final fotosDir = Directory('${appDir.path}/fotos_pendientes');
    if (!await fotosDir.exists()) await fotosDir.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = imagePath.split('.').last;
    final localName = 'foto_${peticionId}_${tipo}_$timestamp.$ext';
    final destPath = '${fotosDir.path}/$localName';

    await File(imagePath).copy(destPath);

    // Añadir a la cola de pendientes
    final item = {
      'local_path': destPath,
      'peticion_id': peticionId,
      'tipo': tipo,
      'nombre': nombre,
      'created_at': DateTime.now().toIso8601String(),
      'intentos': 0,
    };
    await _addToQueue(item);

    // Intentar subir inmediatamente (no bloquea)
    _tryUploadSingle(item);

    return destPath;
  }

  /// Sincronizar todas las fotos pendientes.
  Future<void> syncPendientes() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = await _getQueue();
      if (queue.isEmpty) return;

      debugPrint('[FotoSync] ${queue.length} fotos pendientes, intentando...');

      final completadas = <int>[];
      for (var i = 0; i < queue.length; i++) {
        final item = queue[i];
        final success = await _tryUploadSingle(item);
        if (success) {
          completadas.add(i);
          // Eliminar archivo local
          try {
            final file = File(item['local_path'] as String);
            if (await file.exists()) await file.delete();
          } catch (_) {}
        } else {
          // Incrementar intentos
          item['intentos'] = (item['intentos'] as int? ?? 0) + 1;
        }
      }

      // Quitar las completadas de la cola
      if (completadas.isNotEmpty) {
        final remaining = <Map<String, dynamic>>[];
        for (var i = 0; i < queue.length; i++) {
          if (!completadas.contains(i)) remaining.add(queue[i]);
        }
        await _saveQueue(remaining);
        debugPrint('[FotoSync] ${completadas.length} subidas OK, ${remaining.length} pendientes');
      }
    } catch (e) {
      debugPrint('[FotoSync] Error en sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Intentar subir una foto individual.
  Future<bool> _tryUploadSingle(Map<String, dynamic> item) async {
    try {
      final localPath = item['local_path'] as String;
      final file = File(localPath);
      if (!await file.exists()) return true; // Si no existe, marcar como hecha

      final bytes = await file.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      await apiClient.post('/galeria/upload-base64', data: {
        'peticion_id': item['peticion_id'],
        'tipo': item['tipo'],
        'foto_base64': base64Str,
        'nombre': item['nombre'],
      });

      debugPrint('[FotoSync] Foto subida: ${item['nombre']}');
      return true;
    } catch (e) {
      debugPrint('[FotoSync] Fallo subida ${item['nombre']}: $e');
      return false;
    }
  }

  /// Obtener número de fotos pendientes.
  Future<int> getPendientesCount() async {
    final queue = await _getQueue();
    return queue.length;
  }

  // ─── Persistencia de la cola ───────────────────────────────────────

  Future<List<Map<String, dynamic>>> _getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_queueKey);
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> _addToQueue(Map<String, dynamic> item) async {
    final queue = await _getQueue();
    queue.add(item);
    await _saveQueue(queue);
  }
}
