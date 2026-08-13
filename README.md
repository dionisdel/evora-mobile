# Evora Mobile - App Instaladores

Aplicación móvil multiplataforma (iOS + Android) para instaladores de Evora. Desarrollada con React Native + Expo + TypeScript.

## Requisitos

- Node.js 20 LTS o superior
- npm o yarn
- Expo Go instalado en dispositivo móvil (para desarrollo)

## Setup

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo
npm start

# Escanear QR con Expo Go en tu móvil
```

## Estructura del Proyecto

```
evora-mobile/
├── app/                    # Pantallas (Expo Router - file-based routing)
│   ├── _layout.tsx         # Root layout (auth guard)
│   ├── login.tsx           # Pantalla de login
│   └── (auth)/             # Grupo de rutas autenticadas
│       ├── _layout.tsx     # Tab navigator
│       ├── index.tsx       # Búsqueda de farmacias (pantalla principal)
│       ├── cuestionario/   # Cuestionario dinámico
│       └── mas/            # Menú secundario (Actividad + Galería)
├── src/
│   ├── services/           # Capa de comunicación con API Evora
│   ├── hooks/              # Custom hooks (auth, location, offline)
│   ├── components/         # Componentes reutilizables
│   ├── store/              # Estado global (Zustand)
│   ├── types/              # Interfaces TypeScript
│   └── utils/              # Utilidades (storage, queue, navigation)
├── assets/                 # Iconos, splash screen, fuentes
├── app.json                # Configuración Expo
├── eas.json                # Configuración EAS Build
└── tsconfig.json           # TypeScript config
```

## Scripts

| Script | Descripción |
|--------|-------------|
| `npm start` | Inicia Expo dev server |
| `npm run android` | Abre en Android |
| `npm run ios` | Abre en iOS |
| `npm run lint` | Ejecuta ESLint |
| `npm run typecheck` | Verifica tipos TypeScript |

## Arquitectura

La app es un **thin client** que consume exclusivamente la API REST de la plataforma web Evora:

- **Sin lógica de negocio local** — toda la lógica vive en el backend PHP
- **Sin datos maestros persistentes** — solo caché temporal y cola offline
- **Autenticación delegada** — JWT emitido por la plataforma web

## API Backend

La app consume endpoints en `/api/v2/mobile/` publicados por la plataforma web existente. Ver documentación en el repo `evora-plataforma`.

## Builds

```bash
# Build de desarrollo (APK para testing)
npx eas build --platform android --profile preview

# Build de producción
npx eas build --platform all --profile production
```

## Entornos

| Entorno | Backend |
|---------|---------|
| Desarrollo | `http://evora.test/api/v2/mobile` |
| Staging | `https://evora-plataforma-dev.es.mialias.net/api/v2/mobile` |
| Producción | `https://e-plataforma.com/api/v2/mobile` |
