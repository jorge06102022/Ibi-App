# 🤝 ConnectVoice — Chat Inclusivo (v2)

Sistema de chat en tiempo real para comunicación entre personas **sordomudas y oyentes**.
Sin login. Sin registro. Solo abre y chatea.

---

## ✨ Características

- 💬 **Chat en tiempo real** via WebSockets (Django Channels)
- 🎙 **Voz → Texto** con Web Speech API (Chrome/Edge)
- 🔊 **Texto → Voz** automático al recibir mensajes
- 📁 **Múltiples salas** — crea, usa y conserva historial
- 🌓 **Tema claro / oscuro**
- 📱 **Responsive** — móvil, tablet y PC
- 📄 **Exportar historial** en PDF o TXT
- 🚫 **Sin registro ni login** — completamente anónimo

---

## 🚀 Instalación en 3 pasos

### 1. Entorno virtual e instalar dependencias

```bash
# Crear entorno virtual
python -m venv venv

# Activar (Windows)
venv\Scripts\activate

# Activar (Linux / Mac)
source venv/bin/activate

# Instalar
pip install -r requirements.txt
```

### 2. Preparar la base de datos

```bash
python manage.py makemigrations
python manage.py migrate
```

### 3. Iniciar el servidor

```bash
python manage.py runserver
```

Abre **http://localhost:8000** en Chrome o Edge.

---

## 🗄️ MySQL (opcional, para producción)

```sql
CREATE DATABASE connectvoice_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'cvuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON connectvoice_db.* TO 'cvuser'@'localhost';
```

Descomenta el bloque MySQL en `connectvoice/settings.py` y comenta el SQLite.

---

## ⚡ Redis + Daphne (producción multi-proceso)

```bash
pip install channels-redis redis daphne

# Iniciar con Daphne (ASGI)
daphne -b 0.0.0.0 -p 8000 connectvoice.asgi:application
```

Descomenta el bloque Redis en `settings.py`.

---

## 📁 Estructura

```
connectvoice/
├── connectvoice/        # Configuración Django
│   ├── settings.py
│   ├── urls.py
│   └── asgi.py
├── chat/                # App principal
│   ├── models.py        # ChatRoom, Message
│   ├── views.py         # Vistas + API REST
│   ├── consumers.py     # WebSocket consumer
│   ├── routing.py       # URLs WebSocket
│   ├── urls.py
│   └── templates/chat/
│       ├── chat.html    # Interfaz única (index + sala)
│       └── index.html
├── static/chat/
│   ├── css/main.css     # Sistema de diseño completo
│   └── js/app.js        # WebSocket + Speech + TTS
├── templates/
│   └── base.html
├── manage.py
└── requirements.txt
```

---

## 🎙️ Uso del micrófono

1. **Chrome/Edge obligatorio** — Firefox no soporta Web Speech API
2. Al hacer clic en el botón de micrófono, el navegador pedirá permiso
3. El texto transcrito se envía automáticamente al chat
4. Los mensajes de otros usuarios se leen automáticamente en voz alta
5. Atajo de teclado: **Ctrl+M** para activar/desactivar micrófono

---

## ⚙️ Configuración (en la app)

Haz clic en el ícono ⚙️ para:
- Cambiar tu nombre visible en el chat
- Elegir color de avatar
- Seleccionar voz masculina o femenina
- Ajustar velocidad y volumen
- Cambiar tema claro/oscuro

---

## 🔧 Solución de problemas

**"Voz no disponible"** → Usa Chrome o Edge (no Firefox)

**WebSocket no conecta** → Verifica que el servidor esté corriendo en `localhost:8000`

**PDF no se genera** → Instala `pip install reportlab` (descargará como .txt si no está disponible)

**Migraciones** → `python manage.py makemigrations chat && python manage.py migrate`
