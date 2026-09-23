import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'api_client.dart';
import 'models.dart';
import 'prefs.dart';
import 'sign_emoji.dart';
import 'sign_keyboard.dart';
import 'theme.dart';
import 'hand_avatar_3d.dart';

class ChatScreen extends StatefulWidget {
  final Prefs prefs;
  final String serverUrl;
  final Room room;

  const ChatScreen({
    super.key,
    required this.prefs,
    required this.serverUrl,
    required this.room,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ApiClient _api = ApiClient(widget.serverUrl);
  late final String _sessionId = widget.prefs.sessionId;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  bool _connected = false;
  int _reconnectAttempts = 0;
  static const _maxReconnects = 6;

  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _listening = false;
  String _interimText = '';

  final FlutterTts _tts = FlutterTts();

  bool _signMode = false;

  // ── Teclado de señas ──────────────────────────────────────
  bool _signKeyboardOpen = false;
  final _textFocusNode = FocusNode();

  // ── Avatar de deletreo visual (letra por letra) ────────────
  final GlobalKey<HandAvatar3DState> _handAvatarKey = GlobalKey<HandAvatar3DState>();
  List<String> _avatarSigns = [];
  int _avatarIndex = 0;
  Timer? _avatarTimer;
  bool _avatarActive = false;
  String _avatarEmoji = '🤟';
  String _avatarWord = '';

  @override
  void initState() {
    super.initState();
    _signMode = widget.prefs.signMode;
    _loadHistory();
    _connectWs();
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _channel?.sink.close();
    _speech.stop();
    _tts.stop();
    _avatarTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // ── Historial inicial ────────────────────────────────────
  Future<void> _loadHistory() async {
    try {
      final msgs = await _api.getMessages(widget.room.slug);
      setState(() => _messages.addAll(msgs));
      _scrollToBottom();
    } catch (_) {
      // Si falla, simplemente empieza con historial vacío.
    }
  }

  // ── WebSocket ─────────────────────────────────────────────
  void _connectWs() {
    final url = '${_api.wsBaseUrl}/ws/chat/${widget.room.slug}/';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      _scheduleReconnect();
      return;
    }

    _wsSub = _channel!.stream.listen(
      (raw) => _handleWsMessage(jsonDecode(raw)),
      onError: (_) => _handleDisconnect(),
      onDone: _handleDisconnect,
    );

    setState(() { _connected = true; _reconnectAttempts = 0; });
  }

  void _handleDisconnect() {
    if (!mounted) return;
    setState(() => _connected = false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnects) return;
    _reconnectAttempts++;
    final delay = Duration(milliseconds: (1000 * (1 << _reconnectAttempts)).clamp(1000, 20000));
    Future.delayed(delay, () {
      if (mounted) _connectWs();
    });
  }

  void _handleWsMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'message':
        final isOwn = data['session_id'] == _sessionId;
        final msg = ChatMessage(
          msgId: data['msg_id'],
          senderName: data['sender_name'],
          senderColor: data['sender_color'],
          content: data['content'],
          messageType: data['message_type'],
          timestamp: data['timestamp'],
          isOwn: isOwn,
        );
        setState(() => _messages.add(msg));
        _scrollToBottom();
        if (msg.messageType == 'text') _speak(msg.content);
        
        // Animamos el avatar tanto para nuestros mensajes como los de otros
        _playAvatarSigns(msg.content);
        break;
      case 'cleared':
        setState(() => _messages.clear());
        break;
      case 'error':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${data['msg']}')));
        break;
      // 'typing' y 'presence' se ignoran en esta versión simplificada.
    }
  }

  void _sendWs(Map<String, dynamic> obj) {
    if (_channel != null && _connected) {
      _channel!.sink.add(jsonEncode(obj));
    }
  }

  // ── Avatar de deletreo visual ──────────────────────────────
  // Deletrea con emoji-señas lo que la otra persona dijo/escribió,
  // letra por letra. NO es una traducción oficial a LSC (no existe
  // seña por palabra completa aquí, solo el alfabeto visual de apoyo).
  void _playAvatarSigns(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    // Pedir a la mano 3D que deletree el texto
    _handAvatarKey.currentState?.spell(clean);

    final raw = textToSignEmojis(clean);
    final parts = raw.split(' ').where((s) => s.trim().isNotEmpty).toList();
    if (parts.isEmpty) return;

    _avatarTimer?.cancel();
    setState(() {
      _avatarSigns = parts;
      _avatarIndex = 0;
      _avatarActive = true;
      _avatarEmoji = parts[0];
      _avatarWord = clean;
    });
    _avatarTimer = Timer.periodic(const Duration(milliseconds: 480), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _avatarIndex++;
        if (_avatarIndex >= _avatarSigns.length) {
          t.cancel();
          _avatarActive = false;
        } else {
          _avatarEmoji = _avatarSigns[_avatarIndex];
        }
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Enviar mensajes ───────────────────────────────────────
  void _sendText() {
    final txt = _textController.text.trim();
    if (txt.isEmpty) return;
    _sendWs({
      'type': 'chat_message',
      'content': txt,
      'sender_name': widget.prefs.senderName,
      'sender_color': widget.prefs.senderColor,
      'session_id': _sessionId,
    });
    _textController.clear();
  }

  void _sendVoiceText(String txt) {
    if (txt.trim().isEmpty) return;
    _sendWs({
      'type': 'voice_message',
      'content': txt.trim(),
      'sender_name': widget.prefs.senderName,
      'sender_color': widget.prefs.senderColor,
      'session_id': _sessionId,
    });
  }

  // ── Micrófono nativo (speech_to_text — usa el reconocedor de Android) ──
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _listening = false);
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() => _listening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de micrófono: ${err.errorMsg}')),
          );
        }
      },
    );
    setState(() {});
  }

  Future<void> _toggleMic() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Micrófono no disponible. Revisa permisos de la app en Ajustes.')),
      );
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() { _listening = true; _interimText = ''; });
    await _speech.listen(
      localeId: 'es_CO',
      onResult: (result) {
        setState(() => _interimText = result.recognizedWords);
        if (result.finalResult) {
          _sendVoiceText(result.recognizedWords);
          setState(() => _interimText = '');
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  // ── Texto a voz nativo (flutter_tts) ──────────────────────
  Future<void> _initTts() async {
    await _tts.setLanguage('es-CO');
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.setSpeechRate(widget.prefs.voiceSpeed * 0.5); // flutter_tts usa otra escala
    await _tts.setVolume(widget.prefs.voiceVolume);
    final voices = await _tts.getVoices;
    if (voices is List) {
      final wantFemale = widget.prefs.voiceGender == 'female';
      final keys = wantFemale
          ? ['female', 'mujer', 'femenin']
          : ['male', 'hombre', 'mascul'];
      for (final v in voices) {
        final name = (v['name'] ?? '').toString().toLowerCase();
        final locale = (v['locale'] ?? '').toString().toLowerCase();
        if (locale.startsWith('es') && keys.any((k) => name.contains(k))) {
          await _tts.setVoice({
            'name': v['name'].toString(),
            'locale': v['locale'].toString(),
          });
          break;
        }
      }
    }
    await _tts.speak(text);
  }

  // ── Modo señas ─────────────────────────────────────────────
  void _toggleSignMode(bool value) {
    setState(() => _signMode = value);
    widget.prefs.setSignMode(value);
  }

  // ── Teclado de señas ─────────────────────────────────────────
  void _toggleSignKeyboard() {
    setState(() => _signKeyboardOpen = !_signKeyboardOpen);
    if (_signKeyboardOpen) {
      _textFocusNode.requestFocus();
    } else {
      _textFocusNode.unfocus();
    }
  }

  // ── Settings ────────────────────────────────────────────────
  Future<void> _openSettings() async {
    String name = widget.prefs.senderName;
    String color = widget.prefs.senderColor;
    String gender = widget.prefs.voiceGender;
    double speed = widget.prefs.voiceSpeed;
    double volume = widget.prefs.voiceVolume;
    bool signMode = _signMode;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r4)),
            ),
            padding: EdgeInsets.only(
              left: 22, right: 22, top: 14,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.bg5, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Configuración',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.tx1)),
                const SizedBox(height: 18),

                const Text('Tu nombre', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
                const SizedBox(height: 6),
                TextField(
                  style: const TextStyle(color: AppColors.tx1),
                  decoration: const InputDecoration(hintText: 'Escribe tu nombre'),
                  controller: TextEditingController(text: name),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 18),

                const Text('Color', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: Prefs.colors.map((c) {
                    final selected = c == color;
                    final col = Color(int.parse(c.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setSheet(() => color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? AppColors.tx1 : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: col.withOpacity(0.6), blurRadius: 10)]
                              : null,
                        ),
                        child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                const Text('Voz', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceChip(
                        label: 'Femenina',
                        icon: Icons.face_3_rounded,
                        selected: gender == 'female',
                        onTap: () => setSheet(() => gender = 'female'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ChoiceChip(
                        label: 'Masculina',
                        icon: Icons.face_rounded,
                        selected: gender == 'male',
                        onTap: () => setSheet(() => gender = 'male'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(Icons.speed_rounded, size: 16, color: AppColors.tx2),
                    const SizedBox(width: 6),
                    const Text('Velocidad', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
                    const Spacer(),
                    Text(speed.toStringAsFixed(1), style: const TextStyle(color: AppColors.accent, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                  value: speed, min: 0.5, max: 2.0, divisions: 15,
                  onChanged: (v) => setSheet(() => speed = v),
                ),

                Row(
                  children: [
                    const Icon(Icons.volume_up_rounded, size: 16, color: AppColors.tx2),
                    const SizedBox(width: 6),
                    const Text('Volumen', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
                    const Spacer(),
                    Text('${(volume * 100).round()}%', style: const TextStyle(color: AppColors.accent, fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                  value: volume, min: 0.0, max: 1.0, divisions: 10,
                  onChanged: (v) => setSheet(() => volume = v),
                ),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(AppRadius.r3),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Text('🤟', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Modo señas (emoji)',
                                style: TextStyle(color: AppColors.tx1, fontWeight: FontWeight.w600, fontSize: 13.5)),
                            const SizedBox(height: 2),
                            const Text(
                              'Deletreo visual con emoji, no reemplaza a un intérprete certificado.',
                              style: TextStyle(color: AppColors.tx3, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(value: signMode, onChanged: (v) => setSheet(() => signMode = v)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                GradientButton(
                  label: 'Guardar',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    await widget.prefs.setSenderName(name.isEmpty ? 'Anónimo' : name);
                    await widget.prefs.setSenderColor(color);
                    await widget.prefs.setVoiceGender(gender);
                    await widget.prefs.setVoiceSpeed(speed);
                    await widget.prefs.setVoiceVolume(volume);
                    _toggleSignMode(signMode);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: Text(widget.room.displayName),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (_connected ? AppColors.accent3 : AppColors.danger).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: _connected ? AppColors.accent3 : AppColors.danger),
                const SizedBox(width: 6),
                Text(
                  _connected ? 'En línea' : 'Sin conexión',
                  style: TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w600,
                    color: _connected ? AppColors.accent3 : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.settings_rounded), onPressed: _openSettings),
          const SizedBox(width: 4),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg0, AppColors.bg1],
          ),
        ),
        child: Column(
          children: [
            _AvatarPanel(
              active: _avatarActive,
              emoji: _avatarEmoji,
              word: _avatarWord,
              handKey: _handAvatarKey,
            ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.waving_hand_rounded, color: AppColors.accent, size: 28),
                          ),
                          const SizedBox(height: 14),
                          const Text('Todavía no hay mensajes', style: TextStyle(color: AppColors.tx2)),
                          const SizedBox(height: 4),
                          const Text('Escribe o usa el micrófono para empezar',
                              style: TextStyle(color: AppColors.tx3, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                      itemCount: _messages.length,
                      itemBuilder: (ctx, i) => _MessageBubble(
                        msg: _messages[i],
                        globalSignMode: _signMode,
                      ),
                    ),
            ),
            if (_listening)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.r3),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const _PulsingMicDot(),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _interimText.isEmpty ? 'Escuchando…' : _interimText,
                        style: const TextStyle(color: AppColors.tx1),
                      ),
                    ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _CircleIconButton(
                      icon: Icons.back_hand_rounded,
                      active: _signKeyboardOpen,
                      onTap: _toggleSignKeyboard,
                    ),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      active: _listening,
                      onTap: _toggleMic,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bg2,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          readOnly: _signKeyboardOpen,
                          showCursor: true,
                          style: const TextStyle(color: AppColors.tx1),
                          maxLines: 4,
                          minLines: 1,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje…',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendText(),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleIconButton(
                      icon: Icons.send_rounded,
                      gradient: true,
                      onTap: _sendText,
                    ),
                  ],
                ),
              ),
            ),
            if (_signKeyboardOpen)
              SignKeyboard(
                controller: _textController,
                onSend: _sendText,
                onChanged: () => setState(() {}),
              ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPanel extends StatelessWidget {
  final bool active;
  final String emoji;
  final String word;
  final GlobalKey<HandAvatar3DState> handKey;

  const _AvatarPanel({
    super.key,
    required this.active,
    required this.emoji,
    required this.word,
    required this.handKey,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(AppRadius.r3),
        border: Border.all(
          color: active ? AppColors.accent.withOpacity(0.4) : AppColors.border,
        ),
        boxShadow: active
            ? [BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 16)]
            : null,
      ),
      child: Column(
        children: [
          // ── Área grande para la mano 3D ──
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: HandAvatar3D(key: handKey),
          ),
          const SizedBox(height: 8),
          // ── Texto de estado ──
          Text(
            active ? 'Deletreando: $word' : 'Avatar de señas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? AppColors.accent : AppColors.tx2,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          if (!active)
            const Text(
              'Deletreo visual — no es LSC oficial',
              style: TextStyle(color: AppColors.tx3, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _PulsingMicDot extends StatefulWidget {
  const _PulsingMicDot();
  @override
  State<_PulsingMicDot> createState() => _PulsingMicDotState();
}

class _PulsingMicDotState extends State<_PulsingMicDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
      child: const Icon(Icons.mic_rounded, color: AppColors.danger, size: 18),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool gradient;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap, this.active = false, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    final bg = gradient
        ? null
        : (active ? AppColors.danger.withOpacity(0.15) : AppColors.bg2);
    final iconColor = gradient ? Colors.white : (active ? AppColors.danger : AppColors.tx2);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 46, height: 46,
          decoration: BoxDecoration(
            gradient: gradient ? AppColors.brandGradient : null,
            color: bg,
            shape: BoxShape.circle,
            border: active ? Border.all(color: AppColors.danger.withOpacity(0.4)) : null,
          ),
          child: Icon(icon, color: iconColor, size: 21),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.r2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r2),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent.withOpacity(0.14) : AppColors.bg2,
            borderRadius: BorderRadius.circular(AppRadius.r2),
            border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.accent : AppColors.tx2),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: selected ? AppColors.accent : AppColors.tx2, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage msg;
  final bool globalSignMode;
  const _MessageBubble({required this.msg, required this.globalSignMode});

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  bool? _localOverride; // null = usa el modo global

  @override
  Widget build(BuildContext context) {
    final showSigns = _localOverride ?? widget.globalSignMode;
    final displayText = showSigns ? textToSignEmojis(widget.msg.content) : widget.msg.content;
    final senderColor = Color(int.parse(widget.msg.senderColor.replaceFirst('#', '0xFF')));
    final isOwn = widget.msg.isOwn;

    final bubble = Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
      decoration: BoxDecoration(
        gradient: isOwn ? AppColors.brandGradient : null,
        color: isOwn ? null : AppColors.bg2,
        border: isOwn ? null : Border.all(color: AppColors.border),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.r3),
          topRight: const Radius.circular(AppRadius.r3),
          bottomLeft: Radius.circular(isOwn ? AppRadius.r3 : 4),
          bottomRight: Radius.circular(isOwn ? 4 : AppRadius.r3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwn)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(widget.msg.senderName,
                  style: TextStyle(color: senderColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          if (widget.msg.messageType == 'voice')
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, size: 12, color: isOwn ? Colors.white70 : AppColors.tx3),
                  const SizedBox(width: 4),
                  Text('Voz transcrita',
                      style: TextStyle(fontSize: 10.5, color: isOwn ? Colors.white70 : AppColors.tx3)),
                ],
              ),
            ),
          Text(displayText, style: TextStyle(color: isOwn ? Colors.white : AppColors.tx1, fontSize: 14.5, height: 1.3)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.msg.timestamp,
                  style: TextStyle(fontSize: 10, color: isOwn ? Colors.white70 : AppColors.tx3)),
              const SizedBox(width: 2),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _localOverride = !showSigns),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.back_hand_rounded, size: 13,
                      color: isOwn ? Colors.white70 : AppColors.tx3),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: senderColor,
              child: Text(
                widget.msg.senderName.isNotEmpty ? widget.msg.senderName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}