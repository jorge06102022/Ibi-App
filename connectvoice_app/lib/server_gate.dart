import 'package:flutter/material.dart';
import 'prefs.dart';
import 'welcome_screen.dart';
import 'theme.dart';

class ServerGate extends StatefulWidget {
  const ServerGate({super.key});
  @override
  State<ServerGate> createState() => _ServerGateState();
}

class _ServerGateState extends State<ServerGate> {
  final _controller = TextEditingController();
  bool _loading = true;
  Prefs? _prefs;
  String? _savedUrl;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await Prefs.load();
    setState(() {
      _prefs = prefs;
      _savedUrl = prefs.serverUrl;
      _controller.text = prefs.serverUrl ?? 'http://10.0.2.2:8000';
      _loading = false;
    });
  }

  Future<void> _connect() async {
    final url = _controller.text.trim();
    if (url.isEmpty || _prefs == null) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La URL debe empezar con http:// o https://')),
      );
      return;
    }
    await _prefs!.setServerUrl(url);
    setState(() => _savedUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg0,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_savedUrl != null && _savedUrl!.isNotEmpty && _prefs != null) {
      return WelcomeScreen(
        prefs: _prefs!,
        serverUrl: _savedUrl!,
        onChangeServer: () async {
          await _prefs!.clearServerUrl();
          setState(() => _savedUrl = null);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg0, AppColors.bg2],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x5500D4FF), blurRadius: 40, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.hearing_rounded, size: 42, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'IBI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tx1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Comunicación bidireccional en tiempo real',
                      style: TextStyle(color: AppColors.tx2, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.bg1,
                      borderRadius: BorderRadius.circular(AppRadius.r3),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Dirección de tu servidor',
                          style: TextStyle(color: AppColors.tx1, fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '• Emulador + servidor en tu PC: http://10.0.2.2:8000\n'
                          '• Celular físico + misma WiFi: http://IP_DE_TU_PC:8000\n'
                          '• Servidor en internet: https://tu-dominio.com',
                          style: TextStyle(color: AppColors.tx2, fontSize: 12.5, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          style: const TextStyle(color: AppColors.tx1),
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            hintText: 'http://192.168.1.10:8000',
                            prefixIcon: Icon(Icons.dns_rounded, color: AppColors.tx2, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: 'Conectar',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _connect,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}