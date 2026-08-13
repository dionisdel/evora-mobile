/**
 * Pantalla Principal - Búsqueda de Farmacias.
 * Barra de búsqueda con filtros + listado de resultados.
 * 
 * Carga las peticiones asignadas al usuario al iniciar.
 * Permite buscar por nombre, external_id, dirección, población, provincia.
 */
import { useEffect, useState } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  ActivityIndicator,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useFarmacias } from '../../src/hooks/useFarmacias';
import { useOfflineQueue } from '../../src/hooks/useOfflineQueue';
import { useAuthStore } from '../../src/store/auth.store';
import { BusquedaParams } from '../../src/services/farmacia.service';
import SearchBar from '../../src/components/SearchBar';
import FarmaciaCard from '../../src/components/FarmaciaCard';
import SyncIndicator from '../../src/components/SyncIndicator';

export default function BuscarScreen() {
  const { farmacias, isLoading, error, buscar, limpiar } = useFarmacias();
  const { user } = useAuthStore();
  const { retryFailed } = useOfflineQueue(); // Activa monitoring de red
  const [hasSearched, setHasSearched] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  // Cargar peticiones asignadas al iniciar
  useEffect(() => {
    buscar({});
    setHasSearched(true);
  }, [buscar]);

  const handleSearch = (params: BusquedaParams) => {
    setHasSearched(true);
    buscar(params);
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await buscar({});
    setRefreshing(false);
  };

  return (
    <View style={styles.container}>
      {/* Header con nombre del usuario */}
      <View style={styles.userHeader}>
        <Text style={styles.greeting}>Hola, {user?.nombre?.split(' ')[0] || 'Instalador'}</Text>
        <SyncIndicator onRetry={retryFailed} />
      </View>

      {/* Barra de búsqueda */}
      <SearchBar onSearch={handleSearch} />

      {/* Estado de carga */}
      {isLoading && !refreshing && (
        <ActivityIndicator style={styles.loader} size="large" color="#3182ce" />
      )}

      {/* Error con retry */}
      {error && (
        <View style={styles.errorContainer}>
          <Ionicons name="cloud-offline-outline" size={32} color="#e53e3e" />
          <Text style={styles.errorText}>{error}</Text>
          <TouchableOpacity style={styles.retryButton} onPress={() => buscar({})}>
            <Text style={styles.retryText}>Reintentar</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Lista de farmacias */}
      {!error && (
        <FlatList
          data={farmacias}
          keyExtractor={(item) => String(item.id)}
          renderItem={({ item }) => <FarmaciaCard farmacia={item} />}
          contentContainerStyle={styles.list}
          refreshControl={
            <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} colors={['#3182ce']} />
          }
          ListEmptyComponent={
            !isLoading && hasSearched ? (
              <View style={styles.emptyContainer}>
                <Ionicons name="search-outline" size={48} color="#e2e8f0" />
                <Text style={styles.emptyTitle}>Sin resultados</Text>
                <Text style={styles.emptySubtitle}>
                  No se encontraron farmacias con los filtros aplicados
                </Text>
              </View>
            ) : null
          }
          ListFooterComponent={
            farmacias.length > 0 ? (
              <Text style={styles.resultCount}>
                {farmacias.length} farmacia{farmacias.length !== 1 ? 's' : ''}
              </Text>
            ) : null
          }
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7fafc',
  },
  userHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  greeting: {
    fontSize: 14,
    color: '#718096',
  },
  loader: {
    marginTop: 32,
  },
  errorContainer: {
    alignItems: 'center',
    marginTop: 48,
    paddingHorizontal: 32,
  },
  errorText: {
    color: '#e53e3e',
    textAlign: 'center',
    marginTop: 12,
    fontSize: 14,
  },
  retryButton: {
    marginTop: 16,
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: '#3182ce',
    borderRadius: 8,
  },
  retryText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '500',
  },
  list: {
    paddingHorizontal: 16,
    paddingTop: 4,
    paddingBottom: 16,
  },
  emptyContainer: {
    alignItems: 'center',
    marginTop: 48,
    paddingHorizontal: 32,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#a0aec0',
    marginTop: 12,
  },
  emptySubtitle: {
    fontSize: 14,
    color: '#cbd5e0',
    textAlign: 'center',
    marginTop: 4,
  },
  resultCount: {
    textAlign: 'center',
    color: '#a0aec0',
    fontSize: 12,
    marginTop: 8,
    paddingBottom: 8,
  },
});
