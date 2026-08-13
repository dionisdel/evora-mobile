/**
 * Wrapper para almacenamiento seguro de credenciales.
 * - Nativo: Keychain (iOS) / EncryptedSharedPreferences (Android)
 * - Web: localStorage (fallback para desarrollo)
 */
import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

const TOKEN_KEY = 'evora_auth_token';
const USER_KEY = 'evora_user_data';

// En web usamos localStorage como fallback (solo para desarrollo)
const isWeb = Platform.OS === 'web';

export async function saveToken(token: string): Promise<void> {
  if (isWeb) {
    localStorage.setItem(TOKEN_KEY, token);
    return;
  }
  await SecureStore.setItemAsync(TOKEN_KEY, token);
}

export async function getToken(): Promise<string | null> {
  if (isWeb) {
    return localStorage.getItem(TOKEN_KEY);
  }
  return await SecureStore.getItemAsync(TOKEN_KEY);
}

export async function removeToken(): Promise<void> {
  if (isWeb) {
    localStorage.removeItem(TOKEN_KEY);
    return;
  }
  await SecureStore.deleteItemAsync(TOKEN_KEY);
}

export async function saveUserData(user: object): Promise<void> {
  if (isWeb) {
    localStorage.setItem(USER_KEY, JSON.stringify(user));
    return;
  }
  await SecureStore.setItemAsync(USER_KEY, JSON.stringify(user));
}

export async function getUserData<T>(): Promise<T | null> {
  if (isWeb) {
    const data = localStorage.getItem(USER_KEY);
    return data ? JSON.parse(data) : null;
  }
  const data = await SecureStore.getItemAsync(USER_KEY);
  return data ? JSON.parse(data) : null;
}

export async function clearAll(): Promise<void> {
  if (isWeb) {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    return;
  }
  await SecureStore.deleteItemAsync(TOKEN_KEY);
  await SecureStore.deleteItemAsync(USER_KEY);
}
