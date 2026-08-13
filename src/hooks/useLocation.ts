/**
 * Hook de geolocalización.
 * Solicita permisos y obtiene coordenadas GPS.
 */
import { useState, useEffect } from 'react';
import * as Location from 'expo-location';

interface LocationState {
  latitude: number | null;
  longitude: number | null;
  isLoading: boolean;
  hasPermission: boolean;
  error: string | null;
}

export function useLocation() {
  const [state, setState] = useState<LocationState>({
    latitude: null,
    longitude: null,
    isLoading: true,
    hasPermission: false,
    error: null,
  });

  useEffect(() => {
    let isMounted = true;

    const requestLocation = async () => {
      try {
        const { status } = await Location.requestForegroundPermissionsAsync();

        if (status !== 'granted') {
          if (isMounted) {
            setState((prev) => ({
              ...prev,
              isLoading: false,
              hasPermission: false,
              error: 'Permiso de ubicación denegado',
            }));
          }
          return;
        }

        const location = await Location.getCurrentPositionAsync({
          accuracy: Location.Accuracy.Balanced,
        });

        if (isMounted) {
          setState({
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            isLoading: false,
            hasPermission: true,
            error: null,
          });
        }
      } catch (err) {
        if (isMounted) {
          setState((prev) => ({
            ...prev,
            isLoading: false,
            error: 'No se pudo obtener la ubicación',
          }));
        }
      }
    };

    requestLocation();

    return () => {
      isMounted = false;
    };
  }, []);

  const refresh = async () => {
    setState((prev) => ({ ...prev, isLoading: true }));
    try {
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
      });
      setState((prev) => ({
        ...prev,
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
        isLoading: false,
      }));
    } catch {
      setState((prev) => ({ ...prev, isLoading: false }));
    }
  };

  return { ...state, refresh };
}
