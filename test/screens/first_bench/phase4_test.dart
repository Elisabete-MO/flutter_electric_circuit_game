import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase4.dart';

void main() {
  group('FirstBenchPhase4 Widget Tests', () {
    testWidgets('Renderiza bancada livre controlada da Fase 4', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase4(
              onPhaseComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Verificar elementos principais da interface da Fase 4
      expect(find.textContaining('FASE 4: Monte o circuito livremente!'), findsOneWidget);
      expect(find.text('Biblioteca:'), findsOneWidget);

      // Verificar chips da biblioteca controlada
      expect(find.text('Bateria 9V'), findsOneWidget);
      expect(find.text('Interruptor'), findsOneWidget);
      expect(find.text('LED Vermelho'), findsOneWidget);
      expect(find.text('Resistor 680 Ω'), findsOneWidget);

      expect(completed, isFalse);
    });
  });
}
