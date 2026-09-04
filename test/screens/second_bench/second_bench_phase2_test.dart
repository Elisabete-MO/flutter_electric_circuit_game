import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eletrolab/screens/second_bench/second_bench_phase2.dart';
import 'package:eletrolab/models/phase2_inspection_data.dart';

void main() {
  Widget buildTestWidget({InspectionScenario scenario = InspectionScenario.correct, VoidCallback? onComplete}) {
    return MaterialApp(
      home: Scaffold(
        body: SecondBenchPhase2(
          initialScenario: scenario,
          onPhaseComplete: onComplete ?? () {},
        ),
      ),
    );
  }

  group('Fase 2 do Estande 2 (Acende Aí) — Testes de Inspeção e Diagnóstico', () {
    testWidgets('Renderiza a Fase 2 com o título e os marcadores de inspeção', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Inspecione o circuito'), findsOneWidget);
      expect(find.text('1 de 5 inspecionados'), findsOneWidget);
      expect(find.text('CONCLUIR INSPEÇÃO'), findsOneWidget);
    });

    testWidgets('Nenhum texto visível possui emojis', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );

      for (final element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          expect(
            emojiRegex.hasMatch(widget.data!),
            isFalse,
            reason: 'Emoji encontrado em: "${widget.data}"',
          );
        }
      }
    });

    testWidgets('Inspeção dos 5 pontos habilita a conclusão de inspeção', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Botão "CONCLUIR INSPEÇÃO" inicialmente desabilitado (apenas 1 ponto marcado por padrão)
      // Toca nos marcadores de 2 a 5
      for (int i = 2; i <= 5; i++) {
        final marker = find.text('$i');
        if (marker.evaluate().isNotEmpty) {
          await tester.tap(marker.first);
          await tester.pumpAndSettle();
        }
      }

      // Após inspecionar os 5 pontos, o botão fica habilitado e transita para Diagnóstico
      final button = find.widgetWithText(FilledButton, 'CONCLUIR INSPEÇÃO');
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('Diagnóstico do Circuito'), findsOneWidget);
      expect(find.text('TESTAR RESULTADO'), findsOneWidget);
    });
  });
}
