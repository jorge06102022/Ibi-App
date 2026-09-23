import 'package:flutter/material.dart';
import 'theme.dart';
import 'sign_emoji.dart';

/// Teclado propio dentro de la app (no reemplaza el teclado del sistema
/// Android en todo el dispositivo, solo se usa aquí para escribir mensajes).
/// Cada tecla muestra la letra arriba y el emoji-seña correspondiente abajo,
/// para que una persona sorda pueda escribir reconociendo la seña.
class SignKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onChanged;
  const SignKeyboard({super.key, required this.controller, this.onSend, this.onChanged});

  static const _rows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  void _insert(String letter) {
    final text = controller.text;
    final sel = controller.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    controller.text = text.replaceRange(start, end, letter);
    controller.selection = TextSelection.collapsed(offset: start + letter.length);
    onChanged?.call();
  }

  void _backspace() {
    final text = controller.text;
    if (text.isEmpty) return;
    final sel = controller.selection;
    int start = sel.start < 0 ? text.length : sel.start;
    int end = sel.end < 0 ? text.length : sel.end;
    if (start == end) {
      if (start == 0) return;
      start -= 1;
    }
    controller.text = text.replaceRange(start, end, '');
    controller.selection = TextSelection.collapsed(offset: start);
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg1,
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in _rows) _buildRow(row),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _SpecialKey(
                  label: 'ESPACIO',
                  icon: Icons.space_bar_rounded,
                  onTap: () => _insert(' '),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SpecialKey(icon: Icons.backspace_rounded, onTap: _backspace),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SpecialKey(icon: Icons.send_rounded, gradient: true, onTap: onSend),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> letters) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: letters
            .map((l) => Expanded(child: _SignKey(letter: l, onTap: () => _insert(l))))
            .toList(),
      ),
    );
  }
}

class _SignKey extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;
  const _SignKey({required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final emoji = signEmojiMap[letter] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.r1),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.r1),
          onTap: onTap,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(AppRadius.r1),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(letter.toUpperCase(),
                    style: const TextStyle(color: AppColors.tx3, fontSize: 9, fontWeight: FontWeight.w700)),
                Text(emoji, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialKey extends StatelessWidget {
  final String? label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool gradient;
  const _SpecialKey({this.label, required this.icon, this.onTap, this.gradient = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.r1),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r1),
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            gradient: gradient ? AppColors.brandGradient : null,
            color: gradient ? null : AppColors.bg2,
            borderRadius: BorderRadius.circular(AppRadius.r1),
            border: gradient ? null : Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: gradient ? Colors.white : AppColors.tx2),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(label!,
                    style: TextStyle(
                        color: gradient ? Colors.white : AppColors.tx2,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}