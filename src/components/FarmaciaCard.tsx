/**
 * Tarjeta de farmacia en lista de resultados.
 * 
 * Acciones diferenciadas:
 * - Tocar nombre/card → Abrir cuestionario
 * - Tocar dirección → Abrir navegación (Google Maps/Waze)
 * - Icono post-it → Indica existencia de notas
 * - Icono cuestionario → Estado visual (pendiente/en_curso/completado)
 */
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Farmacia, EstadoCuestionario } from '../types';
import { navegarADireccion } from '@utils/navigation';

interface FarmaciaCardProps {
  farmacia: Farmacia;
}

const ESTADO_CONFIG: Record<EstadoCuestionario, { icon: string; color: string; label: string }> = {
  pendiente: { icon: 'checkbox-outline', color: '#a0aec0', label: 'Pendiente' },
  en_curso: { icon: 'create-outline', color: '#dd6b20', label: 'En curso' },
  completado: { icon: 'checkmark-circle', color: '#38a169', label: 'Completado' },
};

export default function FarmaciaCard({ farmacia }: FarmaciaCardProps) {
  const router = useRouter();
  const estado = ESTADO_CONFIG[farmacia.estado_cuestionario];

  const handleOpenCuestionario = () => {
    router.push(`/(auth)/cuestionario/${farmacia.id}`);
  };

  const handleNavegar = () => {
    if (farmacia.direccion) {
      const direccionCompleta = [farmacia.direccion, farmacia.poblacion, farmacia.provincia]
        .filter(Boolean)
        .join(', ');
      navegarADireccion(direccionCompleta);
    }
  };

  const hasDireccion = !!farmacia.direccion;

  return (
    <TouchableOpacity
      style={styles.card}
      onPress={handleOpenCuestionario}
      activeOpacity={0.7}
      accessible
      accessibilityLabel={`${farmacia.nombre}, ${estado.label}`}
      accessibilityRole="button"
    >
      <View style={styles.content}>
        {/* Info principal */}
        <View style={styles.info}>
          <Text style={styles.nombre} numberOfLines={1}>{farmacia.nombre}</Text>

          {/* Dirección (tocable para navegación) */}
          <TouchableOpacity
            onPress={handleNavegar}
            disabled={!hasDireccion}
            activeOpacity={0.6}
            hitSlop={{ top: 4, bottom: 4, left: 0, right: 0 }}
          >
            <Text style={[styles.direccion, hasDireccion && styles.direccionTocable]} numberOfLines={2}>
              {hasDireccion ? (
                <>
                  {farmacia.direccion}, {farmacia.poblacion}
                </>
              ) : (
                'Sin dirección'
              )}
            </Text>
          </TouchableOpacity>

          <Text style={styles.externalId}>{farmacia.external_id}</Text>
        </View>

        {/* Iconos de acción (derecha) */}
        <View style={styles.actions}>
          {/* Icono Post-It */}
          {farmacia.tiene_post_it && (
            <View style={styles.postItBadge}>
              <Ionicons name="document-text-outline" size={18} color="#d69e2e" />
            </View>
          )}

          {/* Icono estado cuestionario */}
          <View style={[styles.estadoBadge, { borderColor: estado.color }]}>
            <Ionicons
              name={estado.icon as keyof typeof Ionicons.glyphMap}
              size={22}
              color={estado.color}
            />
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 10,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#e2e8f0',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 14,
    minHeight: 72,
  },
  info: {
    flex: 1,
    marginRight: 12,
  },
  nombre: {
    fontSize: 15,
    fontWeight: '600',
    color: '#1a2332',
  },
  direccion: {
    fontSize: 13,
    color: '#718096',
    marginTop: 3,
  },
  direccionTocable: {
    color: '#4a5568',
    textDecorationLine: 'underline',
  },
  externalId: {
    fontSize: 11,
    color: '#a0aec0',
    marginTop: 3,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  postItBadge: {
    width: 32,
    height: 32,
    borderRadius: 6,
    backgroundColor: '#fffff0',
    justifyContent: 'center',
    alignItems: 'center',
  },
  estadoBadge: {
    width: 36,
    height: 36,
    borderRadius: 8,
    borderWidth: 1.5,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fafafa',
  },
});
