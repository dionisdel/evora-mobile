/**
 * Barra de búsqueda de farmacias.
 * Input principal con debounce + panel de filtros avanzados.
 * Filtros: nombre, external_id, dirección, población, provincia.
 */
import { useState, useCallback, useRef } from 'react';
import { View, TextInput, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BusquedaParams } from '@services/farmacia.service';

interface SearchBarProps {
  onSearch: (params: BusquedaParams) => void;
}

export default function SearchBar({ onSearch }: SearchBarProps) {
  const [query, setQuery] = useState('');
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<BusquedaParams>({});
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const handleChange = useCallback(
    (text: string) => {
      setQuery(text);

      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }

      if (text.length >= 3) {
        debounceRef.current = setTimeout(() => {
          // Buscar en nombre por defecto, pero si parece un ID usar external_id
          const isId = /^[A-Z]{2,4}-?\d/.test(text.toUpperCase());
          if (isId) {
            onSearch({ external_id: text, ...filters });
          } else {
            onSearch({ nombre: text, ...filters });
          }
        }, 400);
      }
    },
    [onSearch, filters]
  );

  const handleFilterChange = (field: keyof BusquedaParams, value: string) => {
    setFilters(prev => ({ ...prev, [field]: value }));
  };

  const handleFilterSearch = () => {
    const params: BusquedaParams = { ...filters };
    if (query.length >= 3) params.nombre = query;
    onSearch(params);
  };

  const handleClear = () => {
    setQuery('');
    setFilters({});
    onSearch({});
  };

  const hasActiveFilters = Object.values(filters).some(v => v && v.length >= 3);

  return (
    <View style={styles.container}>
      {/* Barra principal */}
      <View style={styles.inputContainer}>
        <Ionicons name="search" size={20} color="#a0aec0" style={styles.icon} />
        <TextInput
          style={styles.input}
          placeholder="Nombre, dirección, población..."
          placeholderTextColor="#a0aec0"
          value={query}
          onChangeText={handleChange}
          autoCorrect={false}
          returnKeyType="search"
          onSubmitEditing={() => query.length >= 3 && onSearch({ nombre: query, ...filters })}
          accessible
          accessibilityLabel="Buscar farmacias"
        />
        {(query.length > 0 || hasActiveFilters) && (
          <TouchableOpacity onPress={handleClear} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
            <Ionicons name="close-circle" size={20} color="#a0aec0" />
          </TouchableOpacity>
        )}
        <TouchableOpacity
          onPress={() => setShowFilters(!showFilters)}
          style={[styles.filterButton, hasActiveFilters && styles.filterButtonActive]}
          hitSlop={{ top: 5, bottom: 5, left: 5, right: 5 }}
        >
          <Ionicons name="options-outline" size={20} color={hasActiveFilters ? '#3182ce' : '#a0aec0'} />
        </TouchableOpacity>
      </View>

      {/* Panel de filtros avanzados */}
      {showFilters && (
        <View style={styles.filtersPanel}>
          <FilterInput
            label="External ID"
            value={filters.external_id || ''}
            onChangeText={(v) => handleFilterChange('external_id', v)}
            placeholder="EXT-..."
          />
          <FilterInput
            label="Dirección"
            value={filters.direccion || ''}
            onChangeText={(v) => handleFilterChange('direccion', v)}
            placeholder="Calle, número..."
          />
          <FilterInput
            label="Población"
            value={filters.poblacion || ''}
            onChangeText={(v) => handleFilterChange('poblacion', v)}
            placeholder="Ciudad..."
          />
          <FilterInput
            label="Provincia"
            value={filters.provincia || ''}
            onChangeText={(v) => handleFilterChange('provincia', v)}
            placeholder="Provincia..."
          />
          <TouchableOpacity style={styles.applyButton} onPress={handleFilterSearch} activeOpacity={0.7}>
            <Text style={styles.applyButtonText}>Aplicar filtros</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

// Componente auxiliar para inputs de filtro
function FilterInput({ label, value, onChangeText, placeholder }: {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder: string;
}) {
  return (
    <View style={styles.filterRow}>
      <Text style={styles.filterLabel}>{label}</Text>
      <TextInput
        style={styles.filterInput}
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor="#cbd5e0"
        autoCapitalize="none"
        autoCorrect={false}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 4,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderWidth: 1,
    borderColor: '#e2e8f0',
    minHeight: 48,
  },
  icon: {
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontSize: 15,
    color: '#1a2332',
  },
  filterButton: {
    marginLeft: 8,
    padding: 4,
  },
  filterButtonActive: {
    backgroundColor: '#ebf8ff',
    borderRadius: 6,
  },
  filtersPanel: {
    marginTop: 8,
    backgroundColor: '#ffffff',
    borderRadius: 10,
    padding: 12,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  filterRow: {
    marginBottom: 8,
  },
  filterLabel: {
    fontSize: 12,
    color: '#718096',
    marginBottom: 4,
    fontWeight: '500',
  },
  filterInput: {
    backgroundColor: '#f7fafc',
    borderRadius: 6,
    paddingHorizontal: 10,
    paddingVertical: 8,
    fontSize: 14,
    color: '#1a2332',
    borderWidth: 1,
    borderColor: '#edf2f7',
  },
  applyButton: {
    backgroundColor: '#3182ce',
    borderRadius: 8,
    paddingVertical: 10,
    alignItems: 'center',
    marginTop: 4,
  },
  applyButtonText: {
    color: '#ffffff',
    fontSize: 14,
    fontWeight: '600',
  },
});
