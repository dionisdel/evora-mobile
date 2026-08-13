/**
 * Tema visual de Evora Mobile.
 * Colores, tipografía y espaciado consistentes con la plataforma web.
 */

export const colors = {
  // Marca Evora
  primary: '#1a2332',       // Azul oscuro (header, fondos principales)
  primaryLight: '#2d3748',  // Azul oscuro claro
  accent: '#3182ce',        // Azul acción (botones, links)
  accentLight: '#ebf8ff',   // Azul fondo claro

  // Estados
  success: '#38a169',       // Verde (completado)
  successLight: '#f0fff4',
  warning: '#dd6b20',       // Naranja (en curso)
  warningLight: '#fefcbf',
  error: '#e53e3e',         // Rojo (error)
  errorLight: '#fed7d7',

  // Neutrales
  background: '#f7fafc',    // Fondo general
  surface: '#ffffff',       // Cards, modales
  border: '#e2e8f0',        // Bordes
  borderLight: '#edf2f7',
  
  // Texto
  textPrimary: '#1a2332',
  textSecondary: '#4a5568',
  textMuted: '#718096',
  textDisabled: '#a0aec0',
  textPlaceholder: '#cbd5e0',

  // Post-It
  postIt: '#fffff0',
  postItBorder: '#fefcbf',
  postItText: '#744210',
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
};

export const borderRadius = {
  sm: 6,
  md: 8,
  lg: 10,
  xl: 12,
  full: 9999,
};

export const fontSize = {
  xs: 11,
  sm: 12,
  md: 13,
  base: 14,
  lg: 15,
  xl: 16,
  xxl: 17,
  title: 20,
  header: 24,
};

export const shadows = {
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
};

// Tamaño mínimo de elementos táctiles (accesibilidad)
export const MIN_TOUCH_SIZE = 44;
