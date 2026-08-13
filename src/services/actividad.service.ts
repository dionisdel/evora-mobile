/**
 * Servicio de documentos de actividad.
 * Listar y descargar documentos (actividades + documentación usuario).
 */
import apiClient from './api-client';
import { Documento } from '../types';

export interface DocumentoResponse extends Documento {
  fuente: 'actividad' | 'documentacion';
  categoria: string;
  descripcion: string;
}

export const actividadService = {
  /**
   * Listar documentos de actividad + documentación del usuario.
   */
  async listar(): Promise<DocumentoResponse[]> {
    const response = await apiClient.get<{ data: DocumentoResponse[] }>('/documentos/list');
    return response.data.data;
  },

  /**
   * Obtener URL completa de descarga de un documento.
   */
  getDownloadUrl(documentoId: number, fuente: string = 'actividad'): string {
    const base = apiClient.defaults.baseURL || '';
    return `${base}/documentos/download?fuente=${fuente}&id=${documentoId}`;
  },
};
