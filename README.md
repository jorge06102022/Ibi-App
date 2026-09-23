# 🤝 ibi-app — Chat Inclusivo (v2)

Sistema de chat en tiempo real para comunicación entre personas **sordomudas y oyentes**.
Sin login. Sin registro. Solo abre y chatea.



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



