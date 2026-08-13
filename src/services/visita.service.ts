/**
 * Servicio de visitas.
 * Registrar apertura y cierre de visitas.
 */
import apiClient from './api-client';
import { Visita } from '../types';

export interface AbrirVisitaRequest {
  farmacia_id: number;
  latitud?: number;
  longitud?: number;
}

export interface CerrarVisitaRequest {
  visita_id: number;
}

export const visitaService = {
  /**
   * Registrar apertura de visita con fecha/hora y GPS opcional.
   */
  async abrir(data: AbrirVisitaRequest): Promise<Visita> {
    const response = await apiClient.post<{ data: Visita }>('/visitas/abrir', data);
    return response.data.data;
  },

  /**
   * Registrar cierre de visita con fecha/hora de finalización.
   */
  async cerrar(data: CerrarVisitaRequest): Promise<void> {
    await apiClient.post('/visitas/cerrar', data);
  },
};
