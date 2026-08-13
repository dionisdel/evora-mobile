/**
 * Cola de sincronización offline.
 * Almacena operaciones pendientes cuando no hay conexión.
 * Máximo 50 elementos. Sincronización FIFO.
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { SyncItem, SyncItemType } from '../types';

const QUEUE_KEY = 'evora_offline_queue';
const MAX_ITEMS = 50;
const MAX_RETRIES = 3;

export const offlineQueue = {
  /**
   * Añadir elemento a la cola.
   */
  async enqueue(type: SyncItemType, data: unknown): Promise<boolean> {
    const queue = await this.getAll();

    if (queue.length >= MAX_ITEMS) {
      return false; // Cola llena
    }

    const item: SyncItem = {
      id: `${Date.now()}-${Math.random().toString(36).substring(2, 9)}`,
      type,
      status: 'pending',
      data,
      created_at: new Date().toISOString(),
      retries: 0,
    };

    queue.push(item);
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
    return true;
  },

  /**
   * Obtener todos los elementos de la cola.
   */
  async getAll(): Promise<SyncItem[]> {
    const raw = await AsyncStorage.getItem(QUEUE_KEY);
    return raw ? JSON.parse(raw) : [];
  },

  /**
   * Obtener número de elementos pendientes.
   */
  async getPendingCount(): Promise<number> {
    const queue = await this.getAll();
    return queue.filter((item) => item.status === 'pending').length;
  },

  /**
   * Marcar elemento como en proceso de sincronización.
   */
  async markSyncing(id: string): Promise<void> {
    await this.updateStatus(id, 'syncing');
  },

  /**
   * Eliminar elemento sincronizado correctamente.
   */
  async remove(id: string): Promise<void> {
    const queue = await this.getAll();
    const filtered = queue.filter((item) => item.id !== id);
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(filtered));
  },

  /**
   * Marcar elemento como fallido. Si supera MAX_RETRIES, queda en error.
   */
  async markFailed(id: string): Promise<void> {
    const queue = await this.getAll();
    const item = queue.find((i) => i.id === id);
    if (item) {
      item.retries += 1;
      item.status = item.retries >= MAX_RETRIES ? 'error' : 'pending';
    }
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
  },

  /**
   * Limpiar toda la cola.
   */
  async clear(): Promise<void> {
    await AsyncStorage.removeItem(QUEUE_KEY);
  },

  // --- Helpers privados ---

  async updateStatus(id: string, status: SyncItem['status']): Promise<void> {
    const queue = await this.getAll();
    const item = queue.find((i) => i.id === id);
    if (item) {
      item.status = status;
    }
    await AsyncStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
  },
};
