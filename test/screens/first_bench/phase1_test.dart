import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/models/phase1_component_data.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase1.dart';

void main() {
  Widget createPhase1Widget({VoidCallback? onPhaseComplete}) {
    return MaterialApp(
      home: FirstBenchPhase1(
        onPhaseComplete: onPhaseComplete,
        showHeader: true,
      ),
    );
  }

  group('Phase1ComponentData', () {
    test('has exactly 5 components in defaultList', () {
      final list = Phase1ComponentData.defaultList;
      expect(list.length, equals(5));
    });

    test('defaultList contains only required 5 components', () {
      final names = Phase1ComponentData.defaultList.map((e) => e.name).toList();
      expect(names, containsAll([
        'Bateria 9 V',
        'Interruptor SPST',
        'Resistor 680 Ω',
        'LED vermelho',
        'Fios de conexão',
      ]));
      expect(names, isNot(contains('Lâmpada')));
      expect(names, isNot(contains('Diodo')));
      expect(names, isNot(contains('Motor')));
    });
  });

  group('FirstBenchPhase1 Widget Tests', () {
    testWidgets('renders title and 5 component plaques', (tester) async {
      await tester.pumpWidget(createPhase1Widget());
      await tester.pumpAndSettle();

      // Check title
      expect(find.text('Fase 1 — Conheça os componentes'), findsOneWidget);

      // Check plaque names
      expect(find.text('Bateria 9 V'), findsWidgets);
      expect(find.text('Chave SPST'), findsOneWidget);
      expect(find.text('Resistor 680 Ω'), findsOneWidget);
      expect(find.text('LED vermelho'), findsWidgets);
      expect(find.text('Fios jumper'), findsOneWidget);

      // Verify prohibited components are NOT rendered
      expect(find.text('Lâmpada'), findsNothing);
      expect(find.text('Diodo'), findsNothing);
      expect(find.text('Motor'), findsNothing);
    });

    testWidgets('component selection updates info panel and exploration counter', (tester) async {
      await tester.pumpWidget(createPhase1Widget());
      await tester.pumpAndSettle();

      // Initially Bateria is auto-selected (1 of 5 explored)
      expect(find.text('Explorados: 1 de 5'), findsOneWidget);

      // Tap on LED vermelho plaque
      await tester.tap(find.text('LED vermelho').first);
      await tester.pumpAndSettle();

      // Should update panel title to LED vermelho and increment counter to 2 de 5
      expect(find.text('Explorados: 2 de 5'), findsOneWidget);
      expect(find.text('ÂNODO'), findsOneWidget);
      expect(find.text('CÁTODO'), findsOneWidget);

      // Tap on LED vermelho again -> should NOT increment counter
      await tester.tap(find.text('LED vermelho').first);
      await tester.pumpAndSettle();
      expect(find.text('Explorados: 2 de 5'), findsOneWidget);
    });

    testWidgets('quiz button remains locked until all 5 components explored', (tester) async {
      await tester.pumpWidget(createPhase1Widget());
      await tester.pumpAndSettle();

      // Initially locked
      expect(find.text('Explorar todos para liberar o quiz'), findsOneWidget);

      // Tap all remaining 4 components
      await tester.tap(find.text('Chave SPST'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resistor 680 Ω'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LED vermelho').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fios jumper'));
      await tester.pumpAndSettle();

      // Now all 5 explored -> quiz unlocked
      expect(find.text('Explorados: 5 de 5'), findsOneWidget);
      expect(find.text('Iniciar quiz'), findsOneWidget);
    });

    testWidgets('help modal opens and closes properly', (tester) async {
      await tester.pumpWidget(createPhase1Widget());
      await tester.pumpAndSettle();

      // Tap help icon
      final helpFinder = find.byIcon(Icons.help_outline_rounded).first;
      await tester.tap(helpFinder);
      await tester.pumpAndSettle();

      // Verify modal content
      expect(find.text('Como funciona esta fase?'), findsOneWidget);
      expect(find.text('ENTENDI'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('ENTENDI'));
      await tester.pumpAndSettle();
      expect(find.text('Como funciona esta fase?'), findsNothing);
    });

    testWidgets('responsive check: renders in 360 x 740 viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createPhase1Widget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Reset physical size
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
