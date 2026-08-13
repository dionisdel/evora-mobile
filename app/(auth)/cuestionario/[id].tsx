/**
 * Pantalla de Cuestionario.
 * Muestra el formulario dinámico de la farmacia seleccionada.
 * TODO: Implementar en Fase 4.
 */
import { View, Text, StyleSheet } from 'react-native';
import { useLocalSearchParams } from 'expo-router';

export default function CuestionarioScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Cuestionario</Text>
      <Text style={styles.subtitle}>Farmacia ID: {id}</Text>
      <Text style={styles.placeholder}>
        Implementación del formulario dinámico pendiente (Fase 4)
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7fafc',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 32,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1a2332',
  },
  subtitle: {
    fontSize: 16,
    color: '#718096',
    marginTop: 8,
  },
  placeholder: {
    fontSize: 14,
    color: '#a0aec0',
    marginTop: 24,
    textAlign: 'center',
  },
});
