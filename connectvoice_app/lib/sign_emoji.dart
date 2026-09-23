/// Alfabeto visual de apoyo (deletreo con emoji).
/// IMPORTANTE: esto NO es una traducción oficial ni certificada a
/// Lengua de Señas Colombiana (LSC). Es un recurso visual/lúdico.
const Map<String, String> signEmojiMap = {
  'a': '✊', 'b': '🖐️', 'c': '🤏', 'd': '☝️', 'e': '🤌',
  'f': '👆', 'g': '👉', 'h': '👇', 'i': '👆', 'j': '🫰',
  'k': '✌️', 'l': '🤟', 'm': '👊', 'n': '✊', 'ñ': '🌀',
  'o': '👌', 'p': '👇', 'q': '🫳', 'r': '🤞', 's': '🔄',
  't': '🖖', 'u': '🤙', 'v': '✌️', 'w': '🤟', 'x': '🪝',
  'y': '🤙', 'z': '👆',
  '0': '0️⃣', '1': '1️⃣', '2': '2️⃣', '3': '3️⃣', '4': '4️⃣',
  '5': '5️⃣', '6': '6️⃣', '7': '7️⃣', '8': '8️⃣', '9': '9️⃣',
  '?': '❓', '!': '❗', '.': '⏺️', ',': '〰️',
};

const _accentMap = {
  'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u',
};

String _stripAccents(String input) {
  final buf = StringBuffer();
  for (final ch in input.split('')) {
    buf.write(_accentMap[ch] ?? ch);
  }
  return buf.toString();
}

/// Convierte texto plano en su representación con emoji-señas.
String textToSignEmojis(String text) {
  if (text.trim().isEmpty) return '';
  final lower = _stripAccents(text.toLowerCase());
  final parts = <String>[];
  for (final ch in lower.split('')) {
    if (ch.trim().isEmpty) {
      parts.add(' ');
    } else if (signEmojiMap.containsKey(ch)) {
      parts.add(signEmojiMap[ch]!);
    } else {
      parts.add(ch);
    }
  }
  return parts.join(' ');
}