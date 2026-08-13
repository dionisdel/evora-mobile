/**
 * Hook para gestionar la cola offline.
 * Monitoriza conectividad y sincroniza automáticamente al recuperar conexión.
 * 
 * Comportamiento:
 * - Escucha cambios de red (NetInfo)
 * - Al recuperar conexión, espera 30s y sincroniza en orden FIFO
 * - 3 reintentos por elemento, luego marca como error
 * - Máximo 50 elementos en cola
 */
import { useEffect, useCallback, useRef } from 'react';
import NetInfo from '@react-native-community/netinfo';
import { useSyncStore } from '@store/sync.store';
import { offlineQueue } from '@utils/offline-queue';
import { SyncItem } from '../types';
import { cuestionarioService } from '@services/cuestionario.service';
import { visitaService } from '@services/visita.service';
import { galeriaService } from '@services/galeria.service';

export function useOfflineQueue() {
  const { pendingCount, isSyncing, refreshCount, setSyncing, setHasErrors } = useSyncStore();
  const syncTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isSyncingRef = useRef(false);

  // Sincronizar todos los elementos pendientes (FIFO)
  const syncAll = useCallback(async () => {
    if (isSyncingRef.current) return;
    isSyncingRef.current = true;
    setSyncing(true);

    const queue = await offlineQueue.getAll();
    const pendingItems = queue
      .filter((item) => item.status === 'pending')
      .sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime()); // FIFO

    if (pendingItems.length === 0) {
      setSyncing(false);
      isSyncingRef.current = false;
      return;
    }

    let hasAnyError = false;

    for (const item of pendingItems) {
      await offlineQueue.markSyncing(item.id);
      try {
        await syncItem(item);
        await offlineQueue.remove(item.id);
      } catch {
        await offlineQueue.markFailed(item.id);
        hasAnyError = true;
      }
    }

    setHasErrors(hasAnyError);
    setSyncing(false);
    isSyncingRef.current = false;
    await refreshCount();
  }, [refreshCount, setSyncing, setHasErrors]);

  // Escuchar cambios de conectividad
  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state) => {
      if (state.isConnected && !isSyncingRef.current) {
        // Cancelar timeout anterior si existe
        if (syncTimeoutRef.current) {
          clearTimeout(syncTimeoutRef.current);
        }
        // Esperar 30 segundos tras recuperar conexión antes de sincronizar
        syncTimeoutRef.current = setTimeout(() => {
          syncAll();
        }, 30000);
      }
    });

    // Cargar count al montar
    refreshCount();

    return () => {
      unsubscribe();
      if (syncTimeoutRef.current) clearTimeout(syncTimeoutRef.current);
    };
  }, [syncAll, refreshCount]);

  // Sincronizar manualmente (para reintentar errores)
  const retryFailed = useCallback(async () => {
    const queue = await offlineQueue.getAll();
    const errorItems = queue.filter((item) => item.status === 'error');
    // Reset retries y poner en pending
    for (const item of errorItems) {
      await offlineQueue.updateStatus(item.id, 'pending');
    }
    await refreshCount();
    syncAll();
  }, [syncAll, refreshCount]);

  return { pendingCount, isSyncing, syncAll, retryFailed, refreshCount };
}

/**
 * Sincronizar un elemento individual según su tipo.
 */
async function syncItem(item: SyncItem): Promise<void> {
  const data = item.data as Record<string, unknown>;

  switch (item.type) {
    case 'ficha_visita': {
      const peticionId = data.peticion_id as number;
      const fichaData = data.ficha_data as Record<string, unknown>;
      const validar = data.validar as boolean;
      await cuestionarioService.guardarFicha(peticionId, { ...fichaData, validar });
      break;
    }

    case 'foto': {
      const peticionId = data.peticion_id as number;
      const imageUri = data.image_uri as string;
      const tipo = (data.tipo as string) || 'foto_visita';
      await galeriaService.subir(peticionId, imageUri, tipo);
      break;
    }

    case 'cerrar_actividad': {
      const peticionId = data.peticion_id as number;
      await visitaService.cerrar(peticionId);
      break;
    }

    default:
      throw new Error(`Tipo de sync no soportado: ${item.type}`);
  }
}
