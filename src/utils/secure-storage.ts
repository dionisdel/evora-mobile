/**
 * Wrapper para almacenamiento seguro de credenciales.
 * Usa Keychain en iOS y EncryptedSharedPreferences en Android.
 */
import * as SecureStore from 'expo-secure-store';

const TOKEN_KEY = 'evora_auth_token';
const USER_KEY = 'evora_user_data';

export async function saveToken(token: string): Promise<void> {
  await SecureStore.setItemAsync(TOKEN_KEY, token);
}

export async function getToken(): Promise<string | null> {
  return await SecureStore.getItemAsync(TOKEN_KEY);
}

export async function removeToken(): Promise<void> {
  await SecureStore.deleteItemAsync(TOKEN_KEY);
}

export async function saveUserData(user: object): Promise<void> {
  await SecureStore.setItemAsync(USER_KEY, JSON.stringify(user));
}

export async function getUserData<T>(): Promise<T | null> {
  const data = await SecureStore.getItemAsync(USER_KEY);
  return data ? JSON.parse(data) : null;
}

export async function clearAll(): Promise<void> {
  await SecureStore.deleteItemAsync(TOKEN_KEY);
  await SecureStore.deleteItemAsync(USER_KEY);
}
