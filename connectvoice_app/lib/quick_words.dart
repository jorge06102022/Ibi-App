import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'theme.dart';

class QuickWordsData {
  static const Map<String, List<Map<String, String>>> categories = {
    'Emergencia 🚨': [
      {'word': 'ayuda', 'emoji': '🆘'},
      {'word': 'hospital', 'emoji': '🏥'},
      {'word': 'doctor', 'emoji': '👨‍⚕️'},
      {'word': 'medicina', 'emoji': '💊'},
      {'word': 'enfermo', 'emoji': '🤒'},
    ],
    'Saludos 👋': [
      {'word': 'hola', 'emoji': '👋'},
      {'word': 'buenos dias', 'emoji': '🌅'},
      {'word': 'buenas tardes', 'emoji': '🌇'},
      {'word': 'buenas noches', 'emoji': '🌃'},
      {'word': 'gracias', 'emoji': '🙏'},
      {'word': 'de nada', 'emoji': '🙌'},
      {'word': 'por favor', 'emoji': '🥺'},
      {'word': 'perdon', 'emoji': '🙇'},
    ],
    'Preguntas ❓': [
      {'word': 'como estas', 'emoji': '❓'},
      {'word': 'que', 'emoji': '🤷'},
      {'word': 'quien', 'emoji': '👤'},
      {'word': 'cuando', 'emoji': '⏱️'},
      {'word': 'donde', 'emoji': '📍'},
      {'word': 'por que', 'emoji': '🤔'},
      {'word': 'cuanto', 'emoji': '🔢'},
    ],
    'Emociones 😊': [
      {'word': 'feliz', 'emoji': '😃'},
      {'word': 'triste', 'emoji': '😢'},
      {'word': 'enojado', 'emoji': '😡'},
      {'word': 'cansado', 'emoji': '😮‍💨'},
      {'word': 'bien', 'emoji': '👍'},
      {'word': 'mal', 'emoji': '👎'},
    ],
    'Comida 🍎': [
      {'word': 'comer', 'emoji': '🍽️'},
      {'word': 'beber', 'emoji': '🥤'},
      {'word': 'agua', 'emoji': '💧'},
    ],
    'Familia 👨‍👩‍👧': [
      {'word': 'familia', 'emoji': '👨‍👩‍👧‍👦'},
      {'word': 'mama', 'emoji': '👩'},
      {'word': 'papa', 'emoji': '👨'},
      {'word': 'hermano', 'emoji': '👦'},
      {'word': 'hermana', 'emoji': '👧'},
      {'word': 'hijo', 'emoji': '👶'},
      {'word': 'hija', 'emoji': '👶'},
    ],
    'Personas 👥': [
      {'word': 'yo', 'emoji': '🙋'},
      {'word': 'tu', 'emoji': '🫵'},
      {'word': 'el', 'emoji': '👨'},
      {'word': 'ella', 'emoji': '👩'},
      {'word': 'nosotros', 'emoji': '🫂'},
      {'word': 'ellos', 'emoji': '👥'},
      {'word': 'sordo', 'emoji': '🧏'},
      {'word': 'oyente', 'emoji': '👂'},
      {'word': 'amigo', 'emoji': '🤝'},
      {'word': 'profesor', 'emoji': '👨‍🏫'},
      {'word': 'estudiante', 'emoji': '🎒'},
    ],
    'Lugares 🏠': [
      {'word': 'casa', 'emoji': '🏠'},
      {'word': 'trabajo', 'emoji': '💼'},
      {'word': 'escuela', 'emoji': '🏫'},
      {'word': 'baño', 'emoji': '🚽'},
    ],
    'Tiempo ⏱️': [
      {'word': 'tiempo', 'emoji': '⌛'},
      {'word': 'hoy', 'emoji': '📅'},
      {'word': 'mañana', 'emoji': '📆'},
      {'word': 'ayer', 'emoji': '⏮️'},
      {'word': 'ahora', 'emoji': '👇'},
      {'word': 'despues', 'emoji': '⏭️'},
      {'word': 'siempre', 'emoji': '♾️'},
      {'word': 'nunca', 'emoji': '❌'},
    ],
    'Verbos 🏃': [
      {'word': 'gustar', 'emoji': '❤️'},
      {'word': 'querer', 'emoji': '🤲'},
      {'word': 'necesitar', 'emoji': '❗'},
      {'word': 'tener', 'emoji': '✊'},
      {'word': 'hacer', 'emoji': '🛠️'},
      {'word': 'ir', 'emoji': '🚶'},
      {'word': 'venir', 'emoji': '🏃'},
      {'word': 'ver', 'emoji': '👁️'},
      {'word': 'oir', 'emoji': '👂'},
      {'word': 'hablar', 'emoji': '🗣️'},
      {'word': 'pensar', 'emoji': '🧠'},
      {'word': 'saber', 'emoji': '💡'},
      {'word': 'jugar', 'emoji': '🎮'},
      {'word': 'dormir', 'emoji': '😴'},
      {'word': 'despertar', 'emoji': '🥱'},
      {'word': 'comprar', 'emoji': '🛒'},
      {'word': 'pagar', 'emoji': '💳'},
    ],
    'Otros 💡': [
      {'word': 'si', 'emoji': '✅'},
      {'word': 'no', 'emoji': '❌'},
      {'word': 'nombre', 'emoji': '📛'},
      {'word': 'mi', 'emoji': '✋'},
      {'word': 'dinero', 'emoji': '💰'},
      {'word': 'caro', 'emoji': '📈'},
      {'word': 'barato', 'emoji': '📉'},
      {'word': 'mucho', 'emoji': '➕'},
      {'word': 'poco', 'emoji': '➖'},
      {'word': 'grande', 'emoji': '🐘'},
      {'word': 'pequeño', 'emoji': '🐁'},
    ],
  };
}

class QuickWordsMenu extends StatefulWidget {
  final ValueChanged<String> onWordSelected;
  final VoidCallback onClose;

  const QuickWordsMenu({super.key, required this.onWordSelected, required this.onClose});

  @override
  State<QuickWordsMenu> createState() => _QuickWordsMenuState();
}

class _QuickWordsMenuState extends State<QuickWordsMenu> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _selectCategory(String cat) {
    setState(() => _selectedCategory = cat);
    _ctrl.forward(from: 0.0); // Animate again for words
  }

  void _close() {
    _ctrl.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double radius = size.width * 0.45; // Radio del semicírculo
    
    return Stack(
      children: [
        // Fondo semi transparente para cerrar al tocar
        Positioned.fill(
          child: GestureDetector(
            onTap: _close,
            child: Container(color: Colors.black54),
          ),
        ),
        
        // Semicírculo animado que gira
        Positioned(
          bottom: 70, // Encima del input de chat
          left: 0,
          right: 0,
          height: radius + 80,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (ctx, child) {
              final scale = _anim.value;
              final items = _selectedCategory == null 
                  ? QuickWordsData.categories.keys.toList()
                  : QuickWordsData.categories[_selectedCategory]!;
                  
              return Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Arco de fondo de la media dona
                    Positioned(
                      bottom: -radius,
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bg1,
                          border: Border.all(color: AppColors.accent, width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                          ],
                        ),
                      ),
                    ),
                    
                    // Botón Atrás (solo si hay categoría seleccionada) en el centro de la dona
                    if (_selectedCategory != null)
                      Positioned(
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.tx1, size: 36),
                          onPressed: () => setState(() {
                            _selectedCategory = null;
                            _ctrl.forward(from: 0.0);
                          }),
                        ),
                      ),

                    // Media dona giratoria
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: radius + 40,
                      child: _RotatingDial(
                        radius: radius * 0.8, // Radio para los botones un poco menor al de la dona
                        items: List.generate(items.length, (i) {
                          final isCat = _selectedCategory == null;
                          final dynamic item = items[i];
                          return isCat 
                            ? _CategoryButton(
                                title: item as String,
                                onTap: () => _selectCategory(item),
                              )
                            : _WordButton(
                                wordData: item as Map<String, String>,
                                onTap: () {
                                  widget.onWordSelected(item['word']!);
                                  _close();
                                },
                              );
                        }),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RotatingDial extends StatefulWidget {
  final List<Widget> items;
  final double radius;

  const _RotatingDial({required this.items, required this.radius});

  @override
  State<_RotatingDial> createState() => _RotatingDialState();
}

class _RotatingDialState extends State<_RotatingDial> {
  double _scrollAngle = 0.0;
  
  @override
  void didUpdateWidget(_RotatingDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _scrollAngle = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.items.length;
    // Paso angular entre cada item (4 items visibles en la media dona)
    final double step = math.pi / 4.2; 
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        setState(() {
          // El arrastre horizontal o vertical afecta el giro
          // Si arrastra a la izquierda, gira hacia adelante
          _scrollAngle -= details.delta.dx * 0.015;
          _scrollAngle += details.delta.dy * 0.015;
          
          // Limites para que no gire infinitamente hacia la nada
          double maxAngle = math.max(0.0, (count - 1) * step - math.pi);
          if (maxAngle > 0) {
            maxAngle += math.pi / 8; // un poco de padding al final
          }
          final minAngle = -math.pi / 8; // un poco de padding al inicio
          
          if (_scrollAngle < minAngle) _scrollAngle = minAngle;
          if (_scrollAngle > maxAngle) _scrollAngle = maxAngle;
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: List.generate(count, (i) {
          // itemAngle va de pi (izquierda) a 0 (derecha)
          final double itemAngle = math.pi - (i * step) + _scrollAngle;
          
          // No renderizar si está muy oculto debajo del horizonte (por optimización)
          if (itemAngle < -0.4 || itemAngle > math.pi + 0.4) {
            return const SizedBox.shrink();
          }
          
          final double dx = math.cos(itemAngle) * widget.radius;
          final double dy = math.sin(itemAngle) * widget.radius;
          
          return Positioned(
            bottom: dy + 25, // Elevación base sobre el centro
            left: (MediaQuery.of(context).size.width / 2) + dx - 38, // -38 es la mitad del ancho del botón aprox (76/2)
            child: widget.items[i],
          );
        }),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _CategoryButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Extraer emoji y texto
    final parts = title.split(' ');
    final text = parts.length > 1 ? parts.sublist(0, parts.length - 1).join(' ') : title;
    final emoji = parts.length > 1 ? parts.last : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg2,
          border: Border.all(color: AppColors.accent, width: 1.5),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji.isNotEmpty) Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(
              text, 
              style: const TextStyle(color: AppColors.tx1, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _WordButton extends StatelessWidget {
  final Map<String, String> wordData;
  final VoidCallback onTap;

  const _WordButton({required this.wordData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.brandGradient,
          boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(wordData['emoji']!, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 2),
            Text(
              wordData['word']!.toUpperCase(), 
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
