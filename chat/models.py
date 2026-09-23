from django.db import models
from django.utils import timezone


class ChatRoom(models.Model):
    name = models.CharField(max_length=80, unique=True)
    display_name = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    last_activity = models.DateTimeField(default=timezone.now)
    message_count = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.display_name

    def get_recent_messages(self, limit=100):
        return list(self.messages.order_by('timestamp')[:limit])

    class Meta:
        verbose_name = 'Sala de Chat'
        verbose_name_plural = 'Salas de Chat'
        ordering = ['-last_activity']


class Message(models.Model):
    TYPE_TEXT = 'text'
    TYPE_VOICE = 'voice'
    TYPE_CHOICES = [(TYPE_TEXT, 'Texto'), (TYPE_VOICE, 'Voz')]

    room = models.ForeignKey(ChatRoom, on_delete=models.CASCADE, related_name='messages')
    # Nombre libre — sin usuario registrado
    sender_name = models.CharField(max_length=60, default='Anónimo')
    sender_color = models.CharField(max_length=7, default='#00D4FF')
    content = models.TextField()
    message_type = models.CharField(max_length=10, choices=TYPE_CHOICES, default=TYPE_TEXT)
    timestamp = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f'[{self.sender_name}] {self.content[:50]}'

    class Meta:
        verbose_name = 'Mensaje'
        verbose_name_plural = 'Mensajes'
        ordering = ['timestamp']
