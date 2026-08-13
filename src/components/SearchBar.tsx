/**
 * Barra de búsqueda de farmacias.
 * Input con debounce y filtros opcionales.
 */
import { useState, useCallback, useRef } from 'react';
import { View, TextInput, StyleSheet, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BusquedaParams } from '@services/farmacia.service';

interface SearchBarProps {
  onSearch: (params: BusquedaParams) => void;
}

export default function SearchBar({ onSearch }: SearchBarProps) {
  const [query, setQuery] = useState('');
  const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const handleChange = useCallback(
    (text: string) => {
      setQuery(text);

      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }

      if (text.length >= 3) {
        debounceRef.current = setTimeout(() => {
          onSearch({ nombre: text });
        }, 300);
      }
    },
    [onSearch]
  );

  const handleClear = () => {
    setQuery('');
  };

  return (
    <View style={styles.container}>
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
        />
        {query.length > 0 && (
          <TouchableOpacity onPress={handleClear} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
            <Ionicons name="close-circle" size={20} color="#a0aec0" />
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingVertical: 12,
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
  },
  icon: {
    marginRight: 8,
  },
  input: {
    flex: 1,
    fontSize: 15,
    color: '#1a2332',
  },
});
