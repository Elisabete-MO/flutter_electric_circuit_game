import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase3.dart';

void main() {
  group('FirstBenchPhase3 Widget Tests', () {
    testWidgets('Renderiza bancada de mapeamento de símbolos e prancheta técnica', (tester) async {
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

      // Verificar título e subtítulo da fase
      expect(find.text('Fase 3 — Do componente ao símbolo'), findsOneWidget);
      expect(find.text('Transforme o circuito físico em seu diagrama elétrico.'), findsOneWidget);

      // Verificar seletor de modo
      expect(find.text('Físico'), findsOneWidget);
      expect(find.text('Diagrama'), findsOneWidget);

      // Verificar biblioteca lateral e controles inferiores
      expect(find.text('Símbolos disponíveis'), findsOneWidget);
      expect(find.text('0 de 4 símbolos posicionados'), findsOneWidget);
      expect(find.text('Reiniciar'), findsOneWidget);
      expect(find.text('Verificar diagrama'), findsOneWidget);

      expect(completed, isFalse);
    });

    testWidgets('Alterna entre modo Físico e Diagrama', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase3(
              onPhaseComplete: () {},
            ),
          ),
        ),
      );

      // Alternar para modo Físico
      await tester.tap(find.text('Físico'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Modo Físico de Consulta'), findsOneWidget);

      // Alternar de volta para Diagrama
      await tester.tap(find.text('Diagrama'));
      await tester.pumpAndSettle();

      expect(find.text('Símbolos disponíveis'), findsOneWidget);
    });
  });
}

