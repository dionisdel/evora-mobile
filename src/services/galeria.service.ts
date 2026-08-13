/**
 * Servicio de galería de fotos.
 * Listar fotos y subir nuevas imágenes.
 */
import apiClient from './api-client';
import { Foto } from '../types';

export const galeriaService = {
  /**
   * Listar fotos de una farmacia (paginadas, más recientes primero).
   */
  async listar(farmaciaId: number, page: number = 1): Promise<Foto[]> {
    const response = await apiClient.get<{ data: Foto[] }>(
      `/farmacias/${farmaciaId}/galeria`,
      { params: { page, limit: 50 } }
    );
    return response.data.data;
  },

  /**
   * Subir foto asociada a una farmacia y visita.
   */
  async subir(farmaciaId: number, imageUri: string, visitaId?: number): Promise<Foto> {
    const formData = new FormData();
    const filename = imageUri.split('/').pop() || 'photo.jpg';
    const match = /\.(\w+)$/.exec(filename);
    const type = match ? `image/${match[1]}` : 'image/jpeg';

    formData.append('foto', {
      uri: imageUri,
      name: filename,
      type,
    } as unknown as Blob);

    if (visitaId) {
      formData.append('visita_id', String(visitaId));
    }

    const response = await apiClient.post<{ data: Foto }>(
      `/farmacias/${farmaciaId}/galeria`,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } }
    );
    return response.data.data;
  },
};
