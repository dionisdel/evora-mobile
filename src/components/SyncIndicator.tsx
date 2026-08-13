/**
 * Indicador de sincronización offline.
 * Muestra badge con elementos pendientes.
 */
import { View, Text, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSyncStore } from '@store/sync.store';

export default function SyncIndicator() {
  const { pendingCount, isSyncing, hasErrors } = useSyncStore();

  if (pendingCount === 0 && !hasErrors) return null;

  const getIcon = () => {
    if (isSyncing) return 'sync';
    if (hasErrors) return 'alert-circle';
    return 'cloud-upload-outline';
  };

  const getColor = () => {
    if (hasErrors) return '#e53e3e';
    if (isSyncing) return '#3182ce';
    return '#dd6b20';
  };

  return (
    <View style={[styles.container, { borderColor: getColor() }]}>
      <Ionicons name={getIcon()} size={16} color={getColor()} />
      <Text style={[styles.text, { color: getColor() }]}>
        {isSyncing ? 'Sincronizando...' : `${pendingCount} pendiente${pendingCount > 1 ? 's' : ''}`}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 16,
    borderWidth: 1,
    gap: 6,
    alignSelf: 'center',
    marginVertical: 8,
  },
  text: {
    fontSize: 12,
    fontWeight: '500',
  },
});
