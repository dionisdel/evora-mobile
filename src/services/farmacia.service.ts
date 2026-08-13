/**
 * Servicio de farmacias (peticiones_visibilidad).
 * Búsqueda por filtros y detalle.
 * 
 * NOTA: No hay búsqueda por geolocalización porque la BD
 * no tiene coordenadas lat/lng en peticiones_visibilidad.
 */
import apiClient from './api-client';
import { Farmacia, FarmaciaDetalle } from '../types';

export interface BusquedaParams {
  external_id?: string;
  nombre?: string;
  direccion?: string;
  poblacion?: string;
  provincia?: string;
}

export const farmaciaService = {
  /**
   * Buscar farmacias con filtros de texto.
   * Solo devuelve las asignadas al usuario autenticado.
   */
  async buscar(params: BusquedaParams): Promise<Farmacia[]> {
    const response = await apiClient.get<{ data: Farmacia[] }>('/farmacias/list', { params });
    return response.data.data;
  },

  /**
   * Obtener detalle de una farmacia (incluye post-it, estado ficha, calendario).
   */
  async getDetalle(peticionId: number): Promise<FarmaciaDetalle> {
    const response = await apiClient.get<{ data: FarmaciaDetalle }>('/farmacias/detail', {
      params: { id: peticionId }
    });
    return response.data.data;
  },
};
