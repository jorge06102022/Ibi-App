from django.urls import path
from . import views

app_name = 'chat'

urlpatterns = [
    path('', views.welcome, name='welcome'),
    path('salas/', views.index, name='index'),
    path('sala/<slug:room_slug>/', views.room_view, name='room'),
    path('api/rooms/', views.get_rooms_api, name='rooms_api'),
    path('api/rooms/create/', views.create_room, name='create_room'),
    path('api/rooms/<slug:room_slug>/delete/', views.delete_room, name='delete_room'),
    path('api/rooms/<slug:room_slug>/clear/', views.clear_room, name='clear_room'),
    path('api/rooms/<slug:room_slug>/messages/', views.get_messages_api, name='messages_api'),
    path('api/sender/', views.set_sender, name='set_sender'),
    path('descargar/<slug:room_slug>/', views.download_history, name='download'),
]