# Guía de Despliegue — Evora Mobile

## Prerrequisitos

1. Cuenta [Expo](https://expo.dev) (gratis)
2. Cuenta [Google Play Console](https://play.google.com/console) ($25 una vez)
3. Cuenta [Apple Developer Program](https://developer.apple.com) ($99/año)
4. Node.js 20+ instalado
5. EAS CLI: `npm install -g eas-cli`

## Setup inicial (una sola vez)

```bash
# Login en Expo
eas login

# Vincular proyecto
eas init

# Configurar credenciales Android (genera keystore)
eas credentials --platform android

# Configurar credenciales iOS (requiere Apple Developer account)
eas credentials --platform ios
```

## Builds

### Development (testing interno)
```bash
# APK de desarrollo para Android (distribución interna)
eas build --platform android --profile preview

# iOS simulator build
eas build --platform ios --profile development
```

### Production
```bash
# Build Android (AAB para Play Store)
eas build --platform android --profile production

# Build iOS (IPA para App Store)
eas build --platform ios --profile production
```

## Publicar en Stores

### Google Play
1. Generar build: `eas build --platform android --profile production`
2. Descargar AAB desde [expo.dev](https://expo.dev)
3. Subir a Google Play Console → Internal Testing
4. Promover a Production cuando esté validado

### Apple App Store
1. Generar build: `eas build --platform ios --profile production`
2. Submit automático: `eas submit --platform ios`
3. Esperar review de Apple (1-3 días)

## OTA Updates (sin pasar por stores)

Para correcciones JS (no cambios nativos):
```bash
# Publicar update
eas update --branch production --message "Fix: descripción del cambio"
```

Los usuarios reciben la actualización al abrir la app (sin re-descargar).

## Entornos

| Entorno | API Base URL | Build Profile |
|---------|-------------|---------------|
| Local | `http://localhost:8003/api/v2/mobile` | development |
| Staging | `https://dev.e-plataforma.com/api/v2/mobile` | preview |
| Producción | `https://e-plataforma.com/api/v2/mobile` | production |

Para cambiar el entorno, la app detecta `__DEV__` automáticamente.
Para staging, crear un `.env.staging` con la URL correspondiente.

## Checklist pre-publicación

- [ ] Iconos y splash screen generados (1024x1024 icon, 1284x2778 splash)
- [ ] Version bumped en `app.json`
- [ ] Tests manuales en dispositivo real (iOS + Android)
- [ ] API de producción desplegada (`api/v2/mobile/` en el servidor)
- [ ] JWT_SECRET configurado en `.env` de producción
- [ ] Probar login con usuario real de producción
- [ ] Verificar que el vhost apunta correctamente

## Mantenimiento

- **Actualizar dependencias**: `npx expo install --check`
- **Audit vulnerabilidades**: `npm audit`
- **Logs**: Los errores se logean en `logs/api-v2-mobile.log` en el servidor
