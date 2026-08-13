/**
 * Servicio de cuestionarios (peticiones_fichas_visita).
 * Obtener ficha de visita y enviar respuestas.
 * 
 * NOTA: En Evora, el "cuestionario" es la ficha de visita (peticiones_fichas_visita).
 * No es un formulario dinámico de preguntas/respuestas — tiene campos fijos.
 */
import apiClient from './api-client';
import { FichaVisita } from '../types';

export const cuestionarioService = {
  /**
   * Obtener ficha de visita de una petición.
   */
  async getFicha(peticionId: number): Promise<FichaVisita | null> {
    const response = await apiClient.get<{ data: FichaVisita | null }>(
      '/farmacias/cuestionario-get',
      { params: { peticion_id: peticionId } }
    );
    return response.data.data;
  },

  /**
   * Enviar/guardar datos de la ficha de visita.
   */
  async guardarFicha(peticionId: number, datos: Partial<FichaVisita>): Promise<void> {
    await apiClient.post('/farmacias/cuestionario-post', {
      peticion_id: peticionId,
      ...datos,
    });
  },
};
