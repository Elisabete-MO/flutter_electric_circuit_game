import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_electric_circuit_game/main.dart';

void main() {
  testWidgets('shows the base MVP activity structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EletroLabApp());

    expect(find.text('Circuito físico'), findsOneWidget);
    expect(find.text('Monte o diagrama'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Biblioteca de símbolos'), 300);
    expect(find.text('Biblioteca de símbolos'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Corrente: 0 A'), 300);
    expect(find.text('Corrente: 0 A'), findsOneWidget);

    await tester.tap(find.text('Verificar diagrama'));
    await tester.pump();

    expect(
      find.text('Complete todas as posições antes de verificar.'),
      findsOneWidget,
    );
  });
}
