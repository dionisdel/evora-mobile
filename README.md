# Evora Mobile (Flutter)

App móvil Evora para instaladores - Búsqueda de farmacias y cuestionarios.

## Requisitos

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio / Xcode para compilación nativa

## Setup

```bash
# Generar archivos de plataforma (si es la primera vez)
flutter create . --org com.evora --project-name evora_mobile

# Instalar dependencias
flutter pub get

# Ejecutar en desarrollo
flutter run
```

## Estructura

```
lib/
├── main.dart              # Entry point
├── router.dart            # GoRouter con auth guard
├── core/                  # Utilidades core
│   ├── api_client.dart    # Dio HTTP client con interceptors
│   ├── secure_storage.dart
│   ├── offline_queue.dart
│   ├── offline_helpers.dart
│   └── navigation_utils.dart
├── models/                # Modelos de datos
│   ├── farmacia.dart
│   ├── ficha_visita.dart
│   ├── foto.dart
│   ├── documento.dart
│   ├── user.dart
│   └── sync_item.dart
├── services/              # Servicios API
│   ├── auth_service.dart
│   ├── farmacia_service.dart
│   ├── cuestionario_service.dart
│   ├── galeria_service.dart
│   ├── visita_service.dart
│   └── actividad_service.dart
├── providers/             # Estado (Riverpod)
│   ├── auth_provider.dart
│   └── sync_provider.dart
├── screens/               # Pantallas
│   ├── login_screen.dart
│   ├── app_shell.dart     # Tab navigator
│   ├── home_screen.dart   # Búsqueda farmacias
│   ├── cuestionario_screen.dart
│   └── mas_screen.dart
├── widgets/               # Componentes reutilizables
│   ├── farmacia_card.dart
│   ├── search_bar_widget.dart
│   ├── sync_indicator.dart
│   ├── post_it_modal.dart
│   └── galeria_view.dart
└── theme/
    └── app_theme.dart
```

## Funcionalidades

- Login con bloqueo tras 5 intentos (15 min cooldown)
- Búsqueda de farmacias con debounce y filtros avanzados
- Cuestionario/Ficha de visita con auto-guardado cada 30s
- Galería de fotos con cámara/galería
- Documentos de actividad con descarga
- Cola offline (FIFO, máx 50 items, 3 reintentos)
- Sincronización automática al recuperar conexión
- Navegación a Google Maps / Apple Maps

## API

Conecta a:
- Dev: `http://10.0.2.2:8003/api/v2/mobile` (emulador Android)
- Prod: `https://e-plataforma.com/api/v2/mobile`

## Build

```bash
flutter build apk --release
flutter build appbundle --release
```
