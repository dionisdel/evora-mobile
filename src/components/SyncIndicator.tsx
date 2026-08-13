/**
 * Indicador de sincronización offline.
 * Muestra badge persistente con:
 * - Número de elementos pendientes
 * - Estado actual (pendiente, sincronizando, error)
 * - Botón reintentar si hay errores
 */
import { View, Text, TouchableOpacity, StyleSheet, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSyncStore } from '@store/sync.store';

interface SyncIndicatorProps {
  onRetry?: () => void;
}

export default function SyncIndicator({ onRetry }: SyncIndicatorProps) {
  const { pendingCount, isSyncing, hasErrors } = useSyncStore();

  if (pendingCount === 0 && !hasErrors && !isSyncing) return null;

  const getConfig = () => {
    if (isSyncing) return { icon: 'sync' as const, color: '#3182ce', bg: '#ebf8ff', text: 'Sincronizando...' };
    if (hasErrors) return { icon: 'alert-circle' as const, color: '#e53e3e', bg: '#fed7d7', text: `${pendingCount} con error` };
    return { icon: 'cloud-upload-outline' as const, color: '#dd6b20', bg: '#fefcbf', text: `${pendingCount} pendiente${pendingCount > 1 ? 's' : ''}` };
  };

  const config = getConfig();

  return (
    <TouchableOpacity
      style={[styles.container, { backgroundColor: config.bg, borderColor: config.color }]}
      onPress={hasErrors ? onRetry : undefined}
      activeOpacity={hasErrors ? 0.7 : 1}
      disabled={!hasErrors}
    >
      {isSyncing ? (
        <ActivityIndicator size={14} color={config.color} />
      ) : (
        <Ionicons name={config.icon} size={14} color={config.color} />
      )}
      <Text style={[styles.text, { color: config.color }]}>{config.text}</Text>
      {hasErrors && (
        <Ionicons name="refresh" size={12} color={config.color} />
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 14,
    borderWidth: 1,
    gap: 5,
  },
  text: {
    fontSize: 11,
    fontWeight: '500',
  },
});
