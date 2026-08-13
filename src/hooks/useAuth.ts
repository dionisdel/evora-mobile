/**
 * Hook de autenticación.
 * Encapsula la lógica de login/logout con manejo de intentos.
 */
import { useState } from 'react';
import { useAuthStore } from '@store/auth.store';
import { authService, LoginRequest } from '@services/auth.service';

export function useAuth() {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { setAuth, logout, incrementAttempts, resetAttempts, isLocked } = useAuthStore();

  const login = async (credentials: LoginRequest) => {
    setError(null);

    if (isLocked()) {
      setError('Demasiados intentos fallidos. Espera 15 minutos.');
      return false;
    }

    setIsLoading(true);
    try {
      const response = await authService.login(credentials);
      setAuth(response.user as { id: number; nombre: string; perfil: 'instalador' }, response.token);
      resetAttempts();
      return true;
    } catch (err: unknown) {
      incrementAttempts();
      if (err instanceof Error && err.message === 'PERFIL_NO_AUTORIZADO') {
        setError('Acceso restringido a instaladores.');
      } else {
        setError('Credenciales incorrectas. Inténtalo de nuevo.');
      }
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const handleLogout = async () => {
    await logout();
  };

  return { login, logout: handleLogout, isLoading, error };
}
