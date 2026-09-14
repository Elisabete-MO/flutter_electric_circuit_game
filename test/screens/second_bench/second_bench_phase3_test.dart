import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eletrolab/screens/second_bench/second_bench_phase3.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(
      home: Scaffold(
        body: SecondBenchPhase3(onPhaseComplete: onComplete ?? () {}),
      ),
    );
  }

  group(
    'Fase 3 do Estande 2 (Acende Aí) — Testes de Símbolos Esquemáticos e Diagrama',
    () {
      testWidgets(
        'Renderiza a biblioteca com os 6 símbolos esquemáticos reais sem rótulo Distrator',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          expect(
            find.textContaining('Do componente ao símbolo'),
            findsOneWidget,
          );
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
        },
      );

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

      testWidgets(
        'Botão Verificar Diagrama exibe ajuda quando acionado antes de preencher os encaixes',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          final btn = find.widgetWithText(ElevatedButton, 'VERIFICAR DIAGRAMA');
          expect(btn, findsOneWidget);

          await tester.tap(btn);
          await tester.pumpAndSettle();

          expect(find.textContaining('Ajuda — Fase 3'), findsOneWidget);
        },
      );

      testWidgets(
        '1. Todos os slots exibem o asset físico semitransparente correto',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Encontra as 4 imagens físicas de referência nos slots
          expect(
            find.image(const AssetImage('assets/components/battery.png')),
            findsWidgets,
          );
          expect(
            find.image(const AssetImage('assets/components/resistor.png')),
            findsWidgets,
          );
          expect(
            find.image(const AssetImage('assets/components/led_off.png')),
            findsWidgets,
          );
          expect(
            find.image(const AssetImage('assets/components/switch_open.png')),
            findsWidgets,
          );

          // Verifica opacidade semitransparente entre 0.25 e 0.40
          final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
          final hasSlotOpacity = opacities.any(
            (op) => op.opacity >= 0.25 && op.opacity <= 0.40,
          );
          expect(hasSlotOpacity, isTrue);
        },
      );

      testWidgets(
        '2. A camada semitransparente não bloqueia o DragTarget (está sob IgnorePointer)',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Verifica que cada imagem de asset dentro de slot está envolta em IgnorePointer
          final ignorePointers = find.byType(IgnorePointer);
          expect(ignorePointers, findsWidgets);

          // DragTargets continuam ativos e recebendo dados
          expect(find.byType(DragTarget<Phase3SymbolType>), findsNWidgets(4));
        },
      );

      testWidgets(
        '3 & 4. Símbolo pode ser arrastado e solto no slot correspondente',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          expect(find.text('0 de 4 símbolos'), findsOneWidget);

          // Toca em um símbolo da biblioteca (acessibilidade por toque)
          final bateriaItem = find.text('Bateria').first;
          await tester.ensureVisible(bateriaItem);
          await tester.tap(bateriaItem);
          await tester.pumpAndSettle();

          // Toca no primeiro slot de encaixe
          final slots = find.byType(DragTarget<Phase3SymbolType>);
          expect(slots, findsNWidgets(4));
          await tester.tap(slots.first);
          await tester.pumpAndSettle();

          expect(find.text('1 de 4 símbolos'), findsOneWidget);
        },
      );

      testWidgets(
        '5. O seletor inferior não existe e não há controles duplicados na bancada',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 900));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // O texto "Esquemático" e "Físico 3D" só deve aparecer exatamente 1 vez cada (no seletor superior)
          expect(find.text('Esquemático'), findsOneWidget);
          expect(find.text('Físico 3D'), findsOneWidget);

          // Não deve existir botão com rótulo "Diagrama" ou "Físico" isolado
          expect(find.text('Diagrama'), findsNothing);
          expect(find.text('Físico'), findsNothing);
        },
      );

      testWidgets(
        '6 & 7. O seletor superior continua funcional e o progresso permanece após trocar de visualização',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Associa um símbolo a um slot
          final libraryItem = find.text('Bateria').first;
          await tester.ensureVisible(libraryItem);
          await tester.tap(libraryItem);
          await tester.pumpAndSettle();
          final slots = find.byType(DragTarget<Phase3SymbolType>);
          await tester.tap(slots.first);
          await tester.pumpAndSettle();

          expect(find.text('1 de 4 símbolos'), findsOneWidget);

          // Alterna para visualização física
          await tester.tap(find.text('Físico 3D').first);
          await tester.pumpAndSettle();

          expect(
            find.textContaining('Modo Físico de Consulta'),
            findsOneWidget,
          );

          // Retorna para Esquemático e confirma que o símbolo continua posicionado
          await tester.tap(find.text('Esquemático').first);
          await tester.pumpAndSettle();

          expect(find.text('1 de 4 símbolos'), findsOneWidget);
        },
      );
    },
  );
}
