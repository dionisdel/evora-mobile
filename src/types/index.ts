/**
 * Tipos compartidos de la aplicación Evora Mobile.
 * Reflejan los modelos de datos de la API Evora.
 */

// === Autenticación ===

export interface User {
  id: number;
  nombre: string;
  perfil: 'instalador';
}

// === Farmacias ===

export interface Farmacia {
  id: number;
  external_id: string;
  nombre: string;
  direccion: string;
  poblacion: string;
  provincia: string;
  codigo_postal: string;
  telefono?: string;
  estado_cuestionario: EstadoCuestionario;
  distancia_km?: number;
  tiene_post_it: boolean;
}

export interface FarmaciaDetalle extends Farmacia {
  post_it?: string | null;
  correo?: string;
  persona_contacto?: string;
}

// === Cuestionarios ===

export type EstadoCuestionario = 'pendiente' | 'en_curso' | 'completado';

export interface Cuestionario {
  id: number;
  farmacia_id: number;
  estado: EstadoCuestionario;
  preguntas: Pregunta[];
  respuestas?: Respuesta[];
}

export interface Pregunta {
  id: number;
  texto: string;
  tipo: 'texto' | 'numero' | 'seleccion' | 'boolean' | 'foto';
  obligatoria: boolean;
  opciones?: string[];
  orden: number;
}

export interface Respuesta {
  pregunta_id: number;
  valor: string | number | boolean;
}

// === Visitas ===

export interface Visita {
  id: number;
  farmacia_id: number;
  instalador_id: number;
  fecha_apertura: string; // ISO 8601
  fecha_cierre?: string;
  latitud?: number;
  longitud?: number;
}

// === Galería ===

export interface Foto {
  id: number;
  farmacia_id: number;
  visita_id?: number;
  url_thumbnail: string;
  url_full: string;
  fecha: string;
}

// === Documentos ===

export interface Documento {
  id: number;
  nombre: string;
  tipo: string;
  size_bytes: number;
  url_download: string;
}

// === Offline Queue ===

export type SyncItemType = 'cuestionario' | 'visita_abrir' | 'visita_cerrar' | 'foto';
export type SyncItemStatus = 'pending' | 'syncing' | 'error';

export interface SyncItem {
  id: string;
  type: SyncItemType;
  status: SyncItemStatus;
  data: unknown;
  created_at: string;
  retries: number;
}
