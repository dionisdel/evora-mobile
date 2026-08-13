/**
 * Servicio de autenticación.
 * Gestiona login, refresh y validación de perfil instalador.
 */
import apiClient from './api-client';
import { saveToken, removeToken } from '@utils/secure-storage';

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  expires_at: string;
  user: {
    id: number;
    nombre: string;
    perfil: string; // 'coach' | 'colaborador'
    merchan: string;
  };
}

// La API envuelve todo en { success: true, data: {...} }
interface ApiResponse<T> {
  success: boolean;
  data: T;
  timestamp: string;
}

export const authService = {
  /**
   * Autenticar usuario contra la API Evora.
   * Valida que el perfil sea coach o colaborador.
   */
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    try {
      const response = await apiClient.post<ApiResponse<LoginResponse>>('/auth/login', credentials);
      const data = response.data.data; // Desempaquetar { success, data: {...} }

      if (data.user.perfil !== 'coach' && data.user.perfil !== 'colaborador') {
        throw new Error('PERFIL_NO_AUTORIZADO');
      }

      await saveToken(data.token);
      return data;
    } catch (err: unknown) {
      // Distinguir errores HTTP del backend
      if (err && typeof err === 'object' && 'response' in err) {
        const axiosErr = err as { response?: { status: number; data?: { error?: { message?: string } } } };
        if (axiosErr.response?.status === 403) {
          const msg = axiosErr.response.data?.error?.message || '';
          if (msg.includes('deshabilitada')) throw new Error('CUENTA_BLOQUEADA');
          throw new Error('PERFIL_NO_AUTORIZADO');
        }
        if (axiosErr.response?.status === 429) {
          throw new Error('DEMASIADOS_INTENTOS');
        }
      }
      throw err;
    }
  },

  /**
   * Renovar token sin re-login.
   */
  async refreshToken(): Promise<string> {
    const response = await apiClient.post<ApiResponse<{ token: string; expires_at: string }>>('/auth/refresh');
    const data = response.data.data;
    await saveToken(data.token);
    return data.token;
  },

  /**
   * Cerrar sesión y eliminar token del dispositivo.
   */
  async logout(): Promise<void> {
    await removeToken();
  },
};
