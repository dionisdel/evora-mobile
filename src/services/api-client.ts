/**
 * Cliente HTTP configurado para comunicación con la API Evora.
 * Incluye interceptors para autenticación, reintentos y manejo de errores.
 */
import axios, { AxiosError, InternalAxiosRequestConfig } from 'axios';
import { getToken, clearAll } from '@utils/secure-storage';

const API_BASE_URL = __DEV__
  ? 'http://localhost:8003/api/v2/mobile'
  : 'https://e-plataforma.com/api/v2/mobile';

const TIMEOUT_MS = 15000; // 15 segundos
const MAX_RETRIES = 2;
const RETRY_DELAY_MS = 2000;

// Callback para logout forzado (registrado por el store al iniciar)
let onUnauthorized: (() => void) | null = null;
export function setOnUnauthorized(cb: () => void) {
  onUnauthorized = cb;
}

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: TIMEOUT_MS,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Interceptor: Añadir token Bearer a todas las peticiones
apiClient.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const token = await getToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor: Manejo de errores y reintentos
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const config = error.config as InternalAxiosRequestConfig & { _retryCount?: number };

    // 401: Sesión expirada → limpiar todo y forzar logout
    if (error.response?.status === 401) {
      await clearAll();
      if (onUnauthorized) onUnauthorized();
      return Promise.reject(error);
    }

    // 429: Rate limit → esperar y reintentar
    if (error.response?.status === 429) {
      const retryAfter = Number(error.response.headers['retry-after']) || 5;
      await delay(retryAfter * 1000);
      return apiClient(config);
    }

    // 5xx: Error de servidor → reintentar
    if (error.response && error.response.status >= 500) {
      config._retryCount = (config._retryCount || 0) + 1;
      if (config._retryCount <= MAX_RETRIES) {
        await delay(RETRY_DELAY_MS);
        return apiClient(config);
      }
    }

    return Promise.reject(error);
  }
);

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export default apiClient;
