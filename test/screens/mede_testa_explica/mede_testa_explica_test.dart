import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/mede_testa_explica/missions/mede_testa_explica_m1.dart';
import 'package:eletrolab/screens/mede_testa_explica/missions/mede_testa_explica_m2.dart';
import 'package:eletrolab/screens/mede_testa_explica/missions/mede_testa_explica_m3.dart';
import 'package:eletrolab/screens/mede_testa_explica/missions/mede_testa_explica_m4.dart';
import 'package:eletrolab/screens/mede_testa_explica/missions/mede_testa_explica_m5.dart';
import 'package:eletrolab/screens/mede_testa_explica/widgets/mede_testa_explica_widgets.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Estande 07 — Mede, Testa e Explica (Instrumentação & Lei de Ohm)', () {
    testWidgets('M1 renderiza multímetro digital, bateria 9V realista e canetas de prova soltas na bancada', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Realistic9VBatteryWidget), findsOneWidget);
      expect(find.byType(DigitalMultimeterWidget), findsOneWidget);
      expect(find.byType(ProbePenWidget), findsNWidgets(2));
      // Pontas iniciam soltas na bancada: display indica 0.00V
      expect(find.textContaining('0.00'), findsWidgets);

      // Conecta ponta vermelha no polo (+) e ponta preta no polo (-)
      final redButton = find.textContaining('Ponta Vermelha:');
      final blackButton = find.textContaining('Ponta Preta:');
      await tester.tap(redButton); // null -> pos
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(blackButton); // null -> neg
      await tester.pump(const Duration(milliseconds: 100));

      // Agora conectadas na polaridade correta: 9.00V
      expect(find.textContaining('9.00'), findsWidgets);
    });

    testWidgets('M1 inverte polaridade para -9.00V quando pontas são trocadas e permite soltar na bancada', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      final redButton = find.textContaining('Ponta Vermelha:');
      final blackButton = find.textContaining('Ponta Preta:');

      // Conecta invertido: Vermelha no NEG, Preta no POS
      await tester.tap(redButton); // -> pos
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(redButton); // -> neg
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(blackButton); // -> neg
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(blackButton); // -> pos
      await tester.pump(const Duration(milliseconds: 50));

      // Pontas invertidas: Vermelha em NEG e Preta em POS -> ddp = -9.00V
      expect(find.text('-9.00'), findsWidgets);

      // Soltar pontas na bancada
      final releaseButton = find.textContaining('Soltar Pontas na Bancada');
      await tester.tap(releaseButton);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('0.00'), findsWidgets);
    });

    testWidgets('M2 permite alternar chave e medir queda de tensão na lâmpada', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM2(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ProbePenWidget), findsNWidgets(2));
      expect(find.textContaining('CHAVE: FECHADA (ON)'), findsOneWidget);
      expect(find.text('LÂMPADA'), findsOneWidget);

      // Alterna chave para aberta
      await tester.tap(find.textContaining('CHAVE: FECHADA (ON)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('CHAVE: ABERTA (OFF)'), findsOneWidget);
    });

    testWidgets('M3 possui potenciômetro rotativo tátil e atualiza corrente em tempo real', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM3(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ProbePenWidget), findsNWidgets(2));
      expect(find.textContaining('POTENCIÔMETRO (R)'), findsOneWidget);
      expect(find.textContaining('500 Ω'), findsWidgets);
      // I = 7V / 500Ω = 14.0 mA
      expect(find.textContaining('14.0'), findsWidgets);

      // Clica no botão +50 Ω
      final addFinder = find.byTooltip('+50 Ω');
      await tester.tap(addFinder);
      await tester.pump(const Duration(milliseconds: 200));

      // R passa a 550 Ω
      expect(find.textContaining('550 Ω'), findsWidgets);
    });

    testWidgets('M4 permite selecionar resistores da gaveta e valida faixa segura', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ProbePenWidget), findsNWidgets(2));
      expect(find.textContaining('FAIXA SEGURA'), findsOneWidget);
      expect(find.textContaining('680 Ω'), findsWidgets);

      // Seleciona 100 Ω (sobrecorrente)
      await tester.tap(find.textContaining('100 Ω'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('FORA DA FAIXA'), findsOneWidget);
    });

    testWidgets('M5 executa perícia elétrica, diagnostica falha e substitui peça defeituosa', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(MedeTestaExplicaM5(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ProbePenWidget), findsNWidgets(2));
      expect(find.textContaining('10 kΩ !'), findsOneWidget);
      expect(find.textContaining('ANÔMALO'), findsOneWidget);

      // Executa a substituição pericial
      final replaceButton = find.textContaining('SUBSTITUIR POR 680 Ω');
      await tester.tap(replaceButton);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('RESISTOR 680 Ω INSTALADO'), findsOneWidget);
      expect(find.textContaining('CORRETO'), findsOneWidget);
      expect(find.textContaining('ACESO (10mA)'), findsOneWidget);
    });
  });
}
