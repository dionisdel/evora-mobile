/**
 * Servicio de galería de fotos.
 * Listar fotos de una petición y subir nuevas.
 */
import apiClient from './api-client';
import { Foto } from '../types';

export interface GaleriaResponse {
  fotos: Foto[];
  total: number;
  page: number;
  per_page: number;
  total_pages: number;
}

export const galeriaService = {
  /**
   * Listar fotos de una petición (paginadas, más recientes primero).
   */
  async listar(peticionId: number, page: number = 1): Promise<GaleriaResponse> {
    const response = await apiClient.get<{ data: GaleriaResponse }>('/galeria/list', {
      params: { peticion_id: peticionId, page },
    });
    return response.data.data;
  },

  /**
   * Subir foto asociada a una petición.
   */
  async subir(peticionId: number, imageUri: string, tipo: string = 'foto_visita'): Promise<{ foto_id: number }> {
    const formData = new FormData();
    const filename = imageUri.split('/').pop() || 'photo.jpg';
    const match = /\.(\w+)$/.exec(filename);
    const mimeType = match ? `image/${match[1] === 'jpg' ? 'jpeg' : match[1]}` : 'image/jpeg';

    formData.append('foto', {
      uri: imageUri,
      name: filename,
      type: mimeType,
    } as unknown as Blob);

    formData.append('peticion_id', String(peticionId));
    formData.append('tipo', tipo);

    const response = await apiClient.post<{ data: { foto_id: number } }>(
      '/galeria/upload',
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
    return response.data.data;
  },

  /**
   * Obtener URL de thumbnail para una foto.
   */
  getThumbUrl(fotoId: number): string {
    return `${apiClient.defaults.baseURL}/galeria/thumb?id=${fotoId}`;
  },

  /**
   * Obtener URL completa para una foto.
   */
  getFullUrl(fotoId: number): string {
    return `${apiClient.defaults.baseURL}/galeria/thumb?id=${fotoId}&full=1`;
  },
};
