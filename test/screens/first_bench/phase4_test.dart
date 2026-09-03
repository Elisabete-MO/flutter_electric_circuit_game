import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase4.dart';
import 'package:eletrolab/services/circuit_validator.dart';

void main() {
  group('FirstBenchPhase4 Widget & Circuit Validator Tests', () {
    testWidgets('Renderiza bancada livre da Fase 4 inicialmente VAZIA', (tester) async {
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

      // 1. Verificar cabeçalho da Fase 4
      expect(find.text('Fase 4 — Bancada livre'), findsOneWidget);
      expect(
          find.text('Monte e teste o circuito que acenderá a primeira luz da maquete.'),
          findsOneWidget);

      // 2. Verificar painel creme de peças disponíveis
      expect(find.text('Peças disponíveis'), findsOneWidget);
      expect(find.text('Bateria 9 V'), findsOneWidget);
      expect(find.text('Interruptor'), findsOneWidget);
      expect(find.text('LED vermelho'), findsOneWidget);
      expect(find.text('68 Ω'), findsOneWidget);
      expect(find.text('680 Ω'), findsOneWidget);
      expect(find.text('6,8 kΩ'), findsOneWidget);
      expect(find.text('Fio'), findsOneWidget);
      expect(find.text('Remover conexão'), findsOneWidget);

      // 3. Verificar estado inicial da bancada (Pill "Bancada vazia")
      expect(find.text('Bancada vazia'), findsOneWidget);

      // 4. Verificar botões do rodapé (Desfazer, Limpar bancada e Testar circuito inicialmente desabilitados)
      final undoButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Desfazer'));
      expect(undoButton.onPressed, isNull);

      final clearButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Limpar bancada'));
      expect(clearButton.onPressed, isNull);

      final testButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Testar circuito'));
      expect(testButton.onPressed, isNull);

      expect(completed, isFalse);
    });

    testWidgets('Adiciona componente da biblioteca e habilita botões', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase4(
              onPhaseComplete: () {},
            ),
          ),
        ),
      );

      // Adicionar Bateria 9V clicando no card da biblioteca
      await tester.tap(find.text('Bateria 9 V'));
      await tester.pumpAndSettle();

      // Verificar que o pill e o botão "Testar circuito" atualizaram
      expect(find.textContaining('1 componente(s)'), findsOneWidget);

      final testButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Testar circuito'));
      expect(testButton.onPressed, isNotNull);

      final clearButton = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Limpar bancada'));
      expect(clearButton.onPressed, isNotNull);
    });

    group('Validações Elétricas do Grafo (CircuitValidator)', () {
      const validator = CircuitValidator();

      test('Circuito seguro e funcional com 680 Ω e interruptor fechado', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
        const sw = CircuitComponentInstance(id: 'sw', kind: CircuitComponentKind.switchComponent, isSwitchClosed: true);
        const res = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 680.0);
        const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

        final graph = CircuitGraph(
          components: [bat, sw, res, led],
          connections: [
            CircuitConnection(bat.terminalA, sw.terminalA),
            CircuitConnection(sw.terminalB, res.terminalA),
            CircuitConnection(res.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, bat.terminalB),
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.safeAndLit));
        expect(result.energizationAllowed, isTrue);
        expect(result.currentmA, closeTo(10.3, 0.5));
      });

      test('Circuito correto porém com interruptor aberto', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
        const sw = CircuitComponentInstance(id: 'sw', kind: CircuitComponentKind.switchComponent, isSwitchClosed: false);
        const res = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 680.0);
        const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

        final graph = CircuitGraph(
          components: [bat, sw, res, led],
          connections: [
            CircuitConnection(bat.terminalA, sw.terminalA),
            CircuitConnection(sw.terminalB, res.terminalA),
            CircuitConnection(res.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, bat.terminalB),
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.validButOpen));
      });

      test('LED invertido (corrente tenta entrar pelo cátodo)', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
        const sw = CircuitComponentInstance(id: 'sw', kind: CircuitComponentKind.switchComponent, isSwitchClosed: true);
        const res = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 680.0);
        const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

        final graph = CircuitGraph(
          components: [bat, sw, res, led],
          connections: [
            CircuitConnection(bat.terminalA, sw.terminalA),
            CircuitConnection(sw.terminalB, res.terminalA),
            CircuitConnection(res.terminalB, led.terminalB), // Entrando no Cátodo
            CircuitConnection(led.terminalA, bat.terminalB), // Saindo pelo Ânodo
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.reversedLed));
      });

      test('Resistor de 68 Ω causa corrente excessiva', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
        const res = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 68.0);
        const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

        final graph = CircuitGraph(
          components: [bat, res, led],
          connections: [
            CircuitConnection(bat.terminalA, res.terminalA),
            CircuitConnection(res.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, bat.terminalB),
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.excessiveCurrent));
      });

      test('Resistor de 6,8 kΩ resulta em corrente muito baixa', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);
        const res = CircuitComponentInstance(id: 'res', kind: CircuitComponentKind.resistor, resistanceOhms: 6800.0);
        const led = CircuitComponentInstance(id: 'led', kind: CircuitComponentKind.led);

        final graph = CircuitGraph(
          components: [bat, res, led],
          connections: [
            CircuitConnection(bat.terminalA, res.terminalA),
            CircuitConnection(res.terminalB, led.terminalA),
            CircuitConnection(led.terminalB, bat.terminalB),
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.lowCurrent));
      });

      test('Detecta curto-circuito (ligação direta entre polos + e - da bateria)', () {
        const bat = CircuitComponentInstance(id: 'bat', kind: CircuitComponentKind.battery);

        final graph = CircuitGraph(
          components: [bat],
          connections: [
            CircuitConnection(bat.terminalA, bat.terminalB),
          ],
        );

        final result = validator.validate(graph);
        expect(result.status, equals(CircuitStatus.shortCircuit));
      });
    });
  });
}
