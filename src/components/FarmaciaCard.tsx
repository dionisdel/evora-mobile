/**
 * Tarjeta de farmacia en lista de resultados.
 * Muestra nombre, dirección, distancia e icono de cuestionario.
 */
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { Farmacia, EstadoCuestionario } from '../types';
import { navegarADireccion } from '@utils/navigation';

interface FarmaciaCardProps {
  farmacia: Farmacia;
}

const ESTADO_ICONS: Record<EstadoCuestionario, { name: string; color: string }> = {
  pendiente: { name: 'checkbox-outline', color: '#a0aec0' },
  en_curso: { name: 'checkbox-outline', color: '#dd6b20' },
  completado: { name: 'checkbox', color: '#38a169' },
};

export default function FarmaciaCard({ farmacia }: FarmaciaCardProps) {
  const router = useRouter();
  const estadoIcon = ESTADO_ICONS[farmacia.estado_cuestionario];

  const handlePress = () => {
    router.push(`/(auth)/cuestionario/${farmacia.id}`);
  };

  const handleDireccionPress = () => {
    if (farmacia.direccion) {
      const direccionCompleta = `${farmacia.direccion}, ${farmacia.poblacion}`;
      navegarADireccion(direccionCompleta);
    }
  };

  return (
    <View style={styles.card}>
      <TouchableOpacity style={styles.content} onPress={handlePress} activeOpacity={0.7}>
        <View style={styles.info}>
          <Text style={styles.nombre}>{farmacia.nombre}</Text>
          <TouchableOpacity onPress={handleDireccionPress} activeOpacity={0.7}>
            <Text style={styles.direccion}>
              {farmacia.direccion}, {farmacia.poblacion}
              {farmacia.distancia_km != null && ` · ${farmacia.distancia_km.toFixed(1)} km`}
            </Text>
          </TouchableOpacity>
          <Text style={styles.externalId}>{farmacia.external_id}</Text>
        </View>

        <View style={styles.actions}>
          {farmacia.tiene_post_it && (
            <Ionicons name="chatbox-ellipses-outline" size={22} color="#d69e2e" />
          )}
          <Ionicons
            name={estadoIcon.name as keyof typeof Ionicons.glyphMap}
            size={24}
            color={estadoIcon.color}
          />
        </View>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: '#ffffff',
    borderRadius: 8,
    marginBottom: 8,
    borderWidth: 1,
    borderColor: '#e2e8f0',
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
  },
  info: {
    flex: 1,
  },
  nombre: {
    fontSize: 15,
    fontWeight: '600',
    color: '#1a2332',
  },
  direccion: {
    fontSize: 13,
    color: '#4a5568',
    marginTop: 3,
  },
  externalId: {
    fontSize: 12,
    color: '#a0aec0',
    marginTop: 2,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
});
