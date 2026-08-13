/**
 * Pantalla Principal - Búsqueda de Farmacias.
 * Incluye barra de búsqueda y listado de farmacias cercanas.
 */
import { useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useLocation } from '../../src/hooks/useLocation';
import { useFarmacias } from '../../src/hooks/useFarmacias';
import SearchBar from '../../src/components/SearchBar';
import FarmaciaCard from '../../src/components/FarmaciaCard';

export default function BuscarScreen() {
  const { latitude, longitude, hasPermission, isLoading: geoLoading } = useLocation();
  const { farmacias, isLoading, error, buscar, buscarCercanas } = useFarmacias();

  // Cargar farmacias cercanas cuando tenemos ubicación
  useEffect(() => {
    if (latitude && longitude) {
      buscarCercanas(latitude, longitude);
    }
  }, [latitude, longitude, buscarCercanas]);

  return (
    <View style={styles.container}>
      {/* Badge de geolocalización */}
      {hasPermission && latitude && (
        <View style={styles.geoBadge}>
          <Text style={styles.geoBadgeText}>📍 Cerca de tu ubicación</Text>
        </View>
      )}

      {/* Barra de búsqueda */}
      <SearchBar onSearch={buscar} />

      {/* Estado de carga */}
      {(isLoading || geoLoading) && (
        <ActivityIndicator style={styles.loader} size="large" color="#3182ce" />
      )}

      {/* Error */}
      {error && <Text style={styles.error}>{error}</Text>}

      {/* Lista de farmacias */}
      <FlatList
        data={farmacias}
        keyExtractor={(item) => String(item.id)}
        renderItem={({ item }) => <FarmaciaCard farmacia={item} />}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          !isLoading && !geoLoading ? (
            <Text style={styles.empty}>
              {latitude ? 'No hay farmacias cercanas' : 'Busca una farmacia por nombre, dirección o población'}
            </Text>
          ) : null
        }
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7fafc',
  },
  geoBadge: {
    backgroundColor: '#ebf8ff',
    paddingVertical: 8,
    paddingHorizontal: 16,
  },
  geoBadgeText: {
    color: '#2b6cb0',
    fontSize: 13,
  },
  loader: {
    marginTop: 32,
  },
  error: {
    color: '#e53e3e',
    textAlign: 'center',
    marginTop: 16,
    paddingHorizontal: 16,
  },
  list: {
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  empty: {
    textAlign: 'center',
    color: '#a0aec0',
    marginTop: 48,
    fontSize: 15,
  },
});
