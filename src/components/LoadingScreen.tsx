/**
 * Pantalla de carga reutilizable.
 * Se muestra al cargar datos de la API.
 */
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import { colors } from '../theme';

interface LoadingScreenProps {
  message?: string;
}

export default function LoadingScreen({ message = 'Cargando...' }: LoadingScreenProps) {
  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color={colors.accent} />
      <Text style={styles.text}>{message}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background,
    padding: 32,
  },
  text: {
    marginTop: 12,
    fontSize: 14,
    color: colors.textMuted,
  },
});
