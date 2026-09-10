import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/widgets/workbench_table_frame.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m1.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m1.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m1.dart';

void main() {
  group('Workbench Responsiveness & Layout Reflow Tests', () {
    testWidgets('WorkbenchResponsiveLayout reflows vertically on narrow screens and row on wide screens',
        (WidgetTester tester) async {
      const narrowSize = Size(600, 800);
      await tester.binding.setSurfaceSize(narrowSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkbenchResponsiveLayout(
              workbench: Container(key: const Key('workbench_test'), height: 300),
              sidePanel: Container(key: const Key('side_panel_test'), height: 200),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byKey(const Key('workbench_test')), findsOneWidget);
      expect(find.byKey(const Key('side_panel_test')), findsOneWidget);

      // Agora em tela larga (1280x800)
      const wideSize = Size(1280, 800);
      await tester.binding.setSurfaceSize(wideSize);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkbenchResponsiveLayout(
              workbench: Container(key: const Key('workbench_test'), height: 300),
              sidePanel: Container(key: const Key('side_panel_test'), height: 200),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('Estande 08 (Circuito Seguro) renders without overflow on compact screen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('Missão 1 · Alerta de Curto'), findsOneWidget);
    });

    testWidgets('Estande 06 (Movimento em Miniatura) renders without overflow on compact screen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.text('Missão 1 · Primeiro Giro'), findsOneWidget);
    });

    testWidgets('Estande 05 (Letreros LED) renders without overflow on compact screen',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LetrerosLedM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('Placa de Saída'), findsOneWidget);
    });
  });
}
