import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase3.dart';

void main() {
  group('FirstBenchPhase3 Widget Tests', () {
    testWidgets('Renderiza bancada de mapeamento de símbolos', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase3(
              onPhaseComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Verificar títulos principais
      expect(find.textContaining('FASE 3: Associe cada componente físico'), findsOneWidget);
      expect(find.text('Bancada de Mapeamento'), findsOneWidget);
      expect(find.text('VERIFICAR ASSOCIAÇÕES'), findsOneWidget);
      expect(completed, isFalse);
    });
  });
}
