# AstroIO — App Android (APK oficial del juego)

Carpeta donde vive la **APK de AstroIO**: un envoltorio WebView
optimizado para **ahorrar datos móviles** y con **auto-actualización
interna** + **protecciones de seguridad**.

```
apk/
├── android/                  ← proyecto Android Studio (sin dependencias externas)
│   ├── settings.gradle
│   ├── build.gradle
│   ├── gradle.properties
│   └── app/
│       ├── build.gradle      ← versionCode / versionName / firma release
│       ├── proguard-rules.pro
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── java/com/astroio/game/
│           │   ├── MainActivity.java       ← WebView + interceptor + auto-update
│           │   ├── SecurityGuard.java      ← firma oficial / anti APK Editor / anti debug
│           │   └── UpdateFileProvider.java ← entrega el APK de actualización al instalador
│           ├── res/            (icono, layout, textos en español)
│           └── assets/game/    ← (SE GENERA) imágenes del juego copiadas por el script
├── copiar_assets.sh / .bat   ← copia las imágenes del juego a los assets de la APK
├── keystore/
│   └── astroio-release.p12   ← certificado de firma oficial (¡NO perder!)
├── server/
│   ├── version.json          ← plantilla que se sube al servidor
│   └── LEEME-SERVIDOR.txt    ← cómo publicar una actualización en el servidor
└── README.md                 ← este archivo
```

## Qué hace la app

1. **Ahorro de datos**: las imágenes del tema del juego
   (`styles/theme/gow/…`: edificios, planetas, iconos, banderas, etc.)
   van DENTRO de la APK. El WebView sirve esas imágenes desde el
   teléfono (`shouldInterceptRequest`) y solo descarga de Internet lo
   que no tiene guardado (HTML, JSON y demás).

2. **Auto-actualización interna**: al abrir la app se lee
   `https://astroio.duckdns.org/apk/version.json`.
   - Si el `versionCode` del servidor es mayor → descarga la nueva APK,
     verifica su SHA-256 y la instala. **No deja entrar al juego hasta
     que la app esté actualizada.**
   - Si es igual → entra al juego.
   - Si el archivo aún no existe → entra al juego (primera puesta en
     marcha).
   - Si hay error de conexión → aviso genérico, **sin mostrar nunca el
     dominio ni el DNS del servidor**. El dominio está guardado ofuscado
     (XOR) dentro del código, no aparece en texto plano.

3. **Protecciones de seguridad**:
   - Comprobación del **certificado de firma** (hash SHA-256 fijo en el
     código): si la APK se edita con APK Editor y se vuelve a firmar, la
     app se bloquea con "Aplicación modificada".
   - Detección de **apps de edición/patcheo** conocidas (APK Editor,
     Lucky Patcher…): no deja entrar mientras estén instaladas.
   - Bloqueo de **versión de depuración** y de **debugger conectado**.
   - Verificación **SHA-256** del APK descargado antes de instalarlo.
   - Ofuscación de código con **R8/ProGuard** (minifyEnabled).
   - Dominio del servidor **ofuscado** (XOR) y ausente en los mensajes
     de error.

## Cómo compilar

### Automático (recomendado)
Cada push que toque `apk/**` dispara el workflow
`.github/workflows/build-apk.yml`, que copia las imágenes, compila la
APK **firmada**, calcula el SHA-256 y genera `AstroIO.apk` +
`version.json` (artefacto y Release `apk-vX`). Solo hay que descargarlos
y subirlos al servidor (ver `server/LEEME-SERVIDOR.txt`).

### Manual (Android Studio)
1. Ejecuta `apk/copiar_assets.bat` (Windows) o `bash apk/copiar_assets.sh`
   (Linux/Mac) para copiar las imágenes del juego.
2. Abre la carpeta `apk/android` en Android Studio y compila
   `assembleRelease` (la firma ya está configurada en `app/build.gradle`).

## Para publicar una nueva versión

1. Sube `versionCode` (+1) y `versionName` en
   `apk/android/app/build.gradle`.
2. Push a la rama `Xnovaaaa` → descarga la APK y el `version.json`
   del workflow.
3. Súbelos por FTP a `/apk/` (ver `server/LEEME-SERVIDOR.txt`).

## Certificado de firma

- Archivo: `apk/keystore/astroio-release.p12`
- Contraseña: `AstroIO_key_2024` (alias `astroio`)
- **Guarda este archivo con cuidado**: si se pierde, las actualizaciones
  ya no se podrán instalar sobre la app existente (Android exige la misma
  firma). Su hash SHA-256 está fijado en `SecurityGuard.java`; si cambias
  de certificado, actualiza ese hash.
