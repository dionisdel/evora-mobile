/**
 * Store de sincronización offline (Zustand).
 * Gestiona el estado de la cola de sincronización.
 */
import { create } from 'zustand';
import { offlineQueue } from '@utils/offline-queue';

interface SyncState {
  pendingCount: number;
  isSyncing: boolean;
  hasErrors: boolean;

  // Actions
  refreshCount: () => Promise<void>;
  setSyncing: (syncing: boolean) => void;
  setHasErrors: (hasErrors: boolean) => void;
}

export const useSyncStore = create<SyncState>((set) => ({
  pendingCount: 0,
  isSyncing: false,
  hasErrors: false,

  refreshCount: async () => {
    const count = await offlineQueue.getPendingCount();
    set({ pendingCount: count });
  },

  setSyncing: (syncing) => set({ isSyncing: syncing }),
  setHasErrors: (hasErrors) => set({ hasErrors }),
}));
