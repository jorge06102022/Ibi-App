import 'package:flutter/material.dart';
import 'pantallas/bienvenida.dart';
import 'pantallas/inicio.dart';

void main() {
  runApp(const IbiApp());
}

class IbiApp extends StatefulWidget {
  const IbiApp({super.key});

  @override
  State<IbiApp> createState() => _IbiAppState();
}

class _IbiAppState extends State<IbiApp> {
  bool _esModoOscuro = false;
  
  int _pantallaActual = 0;

  void _alternarModoOscuro() {
    setState(() {
      _esModoOscuro = !_esModoOscuro;
    });
  }

  void _irAInicio() {
    setState(() {
      _pantallaActual = 1;
    });
  }

  void _irABienvenida() {
    setState(() {
      _pantallaActual = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ibi',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
          onPrimary: Colors.white,
          surface: const Color(0xFFF8FAFC),
          onSurface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF38BDF8),
          primary: const Color(0xFF38BDF8),
          onPrimary: const Color(0xFF0F172A),
          surface: const Color(0xFF1E293B),
          onSurface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),

      themeMode: _esModoOscuro ? ThemeMode.dark : ThemeMode.light,

      home: _pantallaActual == 0
          ? PantallaBienvenida(
              onAceptar: _irAInicio,
            )
          : PantallaInicio(
              esModoOscuro: _esModoOscuro,
              onAlternarTema: _alternarModoOscuro,
              onEditarApodo: _irABienvenida,
            ),
    );
  }
}