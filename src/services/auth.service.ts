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
    perfil: string;
  };
}

export const authService = {
  /**
   * Autenticar usuario contra la API Evora.
   * Valida que el perfil sea "instalador".
   */
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await apiClient.post<LoginResponse>('/auth/login', credentials);
    const data = response.data;

    if (data.user.perfil !== 'instalador') {
      throw new Error('PERFIL_NO_AUTORIZADO');
    }

    await saveToken(data.token);
    return data;
  },

  /**
   * Renovar token sin re-login.
   */
  async refreshToken(): Promise<string> {
    const response = await apiClient.post<{ token: string; expires_at: string }>('/auth/refresh');
    await saveToken(response.data.token);
    return response.data.token;
  },

  /**
   * Cerrar sesión y eliminar token del dispositivo.
   */
  async logout(): Promise<void> {
    await removeToken();
  },
};
