import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as dartMath;
import 'theme.dart';
import 'prefs.dart';
import 'api_client.dart';
import 'chat_screen.dart';
import 'room_list_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final Prefs prefs;
  final String serverUrl;
  final VoidCallback onChangeServer;
  const WelcomeScreen({super.key, required this.prefs, required this.serverUrl, required this.onChangeServer});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final ApiClient _api = ApiClient(widget.serverUrl);
  bool _creating = false;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassContainer(
          radius: AppRadius.r4,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('NUEVA SALA', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: AppColors.tx1, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Nombre de la sala',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('CANCELAR', style: TextStyle(color: AppColors.tx2, letterSpacing: 1)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                    child: const Text('CREAR', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
    if (name == null || name.isEmpty) return;
    
    setState(() => _creating = true);
    try {
      final room = await _api.createRoom(name);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              prefs: widget.prefs,
              serverUrl: widget.serverUrl,
              room: room,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _openLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomListScreen(
          prefs: widget.prefs,
          serverUrl: widget.serverUrl,
          onChangeServer: widget.onChangeServer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: Stack(
        children: [
          // Animated Mesh Gradient Background
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (ctx, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _MeshGradientPainter(_animCtrl.value),
                ),
              );
            },
          ),
          // Noise texture overlay for premium feel
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset('assets/images/welcome-hero.jpg', fit: BoxFit.cover, errorBuilder: (c,e,s) => const SizedBox()), // Reused just for grain if available, else ignored
            ),
          ),
          
          Positioned(
            top: 50,
            right: 20,
            child: GlassContainer(
              radius: 50,
              padding: const EdgeInsets.all(4),
              child: IconButton(
                icon: const Icon(Icons.dns_rounded, color: AppColors.tx1, size: 20),
                tooltip: 'Cambiar servidor',
                onPressed: widget.onChangeServer,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Holographic Logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.accent.withOpacity(0.4), blurRadius: 60, spreadRadius: 10),
                            BoxShadow(color: AppColors.accent2.withOpacity(0.4), blurRadius: 80, spreadRadius: -10),
                          ],
                        ),
                      ),
                      GlassContainer(
                        radius: 100,
                        padding: const EdgeInsets.all(16),
                        borderColor: AppColors.accent.withOpacity(0.5),
                        child: Image.asset('assets/images/logo.png', width: 80, height: 80),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Typographic Art
                  const Text(
                    'I B I',
                    style: TextStyle(
                      color: AppColors.tx1,
                      fontSize: 56,
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 20,
                      height: 1,
                      shadows: [
                        Shadow(color: AppColors.accent, blurRadius: 30),
                        Shadow(color: AppColors.accent2, blurRadius: 60),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'COMUNICACIÓN SIN BARRERAS',
                    style: TextStyle(
                      color: AppColors.tx1.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 80),
                  
                  if (_creating)
                    const CircularProgressIndicator(color: AppColors.accent)
                  else ...[
                    // Premium Glass Buttons
                    _GlassButton(
                      label: 'CREAR SALA',
                      icon: Icons.add_circle_outline_rounded,
                      onTap: _createRoom,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 24),
                    _GlassButton(
                      label: 'BIBLIOTECA',
                      icon: Icons.library_books_rounded,
                      onTap: _openLibrary,
                      isPrimary: false,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double animation;
  _MeshGradientPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(Math.cos(animation * 3.14) * 0.5, -0.5 + Math.sin(animation * 2) * 0.2),
        radius: 1.5,
        colors: [
          AppColors.accent.withOpacity(0.15),
          AppColors.accent2.withOpacity(0.1),
          AppColors.bg0,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlassButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GlassButton({required this.label, required this.icon, required this.onTap, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: GlassContainer(
        radius: AppRadius.r4,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
        borderColor: isPrimary ? AppColors.accent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        opacity: isPrimary ? 0.1 : 0.03,
        child: SizedBox(
          width: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.tx1, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.tx1,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Math {
  static double cos(double x) => dartMath.cos(x);
  static double sin(double x) => dartMath.sin(x);
}