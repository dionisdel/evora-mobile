/**
 * Root Layout.
 * Gestiona la navegación raíz: login vs app autenticada.
 */
import { useEffect } from 'react';
import { Slot, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useAuthStore } from '../src/store/auth.store';

export default function RootLayout() {
  const { isAuthenticated, isLoading, checkStoredAuth } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  // Verificar auth almacenada al iniciar
  useEffect(() => {
    checkStoredAuth();
  }, [checkStoredAuth]);

  // Redirigir según estado de autenticación
  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!isAuthenticated && inAuthGroup) {
      router.replace('/login');
    } else if (isAuthenticated && !inAuthGroup) {
      router.replace('/(auth)');
    }
  }, [isAuthenticated, isLoading, segments, router]);

  return (
    <>
      <StatusBar style="light" />
      <Slot />
    </>
  );
}
