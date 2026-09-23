import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.sessions import SessionMiddlewareStack

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'connectvoice.settings')
django_asgi_app = get_asgi_application()

import chat.routing

application = ProtocolTypeRouter({
    'http': django_asgi_app,
    'websocket': SessionMiddlewareStack(
        URLRouter(chat.routing.websocket_urlpatterns)
    ),
})
