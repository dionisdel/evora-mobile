/**
 * Helpers para gestionar operaciones offline.
 * Los servicios usan estas funciones para encolar operaciones
 * cuando no hay conexión disponible.
 */
import NetInfo from '@react-native-community/netinfo';
import { offlineQueue } from './offline-queue';
import { SyncItemType } from '../types';

/**
 * Verificar si hay conexión a internet.
 */
export async function isOnline(): Promise<boolean> {
  const state = await NetInfo.fetch();
  return !!state.isConnected;
}

/**
 * Ejecutar operación con fallback offline.
 * Si la operación falla por falta de conexión, la encola.
 * 
 * @param operation - La función async a ejecutar
 * @param queueType - Tipo de elemento para la cola offline
 * @param queueData - Datos a encolar si falla
 * @returns true si se ejecutó online, false si se encoló
 */
export async function executeWithOfflineFallback(
  operation: () => Promise<void>,
  queueType: SyncItemType,
  queueData: Record<string, unknown>
): Promise<{ executed: boolean; queued: boolean }> {
  const online = await isOnline();

  if (!online) {
    // Sin conexión: encolar directamente
    const queued = await offlineQueue.enqueue(queueType, queueData);
    return { executed: false, queued };
  }

  try {
    await operation();
    return { executed: true, queued: false };
  } catch (error: unknown) {
    // Si el error es de red (timeout, network error), encolar
    if (isNetworkError(error)) {
      const queued = await offlineQueue.enqueue(queueType, queueData);
      return { executed: false, queued };
    }
    // Si es otro tipo de error (4xx, lógica), propagar
    throw error;
  }
}

/**
 * Determinar si un error es de red (no de lógica/validación).
 */
function isNetworkError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;

  // Axios network error
  if ('code' in error) {
    const code = (error as { code?: string }).code;
    if (code === 'ERR_NETWORK' || code === 'ECONNABORTED' || code === 'ETIMEDOUT') {
      return true;
    }
  }

  // Axios no response (server down)
  if ('response' in error && (error as { response?: unknown }).response === undefined) {
    return true;
  }

  // Error message patterns
  if ('message' in error) {
    const msg = String((error as { message: string }).message).toLowerCase();
    if (msg.includes('network') || msg.includes('timeout') || msg.includes('connection')) {
      return true;
    }
  }

  return false;
}
