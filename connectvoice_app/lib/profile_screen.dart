import 'package:flutter/material.dart';
import 'theme.dart';
import 'prefs.dart';

class ProfileScreen extends StatefulWidget {
  final Prefs prefs;
  const ProfileScreen({super.key, required this.prefs});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name = widget.prefs.senderName;
  late String _color = widget.prefs.senderColor;
  late String _gender = widget.prefs.voiceGender;
  late double _speed = widget.prefs.voiceSpeed;
  late double _volume = widget.prefs.voiceVolume;
  late bool _signMode = widget.prefs.signMode;
  bool _dirty = false;

  void _mark() => setState(() => _dirty = true);

  Future<void> _save() async {
    await widget.prefs.setSenderName(_name.isEmpty ? 'Anónimo' : _name);
    await widget.prefs.setSenderColor(_color);
    await widget.prefs.setVoiceGender(_gender);
    await widget.prefs.setVoiceSpeed(_speed);
    await widget.prefs.setVoiceVolume(_volume);
    await widget.prefs.setSignMode(_signMode);
    setState(() => _dirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (_dirty)
            TextButton(
              onPressed: _save,
              child: const Text('Guardar', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Color(int.parse(_color.replaceFirst('#', '0xFF'))),
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Tu nombre', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
          const SizedBox(height: 6),
          TextField(
            controller: TextEditingController(text: _name)
              ..selection = TextSelection.collapsed(offset: _name.length),
            style: const TextStyle(color: AppColors.tx1),
            decoration: const InputDecoration(hintText: 'Escribe tu nombre'),
            onChanged: (v) { _name = v; _mark(); },
          ),
          const SizedBox(height: 22),

          const Text('Color', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: Prefs.colors.map((c) {
              final selected = c == _color;
              final col = Color(int.parse(c.replaceFirst('#', '0xFF')));
              return GestureDetector(
                onTap: () { _color = c; _mark(); },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: col,
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? AppColors.tx1 : Colors.transparent, width: 2.5),
                  ),
                  child: selected ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          const Text('Voz', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _GenderChip(
                  label: 'Femenina', icon: Icons.face_3_rounded,
                  selected: _gender == 'female',
                  onTap: () { _gender = 'female'; _mark(); },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _GenderChip(
                  label: 'Masculina', icon: Icons.face_rounded,
                  selected: _gender == 'male',
                  onTap: () { _gender = 'male'; _mark(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 16, color: AppColors.tx2),
              const SizedBox(width: 6),
              const Text('Velocidad', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
              const Spacer(),
              Text(_speed.toStringAsFixed(1), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(value: _speed, min: 0.5, max: 2.0, divisions: 15, onChanged: (v) { _speed = v; _mark(); }),

          Row(
            children: [
              const Icon(Icons.volume_up_rounded, size: 16, color: AppColors.tx2),
              const SizedBox(width: 6),
              const Text('Volumen', style: TextStyle(color: AppColors.tx2, fontSize: 12.5)),
              const Spacer(),
              Text('${(_volume * 100).round()}%', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(value: _volume, min: 0.0, max: 1.0, divisions: 10, onChanged: (v) { _volume = v; _mark(); }),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(AppRadius.r3),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Text('🤟', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Modo señas (emoji)', style: TextStyle(color: AppColors.tx1, fontWeight: FontWeight.w600, fontSize: 13.5)),
                ),
                Switch(value: _signMode, onChanged: (v) { _signMode = v; _mark(); }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          GradientButton(label: 'Guardar cambios', icon: Icons.check_rounded, onPressed: _dirty ? _save : null),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({required this.label, required this.icon, required this.selected, required this.onTap});

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