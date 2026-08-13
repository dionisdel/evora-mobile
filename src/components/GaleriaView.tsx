/**
 * Vista de galería de fotos de una petición.
 * Grid de thumbnails + botón añadir foto (cámara/galería dispositivo).
 */
import { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  Image,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  Dimensions,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { Ionicons } from '@expo/vector-icons';
import { galeriaService, GaleriaResponse } from '@services/galeria.service';
import { executeWithOfflineFallback } from '@utils/offline-helpers';
import { Foto } from '../types';

interface GaleriaViewProps {
  peticionId: number;
}

const SCREEN_WIDTH = Dimensions.get('window').width;
const NUM_COLUMNS = 3;
const THUMB_SIZE = (SCREEN_WIDTH - 48 - 16) / NUM_COLUMNS; // padding + gaps

export default function GaleriaView({ peticionId }: GaleriaViewProps) {
  const [fotos, setFotos] = useState<Foto[]>([]);
  const [total, setTotal] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [isUploading, setIsUploading] = useState(false);

  useEffect(() => {
    loadFotos();
  }, [peticionId]);

  const loadFotos = async () => {
    setIsLoading(true);
    try {
      const response: GaleriaResponse = await galeriaService.listar(peticionId);
      setFotos(response.fotos);
      setTotal(response.total);
    } catch {
      // Silently fail
    } finally {
      setIsLoading(false);
    }
  };

  const handleAddPhoto = () => {
    Alert.alert('Añadir foto', 'Selecciona una opción', [
      { text: 'Cámara', onPress: () => pickImage('camera') },
      { text: 'Galería', onPress: () => pickImage('library') },
      { text: 'Cancelar', style: 'cancel' },
    ]);
  };

  const pickImage = async (source: 'camera' | 'library') => {
    try {
      let result;
      if (source === 'camera') {
        const { status } = await ImagePicker.requestCameraPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permiso necesario', 'Se necesita acceso a la cámara para capturar fotos.');
          return;
        }
        result = await ImagePicker.launchCameraAsync({
          mediaTypes: ['images'],
          quality: 0.8,
          allowsEditing: false,
        });
      } else {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permiso necesario', 'Se necesita acceso a la galería para seleccionar fotos.');
          return;
        }
        result = await ImagePicker.launchImageLibraryAsync({
          mediaTypes: ['images'],
          quality: 0.8,
          allowsEditing: false,
        });
      }

      if (!result.canceled && result.assets[0]) {
        await uploadPhoto(result.assets[0].uri);
      }
    } catch {
      Alert.alert('Error', 'No se pudo abrir la cámara/galería.');
    }
  };

  const uploadPhoto = async (uri: string) => {
    setIsUploading(true);
    try {
      const result = await executeWithOfflineFallback(
        () => galeriaService.subir(peticionId, uri).then(() => undefined),
        'foto',
        { peticion_id: peticionId, image_uri: uri, tipo: 'foto_visita' }
      );

      if (result.queued) {
        Alert.alert('Guardado offline', 'La foto se subirá cuando haya conexión.');
      } else {
        Alert.alert('Foto subida', 'La foto se ha subido correctamente.');
        loadFotos();
      }
    } catch {
      Alert.alert('Error', 'No se pudo subir la foto.');
    } finally {
      setIsUploading(false);
    }
  };

  if (isLoading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#3182ce" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header con contador */}
      <View style={styles.header}>
        <Text style={styles.headerText}>{total} foto{total !== 1 ? 's' : ''}</Text>
        <TouchableOpacity style={styles.addBtn} onPress={handleAddPhoto} disabled={isUploading}>
          {isUploading ? (
            <ActivityIndicator size="small" color="#fff" />
          ) : (
            <>
              <Ionicons name="camera" size={18} color="#fff" />
              <Text style={styles.addBtnText}>Añadir</Text>
            </>
          )}
        </TouchableOpacity>
      </View>

      {/* Grid de fotos */}
      {fotos.length > 0 ? (
        <FlatList
          data={fotos}
          numColumns={NUM_COLUMNS}
          keyExtractor={(item) => String(item.id)}
          renderItem={({ item }) => (
            <View style={styles.thumbContainer}>
              <Image
                source={{ uri: galeriaService.getThumbUrl(item.id) }}
                style={styles.thumb}
                resizeMode="cover"
              />
              {item.foto_ficha && (
                <View style={styles.fichaBadge}>
                  <Ionicons name="checkmark-circle" size={14} color="#38a169" />
                </View>
              )}
            </View>
          )}
          contentContainerStyle={styles.grid}
        />
      ) : (
        <View style={styles.emptyContainer}>
          <Ionicons name="images-outline" size={48} color="#e2e8f0" />
          <Text style={styles.emptyText}>Sin fotos todavía</Text>
          <Text style={styles.emptySubtext}>Pulsa "Añadir" para capturar la primera</Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingVertical: 12 },
  headerText: { fontSize: 14, color: '#718096' },
  addBtn: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#3182ce', paddingHorizontal: 14, paddingVertical: 8, borderRadius: 8, gap: 6 },
  addBtnText: { color: '#fff', fontSize: 13, fontWeight: '600' },
  grid: { paddingHorizontal: 16 },
  thumbContainer: { width: THUMB_SIZE, height: THUMB_SIZE, margin: 2, borderRadius: 6, overflow: 'hidden', backgroundColor: '#e2e8f0' },
  thumb: { width: '100%', height: '100%' },
  fichaBadge: { position: 'absolute', top: 4, right: 4, backgroundColor: '#fff', borderRadius: 10, padding: 2 },
  emptyContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingTop: 48 },
  emptyText: { fontSize: 15, color: '#a0aec0', marginTop: 12 },
  emptySubtext: { fontSize: 13, color: '#cbd5e0', marginTop: 4 },
});
