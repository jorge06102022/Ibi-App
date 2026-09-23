from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    # Agregamos el ^ justo antes de ws/
    re_path(r'^ws/chat/(?P<room_slug>[\w-]+)/$', consumers.ChatConsumer.as_asgi()),
]