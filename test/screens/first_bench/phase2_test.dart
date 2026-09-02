import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase2.dart';

void main() {
  group('FirstBenchPhase2 Widget Tests', () {
    testWidgets('Renderiza botões e inspeciona cenário corretamente', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase2(
              onPhaseComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      );

      // Verificar título inicial
      expect(find.textContaining('FASE 2: Inspecione o circuito pronto!'), findsOneWidget);
      expect(find.textContaining('Cenário 1 — Inspeção de Circuito Perfeito'), findsOneWidget);

      // Selecionar 3 checklist chips
      await tester.tap(find.text('Bateria e Tensão 9V'));
      await tester.tap(find.text('Valor do Resistor em Ohms'));
      await tester.tap(find.text('Polaridade do LED (Ânodo/Cátodo)'));
      await tester.pump();

      // Selecionar diagnóstico correto
      await tester.tap(find.textContaining('Circuito correto e seguro'));
      await tester.pump();

      // Clicar em CONFIRMAR DIAGNÓSTICO
      final submitButton = find.text('CONFIRMAR DIAGNÓSTICO');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Fechar modal de feedback do Prof. Volts
      final okButton = find.text('CONTINUAR');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // Deve ter avançado para o Cenário 2
      expect(find.textContaining('Cenário 2 — Problema de Polaridade'), findsOneWidget);
      expect(completed, isFalse);
    });
  });
}
