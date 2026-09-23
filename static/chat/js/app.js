'use strict';

/* ═══════════════════════════════════════════════════════════
   ConnectVoice — app.js
   WebSocket · Speech Recognition · Text-to-Speech · UI
   ═══════════════════════════════════════════════════════════ */

/* ═══════════════════════════════════════════════════════════
   MODO SEÑAS (representación visual con emoji)
   ───────────────────────────────────────────────────────────
   IMPORTANTE: esto NO es una traducción oficial a Lengua de
   Señas Colombiana (LSC) ni a ningún otro sistema certificado.
   Es un alfabeto visual de apoyo (deletreo con emoji) para que
   el mensaje se vea "señado" en pantalla en vez de solo texto.
   Para comunicación formal, médica o legal, se recomienda un
   intérprete certificado de LSC.
   ═══════════════════════════════════════════════════════════ */
const SIGN_EMOJI_MAP = {
  'a': '✊', 'b': '🖐️', 'c': '🤏', 'd': '👆', 'e': '🤛',
  'f': '👌', 'g': '👉', 'h': '✌️', 'i': '🤙', 'j': '🫰',
  'k': '🤞', 'l': '🤟', 'm': '🖖', 'n': '🤘', 'o': '👊',
  'ñ': '👐', 'o2': '👊', 'p': '🫳', 'q': '🫴', 'r': '🤝',
  's': '👊', 't': '🤌', 'u': '☝️', 'v': '✌️', 'w': '🤟',
  'x': '🫲', 'y': '🤙', 'z': '👋',
  '0':'0️⃣','1':'1️⃣','2':'2️⃣','3':'3️⃣','4':'4️⃣',
  '5':'5️⃣','6':'6️⃣','7':'7️⃣','8':'8️⃣','9':'9️⃣',
  ' ': '⠀ ', '?': '❓', '!': '❗', '.': '⏺️', ',': '〰️'
};

function stripAccents(str) {
  return str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

// Convierte un texto en su representación "deletreada" con emoji-señas.
// Los caracteres sin mapeo (ej. símbolos raros) se muestran tal cual.
function textToSignEmojis(text) {
  if (!text) return '';
  const lower = stripAccents(text.toLowerCase());
  const out = [];
  for (const ch of lower) {
    if (ch === 'ñ') { out.push(SIGN_EMOJI_MAP['ñ']); continue; }
    if (SIGN_EMOJI_MAP[ch] !== undefined) out.push(SIGN_EMOJI_MAP[ch]);
    else if (ch.trim() === '') out.push(' ');
    else out.push(ch);
  }
  return out.join(' ');
}

// Estado del modo señas — persiste en localStorage
let signMode = localStorage.getItem('cv_sign_mode') === '1';

function toggleSignMode(force) {
  signMode = typeof force === 'boolean' ? force : !signMode;
  localStorage.setItem('cv_sign_mode', signMode ? '1' : '0');
  const chk = document.getElementById('cfg_sign_mode');
  if (chk) chk.checked = signMode;
  // Re-renderiza los mensajes ya visibles en pantalla
  document.querySelectorAll('.msg-text[data-original]').forEach(el => {
    const original = el.getAttribute('data-original');
    el.textContent = signMode ? textToSignEmojis(original) : original;
    el.title = signMode ? original : '';
  });
  toast(signMode ? 'Modo señas activado 🤟' : 'Modo señas desactivado', 'info');
}

// ── State ────────────────────────────────────────────────────
let ws            = null;
let recognition   = null;
let isListening   = false;
let voiceGender   = localStorage.getItem('cv_voice_gender')  || 'female';
let voiceSpeed    = parseFloat(localStorage.getItem('cv_voice_speed')  || '1.0');
let voiceVolume   = parseFloat(localStorage.getItem('cv_voice_volume') || '1.0');
let currentTheme  = localStorage.getItem('cv_theme') || 'dark';
let senderName    = SENDER_NAME || localStorage.getItem('cv_name') || 'Anónimo';
let senderColor   = SENDER_COLOR || localStorage.getItem('cv_color') || '#00D4FF';
let selColor      = senderColor;
let typingTimer   = null;
let reconnects    = 0;
const MAX_RC      = 6;
let pendingClear  = false;
let pendingDelSlug = null;

// ── Boot ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  applyTheme(currentTheme);
  initSettingsUI();
  initTextarea();
  initSidebar();
  if (ROOM_SLUG) {
    connectWS();
    initSpeechRecognition();
    initTTS();
    scrollBottom();
  }
  createToasts();

  // Aplica el modo señas guardado al historial ya renderizado por el servidor
  if (signMode) {
    document.querySelectorAll('.msg-text[data-original]').forEach(el => {
      const original = el.getAttribute('data-original');
      el.textContent = textToSignEmojis(original);
      el.title = original;
    });
  }
});

/* ═══════════════════════════════════════════════════════════
   WEBSOCKET
   ═══════════════════════════════════════════════════════════ */
function connectWS() {
  if (!ROOM_SLUG) return;
  const proto = location.protocol === 'https:' ? 'wss' : 'ws';
  ws = new WebSocket(`${proto}://${location.host}/ws/chat/${ROOM_SLUG}/`);

  setConn('connecting');

  ws.onopen = () => {
    reconnects = 0;
    setConn('online');
    toast('Conectado al chat', 'info');
  };

  ws.onmessage = e => {
    try { handleWS(JSON.parse(e.data)); }
    catch(err) { console.error('WS parse error', err); }
  };

  ws.onerror = () => setConn('offline');

  ws.onclose = () => {
    setConn('offline');
    if (reconnects < MAX_RC) {
      reconnects++;
      const d = Math.min(1000 * Math.pow(2, reconnects), 20000);
      toast(`Reconectando en ${Math.round(d/1000)}s…`, 'info');
      setTimeout(connectWS, d);
    } else {
      toast('No se pudo reconectar. Recarga la página.', 'err');
    }
  };
}

function handleWS(data) {
  switch (data.type) {
    case 'message':
      appendMessage(data);
      // CORRECCIÓN: Se remueve la validación session_id !== SESSION_ID 
      // para que lea en voz alta TODOS los mensajes de texto entrantes de inmediato.
      if (data.message_type === 'text') {
        speak(data.content);
      }
      break;
    case 'typing':
      showTyping(data.sender_name, data.is_typing);
      break;
    case 'cleared':
      clearMessagesUI();
      toast('Chat limpiado', 'info');
      break;
    case 'presence':
      updatePresence(data.count);
      break;
    case 'error':
      toast(data.msg, 'err');
      break;
  }
}

function sendWS(obj) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(obj));
    return true;
  }
  toast('Sin conexión, intenta de nuevo', 'err');
  return false;
}

/* ═══════════════════════════════════════════════════════════
   MESSAGES
   ═══════════════════════════════════════════════════════════ */
function sendText() {
  const ta = document.getElementById('msgInput');
  if (!ta) return;
  const txt = ta.value.trim();
  if (!txt) return;

  sendWS({
    type: 'chat_message',
    content: txt,
    sender_name: senderName,
    sender_color: senderColor,
    session_id: SESSION_ID,
  });

  ta.value = '';
  ta.style.height = 'auto';
  updateCharCount(0);
  sendTyping(false);
}

function sendVoiceMsg(txt) {
  if (!txt.trim()) return;
  sendWS({
    type: 'voice_message',
    content: txt.trim(),
    sender_name: senderName,
    sender_color: senderColor,
    session_id: SESSION_ID,
  });
}

function appendMessage(data) {
  const wrap = document.getElementById('msgWrap');
  if (!wrap) return;

  const isOwn = data.session_id === SESSION_ID;
  const div = document.createElement('div');
  div.className = `msg-wrap${isOwn ? ' own' : ''}`;
  div.id = `m${data.msg_id}`;

  const letter = (data.sender_name || '?')[0].toUpperCase();
  const isVoice = data.message_type === 'voice';
  const rawTxt = data.content;
  const txt = escHtml(rawTxt);
  const displayTxt = escHtml(signMode ? textToSignEmojis(rawTxt) : rawTxt);

  div.innerHTML = `
    ${!isOwn ? `<div class="msg-avatar" style="background:${data.sender_color}">${letter}</div>` : ''}
    <div class="msg-body">
      ${!isOwn ? `<div class="msg-sender">${escHtml(data.sender_name)}</div>` : ''}
      <div class="msg-bubble${isVoice ? ' voice-bubble' : ''}">
        ${isVoice ? '<div class="voice-tag"><i class="fas fa-microphone"></i> Voz transcrita</div>' : ''}
        <div class="msg-text" data-original="${txt}" title="${signMode ? txt : ''}">${displayTxt}</div>
        <div class="msg-meta">
          <span class="msg-time">${data.timestamp}</span>
          <button class="btn-replay" onclick="speak('${txt.replace(/'/g,"\\'")}')">
            <i class="fas fa-volume-up"></i>
          </button>
          <button class="btn-replay" title="Alternar texto/señas" onclick="toggleSingleMsg(this)">
            <i class="fas fa-hands"></i>
          </button>
        </div>
      </div>
    </div>`;

  wrap.appendChild(div);
  scrollBottom();
}

// Alterna un solo mensaje entre texto plano y modo señas (emoji),
// sin afectar la preferencia global del usuario.
function toggleSingleMsg(btn) {
  const bubble = btn.closest('.msg-bubble');
  const el = bubble?.querySelector('.msg-text[data-original]');
  if (!el) return;
  const original = el.getAttribute('data-original');
  const showingSigns = el.dataset.showingSigns === '1';
  if (showingSigns) {
    el.textContent = original;
    el.dataset.showingSigns = '0';
    el.title = '';
  } else {
    el.textContent = textToSignEmojis(original);
    el.dataset.showingSigns = '1';
    el.title = original;
  }
}

function clearMessagesUI() {
  const wrap = document.getElementById('msgWrap');
  if (!wrap) return;
  wrap.querySelectorAll('.msg-wrap').forEach(el => el.remove());
  const sys = document.createElement('div');
  sys.className = 'sys-msg';
  sys.innerHTML = '<span><i class="fas fa-trash-alt"></i> Mensajes borrados</span>';
  wrap.appendChild(sys);
}

function scrollBottom() {
  const area = document.getElementById('msgArea');
  if (area) requestAnimationFrame(() => { area.scrollTop = area.scrollHeight; });
}

/* ═══════════════════════════════════════════════════════════
   TYPING INDICATOR
   ═══════════════════════════════════════════════════════════ */
function sendTyping(on) {
  clearTimeout(typingTimer);
  sendWS({ type: 'typing', sender_name: senderName, is_typing: on });
  if (on) typingTimer = setTimeout(() => sendTyping(false), 3000);
}

function showTyping(name, on) {
  const row = document.getElementById('typingRow');
  const who = document.getElementById('typingWho');
  const conn = document.getElementById('connStatus');
  if (!row) return;
  if (on) {
    if (who) who.textContent = name;
    row.classList.add('show');
    if (conn) conn.style.display = 'none';
  } else {
    row.classList.remove('show');
    if (conn) conn.style.display = '';
  }
}

function updatePresence(count) {
  const sub = document.querySelector('.chat-header-sub');
  // We keep typing indicator as main sub, just update dot color
}

/* ═══════════════════════════════════════════════════════════
   SPEECH RECOGNITION (Voz → Texto)
   ═══════════════════════════════════════════════════════════ */
function initSpeechRecognition() {
  const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SR) {
    const btn = document.getElementById('micBtn');
    if (btn) { btn.disabled = true; btn.style.opacity = '.35'; btn.title = 'Reconocimiento de voz no soportado. Usa Chrome o Edge.'; }
    const st = document.getElementById('micStatus');
    if (st) st.innerHTML = '<i class="fas fa-ban"></i> Voz no disponible — usa Chrome/Edge';
    return;
  }

  recognition = new SR();
  recognition.lang = 'es-CO';
  recognition.continuous = true;
  recognition.interimResults = true;
  recognition.maxAlternatives = 1;

  recognition.onstart = () => {
    isListening = true;
    updateMicUI(true);
  };

  recognition.onresult = e => {
    let interim = '';
    let final = '';
    for (let i = e.resultIndex; i < e.results.length; i++) {
      const t = e.results[i][0].transcript;
      if (e.results[i].isFinal) final += t + ' ';
      else interim += t;
    }
    const prev = document.getElementById('voicePreview');
    if (prev) prev.textContent = interim || final;
    if (final.trim()) {
      sendVoiceMsg(final.trim());
      if (prev) prev.textContent = '';
    }
  };

  recognition.onerror = e => {
    if (e.error === 'not-allowed') {
      toast('Acceso al micrófono denegado. Permite el acceso en el navegador.', 'err');
      isListening = false; updateMicUI(false);
    } else if (e.error !== 'no-speech') {
      console.warn('Speech error:', e.error);
    }
  };

  recognition.onend = () => {
    // Auto-restart if still in listening mode
    if (isListening) {
      try { recognition.start(); } catch(_) {}
    } else {
      updateMicUI(false);
    }
  };
}

// Teclas y activadores manuales
function toggleMic() {
  if (!recognition) {
    toast('Reconocimiento de voz no disponible. Usa Chrome o Edge.', 'err');
    return;
  }
  isListening ? stopListening() : startListening();
}

function startListening() {
  isListening = true;
  try { recognition.start(); } catch(_) {}
  showVoiceOverlay(true);
  toast('Micrófono activo — habla ahora', 'info');
}

function stopListening() {
  isListening = false;
  try { recognition.stop(); } catch(_) {}
  showVoiceOverlay(false);
  updateMicUI(false);
}

function updateMicUI(on) {
  const btn  = document.getElementById('micBtn');
  const icon = document.getElementById('micIcon');
  const st   = document.getElementById('micStatus');
  if (!btn) return;
  if (on) {
    btn.classList.add('listening');
    if (icon) icon.className = 'fas fa-microphone';
    if (st)   { st.classList.add('on'); st.innerHTML = '<i class="fas fa-microphone"></i> Escuchando…'; }
  } else {
    btn.classList.remove('listening');
    if (icon) icon.className = 'fas fa-microphone-slash';
    if (st)   { st.classList.remove('on'); st.innerHTML = '<i class="fas fa-microphone-slash"></i> Micrófono desactivado'; }
  }
}

function showVoiceOverlay(show) {
  const ov = document.getElementById('voiceOverlay');
  if (!ov) return;
  if (show) {
    ov.classList.add('show');
    const prev = document.getElementById('voicePreview');
    if (prev) prev.textContent = '';
  } else {
    ov.classList.remove('show');
  }
}

/* ═══════════════════════════════════════════════════════════
   TEXT-TO-SPEECH (Texto → Voz)
   ═══════════════════════════════════════════════════════════ */
let ttsVoices = [];

function initTTS() {
  if (!window.speechSynthesis) return;
  loadVoices();
  if (speechSynthesis.onvoiceschanged !== undefined)
    speechSynthesis.onvoiceschanged = loadVoices;
}

function loadVoices() {
  ttsVoices = window.speechSynthesis?.getVoices() || [];
}

function pickVoice(gender) {
  if (!ttsVoices.length) loadVoices();
  const esVoices = ttsVoices.filter(v => v.lang.startsWith('es'));
  const femKeys  = ['femenin','female','lucia','monica','elena','paula','laura','sofia','mujer','woman'];
  const maleKeys = ['mascul','male','jorge','diego','carlos','pablo','hombre','man'];
  const keys = gender === 'female' ? femKeys : maleKeys;

  for (const k of keys) {
    const v = esVoices.find(v => v.name.toLowerCase().includes(k));
    if (v) return v;
  }
  return esVoices[0] || ttsVoices[0] || null;
}

function speak(text) {
  if (!window.speechSynthesis || !text?.trim()) return;
  speechSynthesis.cancel();
  const utt = new SpeechSynthesisUtterance(text);
  const v = pickVoice(voiceGender);
  if (v) utt.voice = v;
  utt.rate   = voiceSpeed;
  utt.volume = voiceVolume;
  utt.pitch  = 1;
  utt.lang   = 'es-CO';
  speechSynthesis.speak(utt);
}

function testVoice() {
  const g = document.getElementById('cfg_voice_gender')?.value || voiceGender;
  const s = parseFloat(document.getElementById('cfg_speed')?.value || voiceSpeed);
  const vol = parseFloat(document.getElementById('cfg_vol')?.value || voiceVolume);
  const savedG = voiceGender, savedS = voiceSpeed, savedV = voiceVolume;
  voiceGender = g; voiceSpeed = s; voiceVolume = vol;
  speak('Hola, este es el sonido de mi voz en ConnectVoice. Comunicación inclusiva para todos.');
  voiceGender = savedG; voiceSpeed = savedS; voiceVolume = savedV;
}

/* ═══════════════════════════════════════════════════════════
   ROOMS
   ═══════════════════════════════════════════════════════════ */
function createRoom() {
  const inp = document.getElementById('newRoomName');
  const name = inp?.value.trim();
  if (!name) { toast('Escribe un nombre para la sala', 'err'); return; }

  fetch('/api/rooms/create/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-CSRFToken': CSRF },
    body: JSON.stringify({ name }),
  })
  .then(r => r.json())
  .then(d => {
    if (d.ok) {
      closeModal('newRoomModal');
      if (inp) inp.value = '';
      toast(`Sala "${d.display_name}" creada`, 'ok');
      setTimeout(() => { location.href = `/sala/${d.slug}/`; }, 400);
    } else {
      toast(d.error || 'Error al crear sala', 'err');
    }
  })
  .catch(() => toast('Error de red', 'err'));
}

let pendingDelRoomSlug = null;
function askDelRoom(e, slug, displayName) {
  e.preventDefault(); e.stopPropagation();
  pendingDelRoomSlug = slug;
  document.getElementById('delRoomName').textContent = displayName;
  openModal('delRoomModal');
}

function confirmDelRoom() {
  if (!pendingDelRoomSlug) return;
  fetch(`/api/rooms/${pendingDelRoomSlug}/delete/`, {
    method: 'POST',
    headers: { 'X-CSRFToken': CSRF },
  })
  .then(r => r.json())
  .then(d => {
    closeModal('delRoomModal');
    if (d.ok) {
      toast('Sala eliminada', 'ok');
      const el = document.querySelector(`[data-slug="${pendingDelRoomSlug}"]`);
      if (el) el.remove();
      if (ROOM_SLUG === pendingDelRoomSlug) {
        setTimeout(() => { location.href = '/'; }, 600);
      }
    } else {
      toast('Error al eliminar', 'err');
    }
    pendingDelRoomSlug = null;
  })
  .catch(() => toast('Error de red', 'err'));
}

function confirmClear() {
  if (!ROOM_SLUG) return;
  closeModal('clearModal');
  sendWS({ type: 'clear_room' });
  fetch(`/api/rooms/${ROOM_SLUG}/clear/`, {
    method: 'POST',
    headers: { 'X-CSRFToken': CSRF },
  });
}

/* ═══════════════════════════════════════════════════════════
   SETTINGS
   ═══════════════════════════════════════════════════════════ */
function initSettingsUI() {
  const savedName = localStorage.getItem('cv_name');
  const savedColor = localStorage.getItem('cv_color');
  if (savedName) senderName = savedName;
  if (savedColor) senderColor = selColor = savedColor;

  const ni = document.getElementById('cfg_name');
  if (ni) ni.value = senderName;

  document.querySelectorAll('.clr-swatch').forEach(s => {
    if (s.dataset.color === senderColor) s.classList.add('sel');
  });
  const ci = document.getElementById('cfg_color');
  if (ci) ci.value = senderColor;

  const vg = document.getElementById('cfg_voice_gender');
  if (vg) vg.value = voiceGender;

  const sp = document.getElementById('cfg_speed');
  if (sp) {
    sp.value = voiceSpeed;
    document.getElementById('speedVal').textContent = voiceSpeed.toFixed(1) + 'x';
    sp.addEventListener('input', function() {
      document.getElementById('speedVal').textContent = parseFloat(this.value).toFixed(1) + 'x';
    });
  }

  const vl = document.getElementById('cfg_vol');
  if (vl) {
    vl.value = voiceVolume;
    document.getElementById('volVal').textContent = voiceVolume.toFixed(1);
    vl.addEventListener('input', function() {
      document.getElementById('volVal').textContent = parseFloat(this.value).toFixed(1);
    });
  }

  updateThemeBtns(currentTheme);

  const sm = document.getElementById('cfg_sign_mode');
  if (sm) sm.checked = signMode;
}

function selectColor(color, btn) {
  selColor = color;
  document.getElementById('cfg_color').value = color;
  document.querySelectorAll('.clr-swatch').forEach(s => s.classList.remove('sel'));
  btn.classList.add('sel');
}

function saveSettings() {
  const name = document.getElementById('cfg_name')?.value.trim() || senderName;
  const color = document.getElementById('cfg_color')?.value || senderColor;
  const gender = document.getElementById('cfg_voice_gender')?.value || voiceGender;
  const speed = parseFloat(document.getElementById('cfg_speed')?.value || voiceSpeed);
  const vol = parseFloat(document.getElementById('cfg_vol')?.value || voiceVolume);

  senderName  = name || 'Anónimo';
  senderColor = color;
  voiceGender = gender;
  voiceSpeed  = speed;
  voiceVolume = vol;

  localStorage.setItem('cv_name',  senderName);
  localStorage.setItem('cv_color', senderColor);
  localStorage.setItem('cv_voice_gender', voiceGender);
  localStorage.setItem('cv_speed',  voiceSpeed);
  localStorage.setItem('cv_volume', voiceVolume);

  fetch('/api/sender/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'X-CSRFToken': CSRF },
    body: JSON.stringify({ name: senderName, color: senderColor }),
  });

  const sm = document.getElementById('cfg_sign_mode');
  if (sm) toggleSignMode(sm.checked);

  loadVoices();
  closeModal('settingsModal');
  toast('Configuración guardada', 'ok');
}

/* ═══════════════════════════════════════════════════════════
   THEME
   ═══════════════════════════════════════════════════════════ */
function applyTheme(t) {
  document.documentElement.setAttribute('data-theme', t);
  currentTheme = t;
  const icon = document.getElementById('themeIcon');
  if (icon) icon.className = t === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
  updateThemeBtns(t);
}

function toggleTheme() {
  const next = currentTheme === 'dark' ? 'light' : 'dark';
  localStorage.setItem('cv_theme', next);
  applyTheme(next);
}

function setTheme(t) {
  localStorage.setItem('cv_theme', t);
  applyTheme(t);
}

function updateThemeBtns(t) {
  const d = document.getElementById('themeDark');
  const l = document.getElementById('themeLight');
  if (d) d.classList.toggle('btn-modal-primary', t === 'dark');
  if (l) l.classList.toggle('btn-modal-primary', t === 'light');
  if (d) d.classList.toggle('btn-modal-ghost', t !== 'dark');
  if (l) l.classList.toggle('btn-modal-ghost', t !== 'light');
}

/* ═══════════════════════════════════════════════════════════
   CONNECTION STATUS
   ═══════════════════════════════════════════════════════════ */
function setConn(state) {
  const el = document.getElementById('connStatus');
  if (!el) return;
  const map = {
    connecting: ['conn-connecting', '<i class="fas fa-circle"></i> Conectando…'],
    online:     ['conn-online',     '<i class="fas fa-circle"></i> En línea'],
    offline:    ['conn-offline',    '<i class="fas fa-circle"></i> Desconectado'],
  };
  el.className = `conn-status ${map[state][0]}`;
  el.innerHTML = map[state][1];
}

/* ═══════════════════════════════════════════════════════════
   UI HELPERS
   ═══════════════════════════════════════════════════════════ */
function initTextarea() {
  const ta = document.getElementById('msgInput');
  if (!ta) return;

  ta.addEventListener('input', () => {
    ta.style.height = 'auto';
    ta.style.height = Math.min(ta.scrollHeight, 110) + 'px';
    const n = ta.value.length;
    updateCharCount(n);
    sendTyping(n > 0);
  });

  ta.addEventListener('keydown', e => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendText();
    }
  });
}

function updateCharCount(n) {
  const el = document.getElementById('charCnt');
  if (el) el.textContent = `${n} / 2000`;
}

function initSidebar() {
  const hamburgers = document.querySelectorAll('#hamburger, #hamburger2');
  const sidebar = document.getElementById('sidebar');
  const closeBtn = document.getElementById('sidebarClose');
  const backdrop = document.getElementById('sidebarBackdrop');

  hamburgers.forEach(h => h?.addEventListener('click', openSidebar));
  closeBtn?.addEventListener('click', closeSidebar);
  backdrop?.addEventListener('click', closeSidebar);
}

function openSidebar() {
  document.getElementById('sidebar')?.classList.add('open');
  document.getElementById('sidebarBackdrop')?.classList.add('show');
}

function closeSidebar() {
  document.getElementById('sidebar')?.classList.remove('open');
  document.getElementById('sidebarBackdrop')?.classList.remove('show');
}

function openModal(id) {
  document.getElementById(id)?.classList.add('show');
  setTimeout(() => {
    const inp = document.querySelector(`#${id} input:not([type=hidden]):not([type=range])`);
    if (inp) inp.focus();
  }, 100);
}

function closeModal(id) {
  document.getElementById(id)?.classList.remove('show');
}

document.addEventListener('click', e => {
  if (e.target.classList.contains('overlay')) {
    e.target.classList.remove('show');
  }
});

document.addEventListener('keydown', e => {
  if (e.key === 'Escape') {
    document.querySelectorAll('.overlay.show').forEach(el => el.classList.remove('show'));
    if (isListening) stopListening();
  }
  if (e.ctrlKey && e.key === 'm') { e.preventDefault(); toggleMic(); }
  if (e.key === 'Enter') {
    const modal = document.getElementById('newRoomModal');
    if (modal?.classList.contains('show')) createRoom();
  }
});

function createToasts() {
  if (!document.getElementById('toasts')) {
    const d = document.createElement('div');
    d.id = 'toasts'; d.className = 'toasts';
    document.body.appendChild(d);
  }
}

function toast(msg, type = 'info') {
  const c = document.getElementById('toasts');
  if (!c) return;
  const icons = { ok: 'fa-check-circle', err: 'fa-exclamation-circle', info: 'fa-info-circle' };
  const t = document.createElement('div');
  t.className = `toast toast-${type}`;
  t.innerHTML = `<i class="fas ${icons[type] || icons.info}"></i><span>${msg}</span>`;
  c.appendChild(t);
  setTimeout(() => { t.style.opacity = '0'; t.style.transform = 'translateX(110%)'; t.style.transition = '.3s'; setTimeout(() => t.remove(), 320); }, 3200);
}

function escHtml(str) {
  const d = document.createElement('div');
  d.appendChild(document.createTextNode(String(str)));
  return d.innerHTML;
}