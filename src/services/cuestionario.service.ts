/**
 * Servicio de cuestionarios (peticiones_fichas_visita).
 * Obtener ficha de visita y enviar respuestas.
 * 
 * La API retorna: { ficha: {...}, exists: bool, tipo_instalacion: string }
 */
import apiClient from './api-client';
import { FichaVisita } from '../types';

export interface FichaResponse {
  ficha: Partial<FichaVisita> & Record<string, unknown>;
  exists: boolean;
  tipo_instalacion: string | null;
}

export const cuestionarioService = {
  /**
   * Obtener ficha de visita de una petición.
   * Si no existe, retorna datos iniciales pre-rellenados.
   */
  async getFicha(peticionId: number): Promise<FichaResponse> {
    const response = await apiClient.get<{ data: FichaResponse }>(
      '/farmacias/cuestionario-get',
      { params: { peticion_id: peticionId } }
    );
    return response.data.data;
  },

  /**
   * Guardar/actualizar ficha de visita.
   * Con validar=true se valida y cierra la ficha.
   */
  async guardarFicha(peticionId: number, datos: Record<string, unknown>): Promise<void> {
    await apiClient.post('/farmacias/cuestionario-post', {
      peticion_id: peticionId,
      ...datos,
    });
  },
};
