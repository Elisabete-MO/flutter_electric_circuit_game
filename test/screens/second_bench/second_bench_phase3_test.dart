import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eletrolab/screens/second_bench/second_bench_phase3.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(
      home: Scaffold(
        body: SecondBenchPhase3(
          onPhaseComplete: onComplete ?? () {},
        ),
      ),
    );
  }

  group('Fase 3 do Estande 2 (Acende Aí) — Testes de Símbolos Esquemáticos e Diagrama', () {
    testWidgets('Renderiza a biblioteca com os 6 símbolos esquemáticos reais sem rótulo Distrator', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Do componente ao símbolo'), findsOneWidget);
      expect(find.text('Biblioteca de Símbolos'), findsOneWidget);

      // Símbolos esperados
      expect(find.text('Bateria'), findsWidgets);
      expect(find.text('Resistor'), findsWidgets);
      expect(find.text('LED'), findsWidgets);
      expect(find.text('Interruptor'), findsWidgets);
      expect(find.text('Lâmpada'), findsWidgets);
      expect(find.text('Diodo'), findsWidgets);

      // Não deve existir o selo "Distrator"
      expect(find.text('Distrator'), findsNothing);
    });

    testWidgets('Alterna entre modo Físico e Diagrama', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Modo Diagrama ativo por padrão
      expect(find.text('0 de 4 símbolos'), findsOneWidget);

      // Toca na opção Físico 3D
      await tester.tap(find.text('Físico 3D').first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Modo Físico de Consulta'), findsOneWidget);

      // Retorna para Esquemático
      await tester.tap(find.text('Esquemático').first);
      await tester.pumpAndSettle();

      expect(find.text('0 de 4 símbolos'), findsOneWidget);
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

    testWidgets('Botão Verificar Diagrama exibe ajuda quando acionado antes de preencher os encaixes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final btn = find.widgetWithText(ElevatedButton, 'VERIFICAR DIAGRAMA');
      expect(btn, findsOneWidget);

      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Ajuda — Fase 3'), findsOneWidget);
    });
  });
}
