import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/first_bench/first_bench_phase2.dart';

void main() {
  group('FirstBenchPhase2 Widget Tests', () {
    testWidgets('Renderiza titulos neutros e projeta fluxo completo de 5 pontos e diagnostico', (tester) async {
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

      // 1. Verificar título neutro e instrução oficial
      expect(find.text('Fase 2 — Inspecione o circuito'), findsAtLeastNWidgets(1));
      expect(find.text('Antes de ligar, confira se a montagem é segura e funcional.'), findsAtLeastNWidgets(1));

      // 2. O botão CONCLUIR INSPEÇÃO deve começar bloqueado/desabilitado
      final concludeBtnFinder = find.widgetWithText(FilledButton, 'CONCLUIR INSPEÇÃO');
      expect(concludeBtnFinder, findsOneWidget);
      final concludeBtn = tester.widget<FilledButton>(concludeBtnFinder);
      expect(concludeBtn.onPressed, isNull);

      // 3. Inspecionar e responder cada um dos 5 pontos
      // Ponto 1: Bateria
      expect(find.text('Polos da Bateria'), findsOneWidget);
      await tester.tap(find.text('Sim, a conexão entre os polos está correta.'));
      await tester.pumpAndSettle();

      // Ponto 2: Resistor
      expect(find.text('Valor do Resistor'), findsOneWidget);
      await tester.tap(find.text('Sim, o resistor de 680 Ω é adequado.'));
      await tester.pumpAndSettle();

      // Ponto 3: LED
      expect(find.text('Polaridade do LED'), findsOneWidget);
      await tester.tap(find.text('Sim, o Ânodo está no lado positivo.'));
      await tester.pumpAndSettle();

      // Ponto 4: Interruptor
      expect(find.text('Estado do Interruptor'), findsOneWidget);
      await tester.tap(find.text('Aberto (circuito desligado, sem corrente).'));
      await tester.pumpAndSettle();

      // Ponto 5: Continuidade
      expect(find.text('Continuidade dos Fios'), findsOneWidget);
      await tester.tap(find.text('Sim, todos os fios estão conectados.'));
      await tester.pumpAndSettle();

      // 4. Agora os 5 pontos foram inspecionados -> Botão CONCLUIR INSPEÇÃO fica habilitado
      final concludeBtnEnabled = tester.widget<FilledButton>(concludeBtnFinder);
      expect(concludeBtnEnabled.onPressed, isNotNull);

      // 5. Clicar em CONCLUIR INSPEÇÃO para avançar ao Diagnóstico Final
      await tester.tap(concludeBtnFinder);
      await tester.pumpAndSettle();

      // 6. Verificar tela de Diagnóstico Final
      expect(find.text('Diagnóstico Final'), findsOneWidget);
      expect(find.text('Este circuito está seguro e pronto para ser ligado?'), findsOneWidget);

      // Selecionar "Sim, está pronto para ser ligado."
      await tester.tap(find.text('Sim, está pronto para ser ligado.'));
      await tester.pumpAndSettle();

      // Clicar em CONFIRMAR DIAGNÓSTICO
      await tester.tap(find.text('CONFIRMAR DIAGNÓSTICO'));
      await tester.pumpAndSettle();

      // 7. Botão TESTAR CIRCUITO aparece
      final testBtnFinder = find.widgetWithText(FilledButton, 'TESTAR CIRCUITO');
      expect(testBtnFinder, findsOneWidget);

      // Clicar em TESTAR CIRCUITO
      await tester.tap(testBtnFinder);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // 8. Verificar modal de feedback do Prof. Volts
      expect(find.textContaining('Excelente! O circuito está seguro'), findsOneWidget);

      // Fechar feedback e avançar pro próximo cenário
      final continueBtn = find.text('CONTINUAR');
      if (continueBtn.evaluate().isNotEmpty) {
        await tester.tap(continueBtn);
        await tester.pumpAndSettle();
      }

      // Deve avançar para o próximo cenário
      expect(find.text('Fase 2 — Inspecione o circuito'), findsAtLeastNWidgets(1));
      expect(completed, isFalse);
    });

    testWidgets('Valida o cenario de LED invertido (reversedLed)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase2(
              onPhaseComplete: () {},
              initialScenario: InspectionScenario.reversedLed,
            ),
          ),
        ),
      );

      // Responder os 5 pontos no cenário reversedLed
      // Ponto 1: Bateria
      await tester.tap(find.text('Sim, a conexão entre os polos está correta.'));
      await tester.pumpAndSettle();

      // Ponto 2: Resistor
      await tester.tap(find.text('Sim, o resistor de 680 Ω é adequado.'));
      await tester.pumpAndSettle();

      // Ponto 3: LED invertido
      expect(find.text('Polaridade do LED'), findsOneWidget);
      await tester.tap(find.text('Não, o LED está invertido.'));
      await tester.pumpAndSettle();

      // Ponto 4: Interruptor
      await tester.tap(find.text('Aberto (circuito desligado, sem corrente).'));
      await tester.pumpAndSettle();

      // Ponto 5: Continuidade
      await tester.tap(find.text('Sim, todos os fios estão conectados.'));
      await tester.pumpAndSettle();

      // Concluir Inspeção
      await tester.tap(find.text('CONCLUIR INSPEÇÃO'));
      await tester.pumpAndSettle();

      // Diagnóstico: Selecionar "Não, encontrei um problema" e depois "LED invertido"
      await tester.tap(find.text('Não, encontrei um problema.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('LED invertido'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONFIRMAR DIAGNÓSTICO'));
      await tester.pumpAndSettle();

      // Testar Circuito
      await tester.tap(find.text('TESTAR CIRCUITO'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Explicação de sucesso para LED invertido
      expect(find.textContaining('O LED foi montado com a polaridade invertida'), findsOneWidget);
    });

    testWidgets('Valida o cenario de resistor ausente (missingResistor)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase2(
              onPhaseComplete: () {},
              initialScenario: InspectionScenario.missingResistor,
            ),
          ),
        ),
      );

      // Inscrever os 5 pontos
      await tester.tap(find.text('Sim, a conexão entre os polos está correta.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Não, o resistor está ausente no percurso.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, o Ânodo está no lado positivo.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aberto (circuito desligado, sem corrente).'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, todos os fios estão conectados.'));
      await tester.pumpAndSettle();

      // Concluir inspeção
      await tester.tap(find.text('CONCLUIR INSPEÇÃO'));
      await tester.pumpAndSettle();

      // Diagnóstico: Selecionar "Não, encontrei um problema" -> "Resistor ausente"
      await tester.tap(find.text('Não, encontrei um problema.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resistor ausente'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONFIRMAR DIAGNÓSTICO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TESTAR CIRCUITO'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('O circuito não possui resistor de proteção'), findsOneWidget);
    });

    testWidgets('Valida o cenario de resistor incorreto (incorrectResistor)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase2(
              onPhaseComplete: () {},
              initialScenario: InspectionScenario.incorrectResistor,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sim, a conexão entre os polos está correta.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Não, o resistor de 68 Ω é muito baixo.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, o Ânodo está no lado positivo.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aberto (circuito desligado, sem corrente).'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, todos os fios estão conectados.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONCLUIR INSPEÇÃO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Não, encontrei um problema.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resistor inadequado'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONFIRMAR DIAGNÓSTICO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TESTAR CIRCUITO'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('O resistor instalado é de apenas 68 Ω'), findsOneWidget);
    });

    testWidgets('Valida o cenario de circuito aberto (openCircuit)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstBenchPhase2(
              onPhaseComplete: () {},
              initialScenario: InspectionScenario.openCircuit,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sim, a conexão entre os polos está correta.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, o resistor de 680 Ω é adequado.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sim, o Ânodo está no lado positivo.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aberto (circuito desligado, sem corrente).'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Não, existe uma desconexão no circuito.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONCLUIR INSPEÇÃO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Não, encontrei um problema.'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Circuito aberto'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CONFIRMAR DIAGNÓSTICO'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('TESTAR CIRCUITO'));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.textContaining('Existe uma desconexão no circuito'), findsOneWidget);
    });
  });
}
