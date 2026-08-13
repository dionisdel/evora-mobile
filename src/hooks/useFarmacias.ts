/**
 * Hook para búsqueda y listado de farmacias.
 * Solo búsqueda por filtros de texto (no hay geolocalización en BD).
 */
import { useState, useCallback } from 'react';
import { farmaciaService, BusquedaParams } from '@services/farmacia.service';
import { Farmacia } from '../types';

export function useFarmacias() {
  const [farmacias, setFarmacias] = useState<Farmacia[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const buscar = useCallback(async (params: BusquedaParams) => {
    setIsLoading(true);
    setError(null);
    try {
      const results = await farmaciaService.buscar(params);
      setFarmacias(results);
    } catch {
      setError('No se pudieron cargar las farmacias. Comprueba tu conexión.');
      setFarmacias([]);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const limpiar = useCallback(() => {
    setFarmacias([]);
    setError(null);
  }, []);

  return { farmacias, isLoading, error, buscar, limpiar };
}
