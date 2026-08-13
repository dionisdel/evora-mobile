/**
 * Tipos compartidos de la aplicación Evora Mobile.
 * Reflejan los modelos de datos de la API v2 mobile de Evora.
 * 
 * NOTA: En Evora, los "instaladores" son usuarios con rol 'coach' o 'colaborador'.
 * No existe un rol 'instalador' en la BD.
 */

// === Autenticación ===

export interface User {
  id: number;
  nombre: string;
  perfil: 'coach' | 'colaborador';
  merchan: string;
}

// === Farmacias (peticiones_visibilidad) ===

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
  tiene_post_it: boolean;
  distancia_km: number | null; // Siempre null (no hay coords en BD)
}

export interface FarmaciaDetalle extends Farmacia {
  correo?: string;
  persona_contacto?: string;
  tipo_solicitud?: string;
  opcion?: string;
  status?: string;
  post_it: PostIt | null;
  ficha_id: number | null;
  calendario: Calendario | null;
}

// === Post-It (campos de peticiones_visibilidad) ===

export interface PostIt {
  observaciones?: string;
  a_la_atencion_de?: string;
  marca?: string;
  campana?: string;
  opciones_acordar?: string;
  direccion_envio?: string;
  muestras?: string;
  otros?: string;
}

// === Cuestionario / Ficha de Visita (peticiones_fichas_visita) ===

export type EstadoCuestionario = 'pendiente' | 'en_curso' | 'completado';

/**
 * La ficha de visita en Evora tiene campos fijos (no es un formulario dinámico).
 * Los campos dependen del tipo de campaña/solicitud.
 */
export interface FichaVisita {
  id: number;
  peticion_id: number;
  external_id: string;
  fecha_visita?: string;
  hora_visita?: string;
  instalacion_exitosa?: 'si' | 'no';
  tipo_instalacion?: string;
  motivo_no_instalacion?: string;
  trabajo_realizado?: string;
  materiales_instalados?: string;
  observaciones?: string;
  incidencias?: string;
  validado: boolean;
  // ... más campos según campaña (vinilos, baldas, kits, etc.)
}

// === Calendario (peticiones_calendario) ===

export interface Calendario {
  fecha_agendada: string | null;
  hora_visita: string | null;
  fecha_realizada: string | null;
  tipo_visita: 'Normal' | 'Plus';
}

// === Galería / Adjuntos (peticiones_adjuntos) ===

export interface Foto {
  id: number;
  peticion_id: number;
  tipo?: string;
  nombre?: string;
  mime_type?: string;
  foto_ficha: boolean;
  url_thumbnail: string;
  url_full: string;
  fecha: string;
}

// === Documentos (actividades + documentacion) ===

export interface Documento {
  id: number;
  nombre: string;
  tipo: string; // 'pdf', 'doc', 'imagen', 'video'
  formato?: string;
  url_download: string;
  fecha: string;
}

// === Offline Queue ===

export type SyncItemType = 'ficha_visita' | 'foto' | 'cerrar_actividad';
export type SyncItemStatus = 'pending' | 'syncing' | 'error';

export interface SyncItem {
  id: string;
  type: SyncItemType;
  status: SyncItemStatus;
  data: unknown;
  created_at: string;
  retries: number;
}
