/**
 * Modal de Post-It de farmacia.
 * Muestra los campos de notas de peticiones_visibilidad en solo lectura.
 * Campos: observaciones, a_la_atencion_de, marca, campana, opciones_acordar, 
 *         direccion_envio, muestras, otros.
 */
import { View, Text, Modal, ScrollView, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { PostIt } from '../types';

interface PostItModalProps {
  visible: boolean;
  postIt: PostIt | null;
  onClose: () => void;
}

const FIELD_LABELS: Record<string, string> = {
  observaciones: 'Observaciones',
  a_la_atencion_de: 'A la atención de',
  marca: 'Marca',
  campana: 'Campaña',
  opciones_acordar: 'Opciones a acordar',
  direccion_envio: 'Dirección de envío',
  muestras: 'Muestras',
  otros: 'Otros',
};

export default function PostItModal({ visible, postIt, onClose }: PostItModalProps) {
  if (!postIt) return null;

  const entries = Object.entries(postIt).filter(([, value]) => !!value);

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View style={styles.overlay}>
        <View style={styles.modal}>
          <View style={styles.header}>
            <Text style={styles.title}>📝 Datos Particulares</Text>
            <TouchableOpacity
              onPress={onClose}
              hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
              accessible
              accessibilityLabel="Cerrar notas"
            >
              <Ionicons name="close" size={24} color="#718096" />
            </TouchableOpacity>
          </View>
          <ScrollView style={styles.scrollContent} showsVerticalScrollIndicator>
            {entries.map(([key, value]) => (
              <View key={key} style={styles.field}>
                <Text style={styles.fieldLabel}>{FIELD_LABELS[key] || key}</Text>
                <Text style={styles.fieldValue} selectable={false}>
                  {String(value)}
                </Text>
              </View>
            ))}
            {entries.length === 0 && (
              <Text style={styles.emptyText}>Sin notas disponibles</Text>
            )}
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  modal: {
    backgroundColor: '#fffff0',
    borderRadius: 12,
    width: '100%',
    maxHeight: '75%',
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 8,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#fefcbf',
  },
  title: {
    fontSize: 17,
    fontWeight: '600',
    color: '#744210',
  },
  scrollContent: {
    maxHeight: 350,
  },
  field: {
    marginBottom: 14,
  },
  fieldLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#975a16',
    textTransform: 'uppercase',
    marginBottom: 3,
  },
  fieldValue: {
    fontSize: 14,
    color: '#4a5568',
    lineHeight: 20,
  },
  emptyText: {
    fontSize: 14,
    color: '#a0aec0',
    textAlign: 'center',
    paddingVertical: 16,
  },
});
