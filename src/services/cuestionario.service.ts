/**
 * Servicio de cuestionarios.
 * Obtener estructura, enviar respuestas.
 */
import apiClient from './api-client';
import { Cuestionario, Respuesta } from '../types';

export const cuestionarioService = {
  /**
   * Obtener cuestionario de una farmacia (estructura + respuestas previas).
   */
  async getCuestionario(farmaciaId: number): Promise<Cuestionario> {
    const response = await apiClient.get<{ data: Cuestionario }>(
      `/farmacias/${farmaciaId}/cuestionario`
    );
    return response.data.data;
  },

  /**
   * Enviar respuestas del cuestionario y finalizar.
   */
  async enviarRespuestas(farmaciaId: number, respuestas: Respuesta[]): Promise<void> {
    await apiClient.post(`/farmacias/${farmaciaId}/cuestionario`, { respuestas });
  },
};
