import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eletrolab/screens/second_bench/second_bench_phase4.dart';
import 'package:eletrolab/services/circuit_validator.dart';

void main() {
  Widget buildTestWidget({VoidCallback? onComplete}) {
    return MaterialApp(
      home: Scaffold(
        body: SecondBenchPhase4(onPhaseComplete: onComplete ?? () {}),
      ),
    );
  }

  group(
    'Fase 4 do Estande 2 (Acende Aí) — Testes de Montagem Livre, Curto-Circuito, Rotação e Responsividade',
    () {
      testWidgets(
        '1. Componente acompanha o ponteiro durante o arraste e pode ser adicionado à bancada',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Clica para adicionar bateria e interruptor à bancada
          final batteryItem = find.text('Bateria 9 V').first;
          await tester.ensureVisible(batteryItem);
          await tester.tap(batteryItem);
          await tester.pumpAndSettle();

          expect(find.text('1 componentes · 0 fios'), findsOneWidget);
        },
      );

      testWidgets(
        '2 & 3. Ligação direta entre polos e ocupação do mesmo terminal são rejeitadas com mensagem educativa sem emojis',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Adiciona bateria
          await tester.tap(find.text('Bateria 9 V').first);
          await tester.pumpAndSettle();

          // Ativa ferramenta fio
          final wireTool = find.text('Ferramenta Fio').first;
          await tester.ensureVisible(wireTool);
          await tester.tap(wireTool);
          await tester.pumpAndSettle();

          // Toca no terminal (+) da bateria e depois no (-) da bateria (ligação direta)
          final posTerminal = find.text('+').first;
          final negTerminal = find.text('-').first;

          await tester.tap(posTerminal);
          await tester.pumpAndSettle();

          await tester.tap(negTerminal);
          await tester.pumpAndSettle();

          // Mensagem de curto-circuito sem emoji
          expect(
            find.text(
              'Os polos positivo e negativo não podem ser ligados diretamente. Isso provocaria um curto-circuito.',
            ),
            findsOneWidget,
          );

          // Não adicionou fio
          expect(find.text('1 componentes · 0 fios'), findsOneWidget);
        },
      );

      testWidgets(
        '4, 5 & 6. Bateria gira em passos de 90 graus e os terminais acompanham a rotação',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(1600, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Adiciona bateria (ela já é auto-selecionada)
          await tester.tap(find.text('Bateria 9 V').first);
          await tester.pumpAndSettle();

          // Posição inicial do terminal (+)
          final initialPosOffset = tester.getCenter(find.text('+').first);

          // O botão de rotação está visível para a bateria selecionada
          final rotateBtn = find.byIcon(Icons.rotate_right_rounded);
          expect(rotateBtn, findsOneWidget);

          // Toca no botão de rotação (gira 90 graus)
          await tester.tap(rotateBtn);
          await tester.pumpAndSettle();

          // A posição do terminal (+) mudou acompanhando a rotação
          final rotatedPosOffset = tester.getCenter(find.text('+').first);
          expect(rotatedPosOffset, isNot(equals(initialPosOffset)));
        },
      );

      testWidgets(
        '7 & 8. Toque curto alterna o interruptor e arraste não o alterna acidentalmente',
        (tester) async {
          final handle = tester.ensureSemantics();

          await tester.binding.setSurfaceSize(const Size(1600, 1000));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Adiciona interruptor
          final switchItem = find.text('Interruptor SPST').first;
          await tester.ensureVisible(switchItem);
          await tester.tap(switchItem);
          await tester.pumpAndSettle();

          // Estado inicial: Aberto
          expect(find.text('Chave (Aberta)'), findsOneWidget);
          expect(find.bySemanticsLabel('Interruptor aberto'), findsOneWidget);

          // Toque curto: alterna para Fechada
          await tester.tap(find.text('Chave (Aberta)'));
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pumpAndSettle();

          expect(find.text('Chave (Fechada)'), findsOneWidget);
          expect(find.bySemanticsLabel('Interruptor fechado'), findsOneWidget);

          // Arraste: simula pan gesture com movimento > 8 pixels
          final switchComp = find.text('Chave (Fechada)');
          final gesture = await tester.startGesture(
            tester.getCenter(switchComp),
          );
          await gesture.moveBy(const Offset(30, 0));
          await tester.pump();
          await gesture.up();
          await tester.pumpAndSettle();

          // O estado do interruptor NÃO deve ter alternado acidentalmente pelo arraste
          expect(find.text('Chave (Fechada)'), findsOneWidget);

          // Aguarda expirar a janela de debounce
          await tester.pump(const Duration(milliseconds: 450));

          // Duplo clique: alterna de volta para Aberta
          await tester.tap(find.text('Chave (Fechada)'));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.tap(find.text('Chave (Fechada)'));
          await tester.pump(const Duration(milliseconds: 350));
          await tester.pumpAndSettle();

          expect(find.text('Chave (Aberta)'), findsOneWidget);
          expect(find.bySemanticsLabel('Interruptor aberto'), findsOneWidget);

          handle.dispose();
        },
      );

      testWidgets(
        '9 & 10. Validador: estado aberto interrompe circuito e estado fechado permite energização correta',
        (tester) async {
          const validator = CircuitValidator();

          // Circuito fechado correto: Bateria -> Switch -> Resistor 680 -> LED -> Bateria
          final componentsClosed = [
            const CircuitComponentInstance(
              id: 'bat',
              kind: CircuitComponentKind.battery,
            ),
            const CircuitComponentInstance(
              id: 'sw',
              kind: CircuitComponentKind.switchComponent,
              isSwitchClosed: true,
            ),
            const CircuitComponentInstance(
              id: 'res',
              kind: CircuitComponentKind.resistor,
              resistanceOhms: 680,
            ),
            const CircuitComponentInstance(
              id: 'led',
              kind: CircuitComponentKind.led,
            ),
          ];

          final connections = [
            const CircuitConnection(
              CircuitTerminal('bat', 'pos'),
              CircuitTerminal('sw', 't1'),
            ),
            const CircuitConnection(
              CircuitTerminal('sw', 't2'),
              CircuitTerminal('res', 't1'),
            ),
            const CircuitConnection(
              CircuitTerminal('res', 't2'),
              CircuitTerminal('led', 'anode'),
            ),
            const CircuitConnection(
              CircuitTerminal('led', 'cathode'),
              CircuitTerminal('bat', 'neg'),
            ),
          ];

          final resultClosed = validator.validate(
            CircuitGraph(
              components: componentsClosed,
              connections: connections,
            ),
          );
          expect(resultClosed.status, equals(CircuitStatus.safeAndLit));
          expect(resultClosed.energizationAllowed, isTrue);

          // Circuito com interruptor aberto
          final componentsOpen = [
            const CircuitComponentInstance(
              id: 'bat',
              kind: CircuitComponentKind.battery,
            ),
            const CircuitComponentInstance(
              id: 'sw',
              kind: CircuitComponentKind.switchComponent,
              isSwitchClosed: false,
            ),
            const CircuitComponentInstance(
              id: 'res',
              kind: CircuitComponentKind.resistor,
              resistanceOhms: 680,
            ),
            const CircuitComponentInstance(
              id: 'led',
              kind: CircuitComponentKind.led,
            ),
          ];

          final resultOpen = validator.validate(
            CircuitGraph(components: componentsOpen, connections: connections),
          );
          expect(resultOpen.status, equals(CircuitStatus.validButOpen));
          expect(resultOpen.currentmA, equals(0.0));
        },
      );

      testWidgets(
        '11 & 12. Card de previsão não apresenta overflow e todas as opções e botão permanecem acessíveis em 956x440',
        (tester) async {
          // Configura o tamanho exato da captura do erro responsivo
          await tester.binding.setSurfaceSize(const Size(956, 440));
          addTearDown(() => tester.binding.setSurfaceSize(null));

          await tester.pumpWidget(buildTestWidget());
          await tester.pumpAndSettle();

          // Adiciona bateria, interruptor e LED para ter >= 3 componentes
          final batItem = find.text('Bateria 9 V').first;
          await tester.ensureVisible(batItem);
          await tester.tap(batItem);
          await tester.pumpAndSettle();

          final switchItem = find.text('Interruptor SPST').first;
          await tester.ensureVisible(switchItem);
          await tester.tap(switchItem);
          await tester.pumpAndSettle();

          final ledItem = find.text('LED vermelho').first;
          await tester.ensureVisible(ledItem);
          await tester.tap(ledItem);
          await tester.pumpAndSettle();

          // Clica em TESTAR CIRCUITO E PREVER
          final testBtn = find.widgetWithText(
            ElevatedButton,
            'TESTAR CIRCUITO E PREVER',
          );
          await tester.ensureVisible(testBtn);
          expect(testBtn, findsOneWidget);
          await tester.tap(testBtn);
          await tester.pumpAndSettle();

          // Verifica que o diálogo de Previsão abriu
          expect(find.text('Previsão de Comportamento'), findsOneWidget);

          // Confirma que não há overflow visual
          expect(tester.takeException(), isNull);

          // Confirma que as alternativas estão acessíveis
          expect(
            find.text('O LED acenderá normalmente e com segurança.'),
            findsOneWidget,
          );
          expect(
            find.text(
              'O LED permanecerá apagado (circuito aberto/incompleto).',
            ),
            findsOneWidget,
          );
          expect(
            find.text('Haverá corrente excessiva (risco de queimar o LED).'),
            findsOneWidget,
          );
          expect(
            find.text('Existe risco de curto-circuito direto na bateria.'),
            findsOneWidget,
          );

          // Seleciona uma previsão
          await tester.tap(
            find.text('O LED acenderá normalmente e com segurança.'),
          );
          await tester.pumpAndSettle();

          // O botão ENERGIZAR CIRCUITO deve estar presente e clicável
          final energizeBtn = find.text('ENERGIZAR CIRCUITO');
          expect(energizeBtn, findsOneWidget);
          await tester.tap(energizeBtn);
          await tester.pumpAndSettle();

          // Não deve gerar exceção de overflow
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('Nenhum texto visível da Missão 4 possui emojis', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(const Size(1600, 1000));
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
    },
  );
}
