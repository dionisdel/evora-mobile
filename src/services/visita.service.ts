/**
 * Servicio de visitas.
 * En Evora, las visitas se gestionan con peticiones_calendario + peticiones_fichas_visita.
 * "Abrir visita" = crear/iniciar la ficha de visita.
 * "Cerrar visita" = cerrar actividad (api/peticiones-cerrar-actividad.php).
 */
import apiClient from './api-client';

export interface AbrirVisitaRequest {
  peticion_id: number;
}

export interface CerrarVisitaResponse {
  peticion_id: number;
  fecha_visita_realizada: string;
}

export const visitaService = {
  /**
   * Registrar inicio de visita (crear ficha si no existe).
   */
  async abrir(data: AbrirVisitaRequest): Promise<{ ficha_id: number }> {
    const response = await apiClient.post<{ data: { ficha_id: number } }>(
      '/visitas/abrir', data
    );
    return response.data.data;
  },

  /**
   * Registrar cierre de visita (cerrar actividad).
   */
  async cerrar(peticionId: number): Promise<CerrarVisitaResponse> {
    const response = await apiClient.post<{ data: CerrarVisitaResponse }>(
      '/visitas/cerrar', { peticion_id: peticionId }
    );
    return response.data.data;
  },
};
