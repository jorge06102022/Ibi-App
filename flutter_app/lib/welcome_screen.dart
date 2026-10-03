import 'package:flutter/material.dart';
import 'theme.dart';
import 'main_shell.dart';
import 'prefs.dart';

class WelcomeScreen extends StatelessWidget {
  final Prefs prefs;
  final String serverUrl;
  final VoidCallback onChangeServer;
  const WelcomeScreen({super.key, required this.prefs, required this.serverUrl, required this.onChangeServer});

  static const double _imageAspect = 539 / 1019;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AspectRatio(
                aspectRatio: _imageAspect,
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/welcome-hero.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _ChangeServerButton(onTap: onChangeServer),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: h * 0.06,
                            child: Center(
                              child: _CtaButton(
                                serverUrl: serverUrl,
                                prefs: prefs,
                                circleSize: w * 0.34,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChangeServerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChangeServerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.dns_rounded, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String serverUrl;
  final Prefs prefs;
  final double circleSize;
  const _CtaButton({required this.serverUrl, required this.prefs, required this.circleSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => MainShell(serverUrl: serverUrl, prefs: prefs),
        ));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9), Color(0xFF0369A1)],
              ),
              boxShadow: [
                BoxShadow(color: AppColors.accent.withOpacity(0.35), blurRadius: 30, spreadRadius: 3),
                const BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/icon/icon.png',
              width: circleSize * 0.6,
              height: circleSize * 0.6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'EMPEZAR CONVERSACIÓN',
            style: TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: .6,
              shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Toque para conectar',
            style: TextStyle(
              color: Colors.white70, fontSize: 11,
              shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
            ),
          ),
        ],
      ),
    );
  }
}