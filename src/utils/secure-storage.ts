/**
 * Wrapper para almacenamiento seguro de credenciales.
 * - Nativo: Keychain (iOS) / EncryptedSharedPreferences (Android)
 * - Web: localStorage (fallback para desarrollo)
 */
import { Platform } from 'react-native';

const TOKEN_KEY = 'evora_auth_token';
const USER_KEY = 'evora_user_data';

// En web usamos localStorage como fallback (solo para desarrollo)
const isWeb = Platform.OS === 'web';

async function getSecureStore() {
  if (isWeb) return null;
  return await import('expo-secure-store');
}

export async function saveToken(token: string): Promise<void> {
  if (isWeb) {
    localStorage.setItem(TOKEN_KEY, token);
    return;
  }
  const SecureStore = await getSecureStore();
  await SecureStore?.setItemAsync(TOKEN_KEY, token);
}

export async function getToken(): Promise<string | null> {
  if (isWeb) {
    return localStorage.getItem(TOKEN_KEY);
  }
  const SecureStore = await getSecureStore();
  return (await SecureStore?.getItemAsync(TOKEN_KEY)) ?? null;
}

export async function removeToken(): Promise<void> {
  if (isWeb) {
    localStorage.removeItem(TOKEN_KEY);
    return;
  }
  const SecureStore = await getSecureStore();
  await SecureStore?.deleteItemAsync(TOKEN_KEY);
}

export async function saveUserData(user: object): Promise<void> {
  if (isWeb) {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
    return;
  }
  const SecureStore = await getSecureStore();
  await SecureStore?.setItemAsync(USER_KEY, JSON.stringify(user));
}

export async function getUserData<T>(): Promise<T | null> {
  if (isWeb) {
    const data = localStorage.getItem(USER_KEY);
    return data ? JSON.parse(data) : null;
  }
  const SecureStore = await getSecureStore();
  const data = await SecureStore?.getItemAsync(USER_KEY);
  return data ? JSON.parse(data) : null;
}

export async function clearAll(): Promise<void> {
  if (isWeb) {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    return;
  }
  const SecureStore = await getSecureStore();
  await SecureStore?.deleteItemAsync(TOKEN_KEY);
  await SecureStore?.deleteItemAsync(USER_KEY);
}
