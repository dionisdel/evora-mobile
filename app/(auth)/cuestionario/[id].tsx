/**
 * Pantalla de Cuestionario / Ficha de Visita.
 * 
 * Carga la ficha desde la API (o datos iniciales si no existe).
 * Permite completar los campos según tipo_instalacion.
 * Auto-guarda cada 30 segundos.
 * Botón "Finalizar" para validar y cerrar la visita.
 */
import { useEffect, useState, useCallback, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  ActivityIndicator,
  TouchableOpacity,
  Alert,
  TextInput,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { cuestionarioService, FichaResponse } from '../../../src/services/cuestionario.service';
import { visitaService } from '../../../src/services/visita.service';
import { executeWithOfflineFallback } from '../../../src/utils/offline-helpers';

type FichaData = Record<string, unknown>;

export default function CuestionarioScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const peticionId = parseInt(id || '0', 10);

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [ficha, setFicha] = useState<FichaData | null>(null);
  const [fichaExists, setFichaExists] = useState(false);
  const [tipoInstalacion, setTipoInstalacion] = useState<string | null>(null);
  const [hasChanges, setHasChanges] = useState(false);

  const autoSaveRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // Cargar ficha al montar
  useEffect(() => {
    loadFicha();
    return () => {
      if (autoSaveRef.current) clearInterval(autoSaveRef.current);
    };
  }, [peticionId]);

  // Auto-guardado cada 30 segundos
  useEffect(() => {
    if (autoSaveRef.current) clearInterval(autoSaveRef.current);

    if (fichaExists || hasChanges) {
      autoSaveRef.current = setInterval(() => {
        if (hasChanges && ficha) {
          handleSave(false);
        }
      }, 30000);
    }

    return () => {
      if (autoSaveRef.current) clearInterval(autoSaveRef.current);
    };
  }, [hasChanges, ficha, fichaExists]);

  const loadFicha = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Abrir visita (crea ficha si no existe)
      await visitaService.abrir({ peticion_id: peticionId });

      // Obtener ficha
      const response: FichaResponse = await cuestionarioService.getFicha(peticionId);
      if (response) {
        setFicha(response.ficha as FichaData);
        setFichaExists(response.exists);
        setTipoInstalacion(response.tipo_instalacion);
      }
    } catch (err) {
      setError('No se pudo cargar el cuestionario. Comprueba tu conexión.');
    } finally {
      setIsLoading(false);
    }
  };

  const updateField = useCallback((field: string, value: unknown) => {
    setFicha(prev => prev ? { ...prev, [field]: value } : null);
    setHasChanges(true);
  }, []);

  const handleSave = async (showAlert = true) => {
    if (!ficha) return;
    setIsSaving(true);
    try {
      const result = await executeWithOfflineFallback(
        () => cuestionarioService.guardarFicha(peticionId, { ...ficha, validar: false }),
        'ficha_visita',
        { peticion_id: peticionId, ficha_data: ficha, validar: false }
      );
      setHasChanges(false);
      if (showAlert) {
        if (result.queued) {
          Alert.alert('Guardado offline', 'Se sincronizará cuando haya conexión.');
        } else {
          Alert.alert('Guardado', 'Ficha guardada correctamente');
        }
      }
    } catch {
      if (showAlert) Alert.alert('Error', 'No se pudo guardar.');
    } finally {
      setIsSaving(false);
    }
  };

  const handleFinalizar = () => {
    Alert.alert(
      'Finalizar visita',
      '¿Estás seguro de que quieres validar y cerrar la ficha? No podrás editarla después.',
      [
        { text: 'Cancelar', style: 'cancel' },
        { text: 'Finalizar', style: 'destructive', onPress: doFinalizar },
      ]
    );
  };

  const doFinalizar = async () => {
    if (!ficha) return;
    setIsSaving(true);
    try {
      const saveResult = await executeWithOfflineFallback(
        () => cuestionarioService.guardarFicha(peticionId, { ...ficha, validar: true }),
        'ficha_visita',
        { peticion_id: peticionId, ficha_data: ficha, validar: true }
      );

      // Cerrar visita
      await executeWithOfflineFallback(
        () => visitaService.cerrar(peticionId).then(() => undefined),
        'cerrar_actividad',
        { peticion_id: peticionId }
      );

      if (saveResult.queued) {
        Alert.alert('Guardado offline', 'La ficha se validará cuando haya conexión.', [
          { text: 'OK', onPress: () => router.back() },
        ]);
      } else {
        Alert.alert('Completado', 'Ficha validada y visita cerrada.', [
          { text: 'OK', onPress: () => router.back() },
        ]);
      }
    } catch {
      Alert.alert('Error', 'No se pudo finalizar. Inténtalo de nuevo.');
    } finally {
      setIsSaving(false);
    }
  };

  // --- Loading ---
  if (isLoading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#3182ce" />
        <Text style={styles.loadingText}>Cargando cuestionario...</Text>
      </View>
    );
  }

  // --- Error ---
  if (error) {
    return (
      <View style={styles.centered}>
        <Ionicons name="alert-circle-outline" size={48} color="#e53e3e" />
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryBtn} onPress={loadFicha}>
          <Text style={styles.retryText}>Reintentar</Text>
        </TouchableOpacity>
      </View>
    );
  }

  if (!ficha) return null;

  const isValidated = !!(ficha as FichaData).validado;
  const canFinalize = !isValidated && (ficha as FichaData).instalacion_exitosa !== undefined && (ficha as FichaData).instalacion_exitosa !== null;

  return (
    <View style={styles.container}>
      {/* Header con info de la farmacia */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="arrow-back" size={24} color="#1a2332" />
        </TouchableOpacity>
        <View style={styles.headerInfo}>
          <Text style={styles.headerTitle} numberOfLines={1}>
            {(ficha as FichaData).nombre_cliente as string || 'Cuestionario'}
          </Text>
          <Text style={styles.headerSubtitle}>
            {tipoInstalacion || 'Ficha de visita'}
          </Text>
        </View>
        {hasChanges && <View style={styles.unsavedDot} />}
      </View>

      {/* Formulario */}
      <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
        {/* Información de la visita */}
        <Section title="Datos de la visita">
          <ReadonlyField label="Farmacia" value={(ficha as FichaData).nombre_cliente as string} />
          <ReadonlyField label="Dirección" value={(ficha as FichaData).direccion as string} />
          <ReadonlyField label="Fecha visita" value={(ficha as FichaData).fecha_visita as string} />
          <ReadonlyField label="Tipo" value={tipoInstalacion || '-'} />
        </Section>

        {/* Pregunta principal: ¿Se logró la instalación? */}
        {tipoInstalacion !== 'Envío' && (
          <Section title="¿Se logró la instalación?">
            <RadioGroup
              value={(ficha as FichaData).instalacion_exitosa as string}
              options={[
                { label: 'Sí', value: 'si' },
                { label: 'No', value: 'no' },
              ]}
              onChange={(v) => updateField('instalacion_exitosa', v)}
              disabled={isValidated}
            />
          </Section>
        )}

        {/* Tipo Envío: ¿Se realizó el envío? */}
        {tipoInstalacion === 'Envío' && (
          <Section title="¿Se realizó el envío?">
            <RadioGroup
              value={(ficha as FichaData).envio_realizado as string}
              options={[
                { label: 'Sí', value: 'si' },
                { label: 'No', value: 'no' },
              ]}
              onChange={(v) => updateField('envio_realizado', v)}
              disabled={isValidated}
            />
          </Section>
        )}

        {/* Observaciones */}
        <Section title="Observaciones">
          <TextInput
            style={styles.textArea}
            multiline
            numberOfLines={4}
            value={(ficha as FichaData).observaciones as string || ''}
            onChangeText={(v) => updateField('observaciones', v)}
            placeholder="Notas adicionales sobre la visita..."
            placeholderTextColor="#a0aec0"
            editable={!isValidated}
          />
        </Section>

        {/* Estado de validación */}
        {isValidated && (
          <View style={styles.validatedBanner}>
            <Ionicons name="checkmark-circle" size={20} color="#38a169" />
            <Text style={styles.validatedText}>Ficha validada — solo lectura</Text>
          </View>
        )}
      </ScrollView>

      {/* Footer con acciones */}
      {!isValidated && (
        <View style={styles.footer}>
          <TouchableOpacity
            style={styles.saveBtn}
            onPress={() => handleSave(true)}
            disabled={isSaving || !hasChanges}
            activeOpacity={0.7}
          >
            {isSaving ? (
              <ActivityIndicator size="small" color="#3182ce" />
            ) : (
              <Text style={[styles.saveBtnText, !hasChanges && styles.disabledText]}>
                Guardar borrador
              </Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.finalizeBtn, !canFinalize && styles.finalizeBtnDisabled]}
            onPress={handleFinalizar}
            disabled={!canFinalize || isSaving}
            activeOpacity={0.7}
          >
            <Ionicons name="checkmark-circle" size={20} color="#fff" />
            <Text style={styles.finalizeBtnText}>Finalizar</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

// === Componentes auxiliares ===

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <View style={styles.section}>
      <Text style={styles.sectionTitle}>{title}</Text>
      {children}
    </View>
  );
}

function ReadonlyField({ label, value }: { label: string; value?: string }) {
  return (
    <View style={styles.readonlyField}>
      <Text style={styles.fieldLabel}>{label}</Text>
      <Text style={styles.fieldValue}>{value || '-'}</Text>
    </View>
  );
}

function RadioGroup({ value, options, onChange, disabled }: {
  value?: string;
  options: { label: string; value: string }[];
  onChange: (value: string) => void;
  disabled?: boolean;
}) {
  return (
    <View style={styles.radioGroup}>
      {options.map((opt) => (
        <TouchableOpacity
          key={opt.value}
          style={[
            styles.radioOption,
            value === opt.value && styles.radioOptionSelected,
            disabled && styles.radioOptionDisabled,
          ]}
          onPress={() => !disabled && onChange(opt.value)}
          activeOpacity={disabled ? 1 : 0.7}
        >
          <Ionicons
            name={value === opt.value ? 'radio-button-on' : 'radio-button-off'}
            size={20}
            color={value === opt.value ? '#3182ce' : '#a0aec0'}
          />
          <Text style={[styles.radioLabel, value === opt.value && styles.radioLabelSelected]}>
            {opt.label}
          </Text>
        </TouchableOpacity>
      ))}
    </View>
  );
}

// === Estilos ===

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f7fafc' },
  centered: { flex: 1, justifyContent: 'center', alignItems: 'center', padding: 32 },
  loadingText: { marginTop: 12, color: '#718096', fontSize: 14 },
  errorText: { marginTop: 12, color: '#e53e3e', fontSize: 14, textAlign: 'center' },
  retryBtn: { marginTop: 16, backgroundColor: '#3182ce', paddingHorizontal: 20, paddingVertical: 10, borderRadius: 8 },
  retryText: { color: '#fff', fontWeight: '500' },

  header: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#fff', padding: 16, borderBottomWidth: 1, borderBottomColor: '#e2e8f0' },
  backBtn: { marginRight: 12, padding: 4 },
  headerInfo: { flex: 1 },
  headerTitle: { fontSize: 16, fontWeight: '600', color: '#1a2332' },
  headerSubtitle: { fontSize: 13, color: '#718096', marginTop: 2 },
  unsavedDot: { width: 10, height: 10, borderRadius: 5, backgroundColor: '#dd6b20' },

  scroll: { flex: 1 },
  scrollContent: { padding: 16, paddingBottom: 100 },

  section: { marginBottom: 20, backgroundColor: '#fff', borderRadius: 10, padding: 16, borderWidth: 1, borderColor: '#e2e8f0' },
  sectionTitle: { fontSize: 14, fontWeight: '600', color: '#1a2332', marginBottom: 12 },

  readonlyField: { marginBottom: 8 },
  fieldLabel: { fontSize: 12, color: '#718096', marginBottom: 2 },
  fieldValue: { fontSize: 14, color: '#1a2332' },

  textArea: { backgroundColor: '#f7fafc', borderRadius: 8, padding: 12, fontSize: 14, color: '#1a2332', minHeight: 80, textAlignVertical: 'top', borderWidth: 1, borderColor: '#e2e8f0' },

  radioGroup: { flexDirection: 'row', gap: 16 },
  radioOption: { flexDirection: 'row', alignItems: 'center', paddingVertical: 8, paddingHorizontal: 12, borderRadius: 8, borderWidth: 1, borderColor: '#e2e8f0' },
  radioOptionSelected: { borderColor: '#3182ce', backgroundColor: '#ebf8ff' },
  radioOptionDisabled: { opacity: 0.6 },
  radioLabel: { marginLeft: 8, fontSize: 14, color: '#4a5568' },
  radioLabelSelected: { color: '#3182ce', fontWeight: '500' },

  validatedBanner: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#f0fff4', padding: 12, borderRadius: 8, marginTop: 8 },
  validatedText: { marginLeft: 8, color: '#38a169', fontSize: 14, fontWeight: '500' },

  footer: { flexDirection: 'row', padding: 16, backgroundColor: '#fff', borderTopWidth: 1, borderTopColor: '#e2e8f0', gap: 12 },
  saveBtn: { flex: 1, paddingVertical: 14, alignItems: 'center', borderRadius: 8, borderWidth: 1, borderColor: '#3182ce' },
  saveBtnText: { color: '#3182ce', fontSize: 14, fontWeight: '600' },
  disabledText: { color: '#a0aec0' },
  finalizeBtn: { flex: 1, flexDirection: 'row', justifyContent: 'center', alignItems: 'center', paddingVertical: 14, borderRadius: 8, backgroundColor: '#38a169', gap: 6 },
  finalizeBtnDisabled: { backgroundColor: '#a0aec0' },
  finalizeBtnText: { color: '#fff', fontSize: 14, fontWeight: '600' },
});
