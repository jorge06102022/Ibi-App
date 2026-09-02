/// Constantes globales de configuración del sistema IBI
class AppConstants {
  AppConstants._();

  static const String appName = 'ibi';
  static const String appTagline = 'Comunicación accesible e inclusiva';

  // Responsive Breakpoints
  static const double maxContentWidthMobile = 500.0;
  static const double maxContentWidthTablet = 600.0;
  static const double tabletBreakpoint = 600.0;

  // Frases por defecto
  static const List<String> defaultPhrases = [
    'Buenos días, soy...',
    'Necesito ayuda con esto, por favor',
    '¿Cuál es el precio de este producto?',
    'Muchas gracias por su atención',
  ];

  // Velocidades TTS admitidas
  static const List<double> supportedSpeechRates = [1.0, 1.2, 1.5];
  static const double defaultSpeechRate = 1.0;
}
