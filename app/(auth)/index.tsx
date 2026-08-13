/**
 * Pantalla Principal - Búsqueda de Farmacias.
 * Barra de búsqueda + listado de resultados.
 * 
 * NOTA: No hay geolocalización por proximidad (BD sin coordenadas).
 * La búsqueda es exclusivamente por filtros de texto.
 */
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useFarmacias } from '../../src/hooks/useFarmacias';
import SearchBar from '../../src/components/SearchBar';
import FarmaciaCard from '../../src/components/FarmaciaCard';

export default function BuscarScreen() {
  const { farmacias, isLoading, error, buscar } = useFarmacias();

  return (
    <View style={styles.container}>
      {/* Barra de búsqueda */}
      <SearchBar onSearch={buscar} />

      {/* Estado de carga */}
      {isLoading && (
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
          !isLoading ? (
            <Text style={styles.empty}>
              Busca una farmacia por nombre, dirección, población o provincia
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
    paddingHorizontal: 32,
  },
});
