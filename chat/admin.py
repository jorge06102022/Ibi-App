from django.contrib import admin
from .models import ChatRoom, Message

@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['display_name', 'name', 'message_count', 'last_activity', 'created_at']
    search_fields = ['display_name', 'name']

@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['sender_name', 'room', 'message_type', 'short_content', 'timestamp']
    list_filter = ['message_type', 'room']
    search_fields = ['sender_name', 'content']
    date_hierarchy = 'timestamp'

    def short_content(self, obj):
        return obj.content[:60] + '…' if len(obj.content) > 60 else obj.content
    short_content.short_description = 'Contenido'

admin.site.site_header = 'ConnectVoice Admin'
admin.site.site_title = 'ConnectVoice'
admin.site.index_title = 'Panel de Administración'
