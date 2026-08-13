/**
 * Modal de Post-It de farmacia.
 * Muestra el contenido en solo lectura.
 */
import { View, Text, Modal, ScrollView, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface PostItModalProps {
  visible: boolean;
  content: string;
  onClose: () => void;
}

export default function PostItModal({ visible, content, onClose }: PostItModalProps) {
  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <View style={styles.overlay}>
        <View style={styles.modal}>
          <View style={styles.header}>
            <Text style={styles.title}>📝 Nota</Text>
            <TouchableOpacity onPress={onClose} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
              <Ionicons name="close" size={24} color="#718096" />
            </TouchableOpacity>
          </View>
          <ScrollView style={styles.content}>
            <Text style={styles.text} selectable={false}>
              {content}
            </Text>
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
    padding: 32,
  },
  modal: {
    backgroundColor: '#fffff0',
    borderRadius: 12,
    width: '100%',
    maxHeight: '70%',
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
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1a2332',
  },
  content: {
    maxHeight: 300,
  },
  text: {
    fontSize: 15,
    color: '#4a5568',
    lineHeight: 22,
  },
});
