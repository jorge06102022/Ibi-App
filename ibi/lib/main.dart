import 'package:flutter/material.dart';
import 'caracteristicas/bienvenida/presentation/screens/pantalla_bienvenida.dart';
import 'caracteristicas/inicio/presentation/screens/pantalla_inicio.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

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
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
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