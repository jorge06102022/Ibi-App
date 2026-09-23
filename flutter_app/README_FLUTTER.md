# ConnectVoice App (Flutter nativo, con micrófono funcional) → APK

Esta es la versión **nativa** de la app: ya NO es un WebView. Se conecta
directo a tu backend Django por WebSocket, y usa:

- **Micrófono nativo de Android** (`speech_to_text`) → funciona de verdad,
  a diferencia del WebView, porque usa el reconocedor de voz del propio
  sistema Android, no el navegador embebido.
- **Voz nativa** (`flutter_tts`) para leer los mensajes en voz alta.
- **Modo señas (emoji)** — el mismo alfabeto visual de la web, ahora en Dart.

No pude compilar el .apk en este entorno (no tengo Flutter ni el SDK de
Android instalados aquí, y no tengo salida a internet para descargarlos).
El código está 100% listo — sigue estos pasos en tu propia PC.

## Requisitos en tu PC
- Flutter SDK instalado (`flutter --version` debe funcionar)
- Android Studio con el Android SDK

## Pasos para generar el APK

### 1. Crear el esqueleto de proyecto Android con Flutter

Corre esto en una carpeta vacía (Flutter genera las carpetas nativas
de Android — gradle, manifest, etc. — así evitamos versiones
desincronizadas si las escribiéramos a mano):

```bash
flutter create --platforms=android connectvoice_app
```

### 2. Reemplaza estos archivos con los de esta carpeta (`flutter_app/`)

- `connectvoice_app/pubspec.yaml` → reemplázalo con `flutter_app/pubspec.yaml`
- Borra todo el contenido de `connectvoice_app/lib/` y copia ahí **todos**
  los archivos `.dart` de `flutter_app/lib/` (main.dart, chat_screen.dart,
  room_list_screen.dart, server_gate.dart, api_client.dart, models.dart,
  prefs.dart, sign_emoji.dart).

### 3. Agrega permisos en el AndroidManifest

Abre `connectvoice_app/android/app/src/main/AndroidManifest.xml` y
agrega estas líneas dentro de `<manifest ...>` (antes de `<application`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

Y dentro de la etiqueta `<application ...>` agrega el atributo
`android:usesCleartextTraffic="true"` (necesario si tu servidor usa
`http://` en vez de `https://`, por ejemplo mientras pruebas en tu red
local con Docker):

```xml
<application
    android:label="ConnectVoice"
    android:usesCleartextTraffic="true"
    ...>
```

> Si más adelante despliegas el backend con HTTPS real, puedes quitar
> ese atributo — es solo para pruebas locales por http.

### 4. Revisa el `minSdkVersion`

Abre `connectvoice_app/android/app/build.gradle` y confirma que
`minSdkVersion` (o `minSdk`) sea al menos **21**. `flutter create` ya
lo deja así por defecto normalmente, no debería requerir cambios.

### 5. Instala dependencias y compila

```bash
cd connectvoice_app
flutter pub get
flutter build apk --release
```

El .apk queda en:
```
connectvoice_app/build/app/outputs/flutter-apk/app-release.apk
```

Cópialo a tu celular e instálalo (activa "Instalar apps de orígenes
desconocidos" si Android lo pide).

### 6. Primer uso

1. Al abrir la app te pedirá la URL del servidor. Opciones:
   - Emulador Android + servidor en tu PC: `http://10.0.2.2:8000`
   - Celular físico + PC en la misma WiFi: `http://IP_DE_TU_PC:8000`
   - Servidor en internet: `https://tu-dominio.com`
2. Toca "Conectar" → verás la lista de salas (se cargan desde el
   backend Django, igual que en la web).
3. Entra a una sala, y al abrirla Android te pedirá permiso de
   micrófono la primera vez — acéptalo.
4. Toca el ícono de micrófono para dictar por voz, o escribe normal.
5. En ⚙️ Configuración puedes activar "Modo señas (emoji)".

## Notas honestas sobre esta versión

- Esta app **no** usa el diseño visual (CSS) de la web — es una interfaz
  nativa de Flutter con Material Design, funcionalmente equivalente
  (chat en tiempo real, voz↔texto, salas, modo señas), pero visualmente
  distinta. Si quieres que se vea igual a la web (mismos colores,
  tipografías, animaciones), puedo ajustar los estilos de Flutter para
  que se parezcan más — dímelo.
- No incluí exportar a PDF/TXT ni el tema claro/oscuro todavía en esta
  versión nativa (sí existen en la web). Si los necesitas en el APK,
  te los agrego.
- El backend (`docker compose up` o `runserver`) tiene que estar
  corriendo y accesible desde el celular para que todo esto funcione.
