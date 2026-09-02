import 'package:flutter_test/flutter_test.dart';
import 'package:ibi/main.dart';
import 'package:ibi/caracteristicas/bienvenida/presentation/screens/pantalla_bienvenida.dart';
import 'package:ibi/caracteristicas/inicio/presentation/screens/pantalla_inicio.dart';

void main() {
  testWidgets('IbiApp inicia en PantallaBienvenida y navega a PantallaInicio al aceptar',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IbiApp());

    // Verify that PantallaBienvenida is displayed
    expect(find.byType(PantallaBienvenida), findsOneWidget);
    expect(find.text('Logotipo de IBI'), findsOneWidget);
    expect(find.text('Aceptar'), findsOneWidget);

    // Tap the 'Aceptar' button to navigate to PantallaInicio
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    // Verify that PantallaInicio is now displayed
    expect(find.byType(PantallaInicio), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
  });
}
