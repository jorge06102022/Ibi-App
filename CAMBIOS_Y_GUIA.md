# ConnectVoice — Cambios aplicados y guía paso a paso

## ✅ Qué se agregó / cambió

1. **Modo señas (emoji)** — `static/chat/js/app.js` + `chat/templates/chat/chat.html`
   - Diccionario `SIGN_EMOJI_MAP`: convierte cada letra en un emoji de mano.
   - Toggle en ⚙️ Configuración → "Modo señas (emoji)".
   - Botón 🤲 en cada mensaje para alternar ese mensaje puntual entre texto y señas.
   - **Importante — léelo antes de usarlo en producción:** esto es un
     alfabeto visual de apoyo hecho con emoji genéricos, **no es una
     traducción oficial ni certificada a Lengua de Señas Colombiana (LSC)**.
     Generar una traducción real a LSC requeriría animaciones/video de un
     intérprete o un avatar 3D entrenado específicamente para eso — es un
     proyecto mucho más grande (y con contenido con derechos, o modelos de
     IA especializados). Si tu meta final es una traducción certificada,
     cuéntame y lo planeamos aparte; esto que agregué es un "modo visual"
     estético y lúdico, útil como apoyo pero no un reemplazo de intérprete.

2. **Docker** — `Dockerfile`, `docker-compose.yml`, `.dockerignore`
   - `docker-compose up` levanta el backend (Daphne) + Redis para producción
     real con WebSockets multi-proceso.
   - `connectvoice/settings.py` ahora lee `REDIS_URL` del entorno: si está
     vacía usa memoria (desarrollo), si tiene valor usa Redis (Docker/prod).

3. **App Android nativa (Flutter — con micrófono funcional)** — carpeta `flutter_app/`
   - Ya NO es un WebView. Es una app Flutter nativa que habla directo por
     WebSocket con tu backend Django, con micrófono nativo (`speech_to_text`)
     y voz nativa (`flutter_tts`). Esto sí soporta el reconocimiento de voz
     de verdad dentro del APK, a diferencia de un WebView.
   - Para que la app nativa pueda listar/crear/borrar salas, se agregó un
     endpoint JSON de historial (`/api/rooms/<slug>/messages/`) y se quitó
     la validación CSRF de los endpoints de sala (`create/delete/clear/sender`)
     — es seguro porque la app ya era pública y sin login desde el inicio;
     si vas a exponerla a internet sin control de acceso, ten eso en cuenta.
   - **No pude compilar el .apk en este entorno** (no tengo Flutter ni el
     SDK de Android instalados aquí, y no tengo salida a internet para
     descargarlos). El código está completo — sigue
     `flutter_app/README_FLUTTER.md` en tu PC para generar el .apk (son
     pocos pasos, la mayoría es copiar archivos y correr `flutter build apk`).
   - Diferencia de esta versión: usa una interfaz nativa Material Design,
     no el mismo diseño visual de la web. Si quieres que se vea igual,
     lo ajustamos después.

---

## 🚀 Cómo correrlo (elige una opción)

### Opción A — Local, simple (sin Docker), como ya lo tenías

```bash
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

python manage.py makemigrations
python manage.py migrate

python manage.py runserver
```

Abre `http://localhost:8000` en Chrome o Edge.

### Opción B — Con Docker (recomendado para "producción" / probar desde el celular)

Requisitos: tener Docker y Docker Compose instalados.

```bash
docker compose up --build
```

Esto levanta:
- `web`: tu app Django corriendo con Daphne en el puerto 8000
- `redis`: para que el chat en tiempo real soporte múltiples procesos/usuarios

Abre `http://localhost:8000` (o `http://IP_DE_TU_PC:8000` desde otro
dispositivo en la misma red, por ejemplo tu celular con la app APK).

Para pararlo: `Ctrl+C` y luego `docker compose down`.

Variables de entorno configurables (ver `docker-compose.yml` o copia
`.env.example` a `.env`):
- `SECRET_KEY`
- `DEBUG` (pon `False` en producción real)
- `ALLOWED_HOSTS`
- `REDIS_URL`

### Opción C — Generar el APK con Flutter

Ve a `flutter_app/README_FLUTTER.md` — ahí están los pasos completos,
incluyendo cómo apuntar la app al servidor (local, Docker, o en internet).

---

## 🧪 Probar el modo señas

1. Corre el servidor (Opción A o B).
2. Entra a una sala de chat.
3. Abre ⚙️ Configuración → activa "Modo señas (emoji)" → Guardar.
4. Envía un mensaje: en vez de letras verás el deletreo con emoji.
5. Puedes tocar el ícono 🤲 en cualquier mensaje individual para
   alternarlo entre texto y señas sin cambiar tu preferencia global.
