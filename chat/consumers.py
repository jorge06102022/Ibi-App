import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.utils import timezone
from .models import ChatRoom, Message


class ChatConsumer(AsyncWebsocketConsumer):

    async def connect(self):
        self.room_slug = self.scope['url_route']['kwargs']['room_slug']
        self.group_name = f'chat_{self.room_slug}'

        # Verify room exists
        exists = await self.room_exists()
        if not exists:
            await self.close()
            return

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

        # Send participant count update (Corregido sin la propiedad obsoleta _groups)
        await self.broadcast_presence()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.group_name, self.channel_name)
        await self.broadcast_presence()

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            t = data.get('type')

            if t == 'chat_message':
                await self.handle_message(data)
            elif t == 'voice_message':
                await self.handle_message(data, is_voice=True)
            elif t == 'typing':
                await self.handle_typing(data)
            elif t == 'clear_room':
                await self.handle_clear(data)
        except Exception as e:
            await self.send(text_data=json.dumps({'type': 'error', 'msg': str(e)}))

    async def handle_message(self, data, is_voice=False):
        content = data.get('content', '').strip()
        if not content:
            return
        sender_name = data.get('sender_name', 'Anónimo')[:60]
        sender_color = data.get('sender_color', '#00D4FF')
        session_id = data.get('session_id', '')

        msg = await self.save_message(content, sender_name, sender_color, is_voice)

        await self.channel_layer.group_send(self.group_name, {
            'type': 'broadcast_message',
            'msg_id': msg.id,
            'content': content,
            'sender_name': sender_name,
            'sender_color': sender_color,
            'message_type': 'voice' if is_voice else 'text',
            'timestamp': msg.timestamp.strftime('%H:%M'),
            'session_id': session_id,
        })

    async def handle_typing(self, data):
        await self.channel_layer.group_send(self.group_name, {
            'type': 'broadcast_typing',
            'sender_name': data.get('sender_name', 'Alguien'),
            'is_typing': data.get('is_typing', False),
            'channel': self.channel_name,
        })

    async def handle_clear(self, data):
        await self.delete_messages()
        await self.channel_layer.group_send(self.group_name, {
            'type': 'broadcast_clear',
        })

    # ── Broadcast handlers ──────────────────────────────────
    async def broadcast_message(self, event):
        await self.send(text_data=json.dumps({
            'type': 'message',
            'msg_id': event['msg_id'],
            'content': event['content'],
            'sender_name': event['sender_name'],
            'sender_color': event['sender_color'],
            'message_type': event['message_type'],
            'timestamp': event['timestamp'],
            'session_id': event['session_id'],
        }))

    async def broadcast_typing(self, event):
        if event['channel'] != self.channel_name:
            await self.send(text_data=json.dumps({
                'type': 'typing',
                'sender_name': event['sender_name'],
                'is_typing': event['is_typing'],
            }))

    async def broadcast_clear(self, event):
        await self.send(text_data=json.dumps({'type': 'cleared'}))

    async def presence_update(self, event):
        await self.send(text_data=json.dumps({
            'type': 'presence',
            'count': event['count'],
        }))

    # ── DB helpers ──────────────────────────────────────────
    @database_sync_to_async
    def room_exists(self):
        # Corregido para buscar en el campo 'name' que es el que almacena tu slug/identificador único
        return ChatRoom.objects.filter(name=self.room_slug).exists()

    @database_sync_to_async
    def save_message(self, content, sender_name, sender_color, is_voice):
        room = ChatRoom.objects.get(name=self.room_slug)
        msg = Message.objects.create(
            room=room,
            sender_name=sender_name,
            sender_color=sender_color,
            content=content,
            message_type='voice' if is_voice else 'text',
            timestamp=timezone.now(),
        )
        room.last_activity = timezone.now()
        room.message_count = room.messages.count()
        room.save(update_fields=['last_activity', 'message_count'])
        return msg

    @database_sync_to_async
    def delete_messages(self):
        room = ChatRoom.objects.get(name=self.room_slug)
        room.messages.all().delete()
        room.message_count = 0
        room.save(update_fields=['message_count'])

    async def broadcast_presence(self):
        try:
            # Consulta segura de los canales activos en este grupo
            group = self.channel_layer.groups.get(self.group_name, {})
            count = len(group)
        except Exception:
            count = 0
            
        await self.channel_layer.group_send(self.group_name, {
            'type': 'presence_update',
            'count': count,
        })