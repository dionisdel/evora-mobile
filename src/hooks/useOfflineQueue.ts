/**
 * Hook para gestionar la cola offline.
 * Monitoriza conectividad y sincroniza automáticamente.
 */
import { useEffect, useCallback } from 'react';
import NetInfo from '@react-native-community/netinfo';
import { useSyncStore } from '@store/sync.store';
import { offlineQueue } from '@utils/offline-queue';
import { SyncItem } from '../types';

export function useOfflineQueue() {
  const { pendingCount, isSyncing, refreshCount, setSyncing } = useSyncStore();

  // Sincronizar elementos pendientes
  const syncAll = useCallback(async () => {
    const queue = await offlineQueue.getAll();
    const pendingItems = queue.filter((item) => item.status === 'pending');

    if (pendingItems.length === 0) return;

    setSyncing(true);

    for (const item of pendingItems) {
      await offlineQueue.markSyncing(item.id);
      try {
        await syncItem(item);
        await offlineQueue.remove(item.id);
      } catch {
        await offlineQueue.markFailed(item.id);
      }
    }

    setSyncing(false);
    await refreshCount();
  }, [refreshCount, setSyncing]);

  // Escuchar cambios de conectividad
  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state) => {
      if (state.isConnected && !isSyncing) {
        // Esperar 30 segundos antes de sincronizar
        setTimeout(() => {
          syncAll();
        }, 30000);
      }
    });

    refreshCount();
    return () => unsubscribe();
  }, [syncAll, isSyncing, refreshCount]);

  return { pendingCount, isSyncing, syncAll, refreshCount };
}

/**
 * Sincronizar un elemento individual.
 * TODO: Implementar según el tipo de elemento.
 */
async function syncItem(_item: SyncItem): Promise<void> {
  // La implementación real dependerá del tipo de item:
  // - cuestionario: cuestionarioService.enviarRespuestas(...)
  // - visita_abrir: visitaService.abrir(...)
  // - visita_cerrar: visitaService.cerrar(...)
  // - foto: galeriaService.subir(...)
  throw new Error('Not implemented - will be completed in Phase 6');
}
