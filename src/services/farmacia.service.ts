/**
 * Servicio de farmacias.
 * Búsqueda, detalle y listado por geolocalización.
 */
import apiClient from './api-client';
import { Farmacia, FarmaciaDetalle } from '../types';

export interface BusquedaParams {
  external_id?: string;
  nombre?: string;
  direccion?: string;
  poblacion?: string;
  provincia?: string;
  lat?: number;
  lng?: number;
  radio_km?: number;
}

export const farmaciaService = {
  /**
   * Buscar farmacias con filtros y/o geolocalización.
   */
  async buscar(params: BusquedaParams): Promise<Farmacia[]> {
    const response = await apiClient.get<{ data: Farmacia[] }>('/farmacias', { params });
    return response.data.data;
  },

  /**
   * Obtener detalle de una farmacia (incluye post-it y estado cuestionario).
   */
  async getDetalle(farmaciaId: number): Promise<FarmaciaDetalle> {
    const response = await apiClient.get<{ data: FarmaciaDetalle }>(`/farmacias/${farmaciaId}`);
    return response.data.data;
  },
};
