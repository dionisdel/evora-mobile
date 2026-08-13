/**
 * Root Layout.
 * Gestiona la navegación raíz: login vs app autenticada.
 * Registra el callback de logout forzado para tokens expirados.
 */
import { useEffect } from 'react';
import { Slot, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { useAuthStore } from '../src/store/auth.store';
import { setOnUnauthorized } from '../src/services/api-client';

export default function RootLayout() {
  const { isAuthenticated, isLoading, checkStoredAuth, logout } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  // Verificar auth almacenada al iniciar
  useEffect(() => {
    checkStoredAuth();
  }, [checkStoredAuth]);

  // Registrar callback de logout forzado (401 en cualquier petición)
  useEffect(() => {
    setOnUnauthorized(() => {
      logout();
    });
  }, [logout]);

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

  // Splash screen mientras carga auth
  if (isLoading) {
    return (
      <View style={styles.loading}>
        <ActivityIndicator size="large" color="#3182ce" />
      </View>
    );
  }

  return (
    <>
      <StatusBar style="light" />
      <Slot />
    </>
  );
}

const styles = StyleSheet.create({
  loading: {
    flex: 1,
    backgroundColor: '#1a2332',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
