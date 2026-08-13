/**
 * Servicio de documentos de actividad.
 * Listar y descargar documentos asociados a farmacias.
 */
import apiClient from './api-client';
import { Documento } from '../types';

export const actividadService = {
  /**
   * Listar documentos de actividad de una farmacia.
   */
  async listar(farmaciaId: number): Promise<Documento[]> {
    const response = await apiClient.get<{ data: Documento[] }>(
      `/farmacias/${farmaciaId}/documentos`
    );
    return response.data.data;
  },

  /**
   * Obtener URL de descarga de un documento.
   */
  getDownloadUrl(documentoId: number): string {
    return `${apiClient.defaults.baseURL}/documentos/${documentoId}/download`;
  },
};
