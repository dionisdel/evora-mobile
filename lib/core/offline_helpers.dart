import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../models/sync_item.dart';
import 'offline_queue.dart';

/// Resultado de una operación con fallback offline.
class OfflineResult {
  final bool executed;
  final bool queued;

  const OfflineResult({required this.executed, required this.queued});
}

/// Verificar si hay conexión a internet.
Future<bool> isOnline() async {
  final results = await Connectivity().checkConnectivity();
  return results.any((r) => r != ConnectivityResult.none);
}

/// Ejecutar operación con fallback offline.
/// Si la operación falla por falta de conexión, la encola.
Future<OfflineResult> executeWithOfflineFallback({
  required Future<void> Function() operation,
  required SyncItemType queueType,
  required Map<String, dynamic> queueData,
}) async {
  final online = await isOnline();

  if (!online) {
    final queued = await OfflineQueue.enqueue(queueType, queueData);
    return OfflineResult(executed: false, queued: queued);
  }

  try {
    await operation();
    return const OfflineResult(executed: true, queued: false);
  } catch (error) {
    if (_isNetworkError(error)) {
      final queued = await OfflineQueue.enqueue(queueType, queueData);
      return OfflineResult(executed: false, queued: queued);
    }
    rethrow;
  }
}

/// Determinar si un error es de red (no de lógica/validación).
bool _isNetworkError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return false;
      default:
        return error.response == null;
    }
  }
  return false;
}
