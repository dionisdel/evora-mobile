/**
 * Store de autenticación (Zustand).
 * Gestiona estado de sesión del instalador.
 */
import { create } from 'zustand';
import { User } from '../types';
import { getToken, getUserData, clearAll, saveUserData } from '@utils/secure-storage';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  loginAttempts: number;
  lockedUntil: number | null; // timestamp

  // Actions
  setAuth: (user: User, token: string) => void;
  logout: () => Promise<void>;
  incrementAttempts: () => void;
  resetAttempts: () => void;
  checkStoredAuth: () => Promise<void>;
  isLocked: () => boolean;
}

const MAX_ATTEMPTS = 5;
const LOCK_DURATION_MS = 15 * 60 * 1000; // 15 minutos

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  isLoading: true,
  loginAttempts: 0,
  lockedUntil: null,

  setAuth: (user, token) => {
    saveUserData(user);
    set({ user, token, isAuthenticated: true, loginAttempts: 0, lockedUntil: null });
  },

  logout: async () => {
    await clearAll();
    set({ user: null, token: null, isAuthenticated: false });
  },

  incrementAttempts: () => {
    const attempts = get().loginAttempts + 1;
    const lockedUntil = attempts >= MAX_ATTEMPTS ? Date.now() + LOCK_DURATION_MS : null;
    set({ loginAttempts: attempts, lockedUntil });
  },

  resetAttempts: () => {
    set({ loginAttempts: 0, lockedUntil: null });
  },

  checkStoredAuth: async () => {
    const token = await getToken();
    const user = await getUserData<User>();
    if (token && user) {
      set({ user, token, isAuthenticated: true, isLoading: false });
    } else {
      set({ isLoading: false });
    }
  },

  isLocked: () => {
    const { lockedUntil } = get();
    if (!lockedUntil) return false;
    if (Date.now() >= lockedUntil) {
      set({ loginAttempts: 0, lockedUntil: null });
      return false;
    }
    return true;
  },
}));
