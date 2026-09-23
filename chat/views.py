import json
import uuid
import re
import io
from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse, HttpResponse
from django.views.decorators.http import require_POST, require_GET
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from django.utils.text import slugify
from .models import ChatRoom, Message


# ── Helpers ────────────────────────────────────────────────────
def get_session_id(request):
    if 'cv_session_id' not in request.session:
        request.session['cv_session_id'] = str(uuid.uuid4())
    return request.session['cv_session_id']

def get_sender_name(request):
    return request.session.get('cv_sender_name', 'Anónimo')

def get_sender_color(request):
    return request.session.get('cv_sender_color', '#00D4FF')

COLORS = ['#00D4FF','#7C3AED','#10B981','#F59E0B','#EF4444','#EC4899','#3B82F6','#F97316']

def assign_color(session_id):
    idx = int(session_id.replace('-',''), 16) % len(COLORS)
    return COLORS[idx]


import uuid
from django.shortcuts import render
from django.utils import timezone
from .models import ChatRoom, Message  # <-- Cambiado a ChatRoom

def index(request):
    # Traemos todas las salas usando el modelo correcto
    rooms = ChatRoom.objects.all()  
    
    # Generamos un identificador único para la sesión si no existe
    sid = str(uuid.uuid4())     
    
    # Lista de colores Neon/Futuristas para los avatares
    colors = [
        '#00D4FF', '#7C3AED', '#10B981', '#F59E0B', 
        '#EF4444', '#EC4899', '#3B82F6', '#F97316'
    ]
    
    # Enviamos todo al contexto del HTML de forma limpia
    return render(request, 'chat/index.html', {
        'rooms': rooms,
        'sid': sid,
        'colors': colors,
    })
def room_view(request, room_slug):
    """Vista del chat de una sala."""
    room = get_object_or_404(ChatRoom, name=room_slug)
    sid = get_session_id(request)
    if not request.session.get('cv_sender_color'):
        request.session['cv_sender_color'] = assign_color(sid)
    if not request.session.get('cv_sender_name'):
        request.session['cv_sender_name'] = 'Anónimo'

    messages = room.get_recent_messages(100)
    rooms = ChatRoom.objects.all().order_by('-last_activity')

    return render(request, 'chat/chat.html', {
        'room': room,
        'rooms': rooms,
        'messages': messages,
        'session_id': sid,
        'sender_name': get_sender_name(request),
        'sender_color': get_sender_color(request),
    })


# ── API endpoints ──────────────────────────────────────────────
@csrf_exempt
@require_POST
def create_room(request):
    try:
        body = json.loads(request.body)
        display_name = body.get('name', '').strip()[:80]
        if not display_name:
            return JsonResponse({'ok': False, 'error': 'Nombre requerido'})

        slug = slugify(display_name)[:50]
        if not slug:
            slug = 'sala'

        # Make unique
        base = slug
        i = 1
        while ChatRoom.objects.filter(name=slug).exists():
            slug = f'{base}-{i}'
            i += 1

        room = ChatRoom.objects.create(name=slug, display_name=display_name)
        return JsonResponse({'ok': True, 'slug': room.name, 'display_name': room.display_name})
    except Exception as e:
        return JsonResponse({'ok': False, 'error': str(e)})


@csrf_exempt
@require_POST
def delete_room(request, room_slug):
    room = get_object_or_404(ChatRoom, name=room_slug)
    room.delete()
    return JsonResponse({'ok': True})


@csrf_exempt
@require_POST
def clear_room(request, room_slug):
    room = get_object_or_404(ChatRoom, name=room_slug)
    room.messages.all().delete()
    room.message_count = 0
    room.save(update_fields=['message_count'])
    return JsonResponse({'ok': True})


@csrf_exempt
@require_POST
def set_sender(request):
    try:
        body = json.loads(request.body)
        name = body.get('name', '').strip()[:60]
        color = body.get('color', '#00D4FF')
        if name:
            request.session['cv_sender_name'] = name
        if color:
            request.session['cv_sender_color'] = color
        return JsonResponse({'ok': True, 'name': request.session['cv_sender_name'], 'color': request.session['cv_sender_color']})
    except Exception as e:
        return JsonResponse({'ok': False, 'error': str(e)})


def get_rooms_api(request):
    rooms = ChatRoom.objects.all().order_by('-last_activity')
    data = [{'slug': r.name, 'display_name': r.display_name,
             'message_count': r.message_count,
             'last_activity': r.last_activity.strftime('%d/%m %H:%M')} for r in rooms]
    return JsonResponse({'rooms': data})


def get_messages_api(request, room_slug):
    """Historial de mensajes en JSON — usado por la app nativa Flutter."""
    room = get_object_or_404(ChatRoom, name=room_slug)
    msgs = room.get_recent_messages(200)
    data = [{
        'sender_name': m.sender_name,
        'sender_color': m.sender_color,
        'content': m.content,
        'message_type': m.message_type,
        'timestamp': m.timestamp.strftime('%H:%M'),
    } for m in msgs]
    return JsonResponse({'messages': data})


def download_history(request, room_slug):
    room = get_object_or_404(ChatRoom, name=room_slug)
    msgs = Message.objects.filter(room=room).order_by('timestamp')

    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import cm
        from reportlab.lib import colors
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
        from reportlab.lib.enums import TA_LEFT

        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=A4, topMargin=2*cm, bottomMargin=2*cm,
                                 leftMargin=2*cm, rightMargin=2*cm)
        styles = getSampleStyleSheet()
        story = []

        title_style = ParagraphStyle('T', parent=styles['Title'], fontSize=20, spaceAfter=6)
        sub_style = ParagraphStyle('S', parent=styles['Normal'], fontSize=11,
                                    textColor=colors.HexColor('#666666'), spaceAfter=20)
        msg_name_style = ParagraphStyle('N', parent=styles['Normal'], fontSize=10,
                                         textColor=colors.HexColor('#888888'), spaceAfter=2)
        msg_style = ParagraphStyle('M', parent=styles['Normal'], fontSize=12, spaceAfter=12)

        story.append(Paragraph(f'ConnectVoice — {room.display_name}', title_style))
        story.append(Paragraph(f'Exportado: {timezone.now().strftime("%d/%m/%Y %H:%M")} | {msgs.count()} mensajes', sub_style))
        story.append(Spacer(1, 0.5*cm))

        for msg in msgs:
            icon = '🎙' if msg.message_type == 'voice' else '💬'
            story.append(Paragraph(f'{icon} <b>{msg.sender_name}</b> — {msg.timestamp.strftime("%H:%M")}', msg_name_style))
            story.append(Paragraph(msg.content, msg_style))

        doc.build(story)
        buffer.seek(0)
        resp = HttpResponse(buffer, content_type='application/pdf')
        resp['Content-Disposition'] = f'attachment; filename="connectvoice_{room_slug}.pdf"'
        return resp

    except ImportError:
        lines = [f'ConnectVoice — {room.display_name}\nExportado: {timezone.now().strftime("%d/%m/%Y %H:%M")}\n{"="*50}\n']
        for msg in msgs:
            icon = '[VOZ]' if msg.message_type == 'voice' else '[TEXTO]'
            lines.append(f'{msg.timestamp.strftime("%H:%M")} {msg.sender_name} {icon}\n{msg.content}\n')
        resp = HttpResponse('\n'.join(lines), content_type='text/plain; charset=utf-8')
        resp['Content-Disposition'] = f'attachment; filename="connectvoice_{room_slug}.txt"'
        return resp

def welcome(request):
    """Pantalla de bienvenida CONECTA — primera pantalla que ve el usuario."""
    return render(request, 'chat/welcome.html')