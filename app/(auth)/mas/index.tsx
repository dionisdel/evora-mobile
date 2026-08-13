/**
 * Menú Secundario "Más".
 * Actividad: listado de documentos de campaña.
 * Galería: Acceso a fotos (requiere seleccionar petición primero).
 */
import { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  ActivityIndicator,
  Linking,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { actividadService } from '../../../src/services/actividad.service';
import { Documento } from '../../../src/types';

type TabType = 'menu' | 'actividad';

export default function MasScreen() {
  const [activeTab, setActiveTab] = useState<TabType>('menu');

  if (activeTab === 'actividad') {
    return <ActividadView onBack={() => setActiveTab('menu')} />;
  }

  return (
    <View style={styles.container}>
      {/* Menú principal */}
      <TouchableOpacity
        style={styles.menuItem}
        onPress={() => setActiveTab('actividad')}
        activeOpacity={0.7}
      >
        <View style={styles.menuIcon}>
          <Ionicons name="document-text-outline" size={24} color="#3182ce" />
        </View>
        <View style={styles.menuContent}>
          <Text style={styles.menuTitle}>Actividad</Text>
          <Text style={styles.menuSubtitle}>Documentos e instrucciones de campaña</Text>
        </View>
        <Ionicons name="chevron-forward" size={20} color="#a0aec0" />
      </TouchableOpacity>

      <TouchableOpacity style={styles.menuItem} activeOpacity={0.7} disabled>
        <View style={styles.menuIcon}>
          <Ionicons name="images-outline" size={24} color="#a0aec0" />
        </View>
        <View style={styles.menuContent}>
          <Text style={[styles.menuTitle, styles.disabledText]}>Galería</Text>
          <Text style={styles.menuSubtitle}>Accede desde el detalle de cada farmacia</Text>
        </View>
      </TouchableOpacity>

      {/* Info */}
      <View style={styles.infoBox}>
        <Ionicons name="information-circle-outline" size={18} color="#718096" />
        <Text style={styles.infoText}>
          La galería de fotos está disponible desde el detalle de cada farmacia en la pantalla de búsqueda.
        </Text>
      </View>
    </View>
  );
}

// === Subvista de Actividad (documentos) ===

function ActividadView({ onBack }: { onBack: () => void }) {
  const [documentos, setDocumentos] = useState<Documento[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDocumentos();
  }, []);

  const loadDocumentos = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const docs = await actividadService.listar();
      setDocumentos(docs);
    } catch {
      setError('No se pudieron cargar los documentos.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleDownload = async (doc: Documento) => {
    try {
      const url = actividadService.getDownloadUrl(doc.id, doc.fuente);
      await Linking.openURL(url);
    } catch {
      // Fallback: mostrar error
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.subHeader}>
        <TouchableOpacity onPress={onBack} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={22} color="#1a2332" />
        </TouchableOpacity>
        <Text style={styles.subHeaderTitle}>Documentos de Actividad</Text>
      </View>

      {isLoading && <ActivityIndicator style={styles.loader} size="large" color="#3182ce" />}
      {error && <Text style={styles.errorText}>{error}</Text>}

      <FlatList
        data={documentos}
        keyExtractor={(item) => `${item.fuente}-${item.id}`}
        renderItem={({ item }) => (
          <TouchableOpacity style={styles.docItem} onPress={() => handleDownload(item)} activeOpacity={0.7}>
            <View style={styles.docIcon}>
              <Ionicons
                name={getDocIcon(item.tipo)}
                size={24}
                color="#3182ce"
              />
            </View>
            <View style={styles.docContent}>
              <Text style={styles.docName} numberOfLines={2}>{item.nombre}</Text>
              <Text style={styles.docMeta}>
                {item.categoria || item.tipo} · {formatDate(item.fecha)}
              </Text>
            </View>
            <Ionicons name="download-outline" size={20} color="#a0aec0" />
          </TouchableOpacity>
        )}
        contentContainerStyle={styles.listContent}
        ListEmptyComponent={
          !isLoading ? (
            <View style={styles.emptyContainer}>
              <Ionicons name="document-outline" size={48} color="#e2e8f0" />
              <Text style={styles.emptyText}>No hay documentos disponibles</Text>
            </View>
          ) : null
        }
      />
    </View>
  );
}

// === Helpers ===

function getDocIcon(tipo: string): keyof typeof Ionicons.glyphMap {
  switch (tipo) {
    case 'pdf': return 'document-text';
    case 'doc': return 'document';
    case 'imagen': return 'image';
    case 'video': return 'videocam';
    default: return 'document-outline';
  }
}

function formatDate(date: string): string {
  if (!date) return '';
  try {
    return new Date(date).toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
  } catch {
    return date;
  }
}

// === Estilos ===

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f7fafc' },
  menuItem: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#fff', paddingVertical: 18, paddingHorizontal: 20, borderBottomWidth: 1, borderBottomColor: '#e2e8f0' },
  menuIcon: { width: 40, height: 40, borderRadius: 10, backgroundColor: '#ebf8ff', justifyContent: 'center', alignItems: 'center' },
  menuContent: { flex: 1, marginLeft: 14 },
  menuTitle: { fontSize: 16, fontWeight: '600', color: '#1a2332' },
  menuSubtitle: { fontSize: 13, color: '#718096', marginTop: 2 },
  disabledText: { color: '#a0aec0' },
  infoBox: { flexDirection: 'row', alignItems: 'flex-start', margin: 16, padding: 12, backgroundColor: '#edf2f7', borderRadius: 8, gap: 8 },
  infoText: { flex: 1, fontSize: 13, color: '#718096', lineHeight: 18 },

  subHeader: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#fff', padding: 16, borderBottomWidth: 1, borderBottomColor: '#e2e8f0' },
  backBtn: { marginRight: 12, padding: 4 },
  subHeaderTitle: { fontSize: 17, fontWeight: '600', color: '#1a2332' },

  loader: { marginTop: 32 },
  errorText: { color: '#e53e3e', textAlign: 'center', marginTop: 16, padding: 16 },

  listContent: { padding: 16 },
  docItem: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#fff', borderRadius: 10, padding: 14, marginBottom: 8, borderWidth: 1, borderColor: '#e2e8f0' },
  docIcon: { width: 40, height: 40, borderRadius: 8, backgroundColor: '#ebf8ff', justifyContent: 'center', alignItems: 'center' },
  docContent: { flex: 1, marginHorizontal: 12 },
  docName: { fontSize: 14, fontWeight: '500', color: '#1a2332' },
  docMeta: { fontSize: 12, color: '#a0aec0', marginTop: 3 },

  emptyContainer: { alignItems: 'center', marginTop: 48 },
  emptyText: { fontSize: 14, color: '#a0aec0', marginTop: 12 },
});
