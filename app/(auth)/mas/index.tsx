/**
 * Menú Secundario "Más".
 * Acceso a Actividad y Galería.
 * TODO: Implementar en Fase 5.
 */
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export default function MasScreen() {
  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.menuItem} activeOpacity={0.7}>
        <Ionicons name="document-text-outline" size={24} color="#3182ce" />
        <View style={styles.menuContent}>
          <Text style={styles.menuTitle}>Actividad</Text>
          <Text style={styles.menuSubtitle}>Documentos e instrucciones de campaña</Text>
        </View>
        <Ionicons name="chevron-forward" size={20} color="#a0aec0" />
      </TouchableOpacity>

      <TouchableOpacity style={styles.menuItem} activeOpacity={0.7}>
        <Ionicons name="images-outline" size={24} color="#3182ce" />
        <View style={styles.menuContent}>
          <Text style={styles.menuTitle}>Galería</Text>
          <Text style={styles.menuSubtitle}>Fotos de instalaciones realizadas</Text>
        </View>
        <Ionicons name="chevron-forward" size={20} color="#a0aec0" />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f7fafc',
    paddingTop: 16,
  },
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#ffffff',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e2e8f0',
  },
  menuContent: {
    flex: 1,
    marginLeft: 16,
  },
  menuTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1a2332',
  },
  menuSubtitle: {
    fontSize: 13,
    color: '#718096',
    marginTop: 2,
  },
});
