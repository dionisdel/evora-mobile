import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/offline_queue.dart';
import '../models/sync_item.dart';
import '../services/cuestionario_service.dart';
import '../services/galeria_service.dart';
import '../services/visita_service.dart';

/// Estado de sincronización.
class SyncState {
  final int pendingCount;
  final bool isSyncing;
  final bool hasErrors;

  const SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.hasErrors = false,
  });

  SyncState copyWith({int? pendingCount, bool? isSyncing, bool? hasErrors}) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      hasErrors: hasErrors ?? this.hasErrors,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  StreamSubscription? _connectivitySub;
  Timer? _syncTimer;
  bool _isSyncing = false;

  SyncNotifier() : super(const SyncState()) {
    refreshCount();
    _listenConnectivity();
  }

  /// Escuchar cambios de conectividad.
  void _listenConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      if (connected && !_isSyncing) {
        _syncTimer?.cancel();
        // Esperar 30 segundos tras recuperar conexión
        _syncTimer = Timer(const Duration(seconds: 30), () => syncAll());
      }
    });
  }

  /// Refrescar contador de pendientes.
  Future<void> refreshCount() async {
    final count = await OfflineQueue.getPendingCount();
    state = state.copyWith(pendingCount: count);
  }

  /// Sincronizar todos los elementos pendientes (FIFO).
  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    state = state.copyWith(isSyncing: true);

    final queue = await OfflineQueue.getAll();
    final pending = queue
        .where((item) => item.status == SyncItemStatus.pending)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (pending.isEmpty) {
      state = state.copyWith(isSyncing: false);
      _isSyncing = false;
      return;
    }

    bool hasAnyError = false;

    for (final item in pending) {
      await OfflineQueue.markSyncing(item.id);
      try {
        await _syncItem(item);
        await OfflineQueue.remove(item.id);
      } catch (_) {
        await OfflineQueue.markFailed(item.id);
        hasAnyError = true;
      }
    }

    state = state.copyWith(isSyncing: false, hasErrors: hasAnyError);
    _isSyncing = false;
    await refreshCount();
  }

  /// Reintentar elementos con error.
  Future<void> retryFailed() async {
    await OfflineQueue.resetErrors();
    await refreshCount();
    syncAll();
  }

  /// Sincronizar un elemento individual según su tipo.
  Future<void> _syncItem(SyncItem item) async {
    final data = item.data;

    switch (item.type) {
      case SyncItemType.fichaVisita:
        final peticionId = data['peticion_id'] as int;
        final fichaData = Map<String, dynamic>.from(data['ficha_data'] as Map);
        final validar = data['validar'] as bool? ?? false;
        await CuestionarioService.guardarFicha(
          peticionId,
          {...fichaData, 'validar': validar},
        );
        break;
      case SyncItemType.foto:
        final peticionId = data['peticion_id'] as int;
        final imageUri = data['image_uri'] as String;
        final tipo = data['tipo'] as String? ?? 'foto_visita';
        await GaleriaService.subir(peticionId, imageUri, tipo: tipo);
        break;
      case SyncItemType.cerrarActividad:
        final peticionId = data['peticion_id'] as int;
        await VisitaService.cerrar(peticionId);
        break;
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier();
});
