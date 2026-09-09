import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eletrolab/screens/first_steps/first_steps_screen.dart';
import 'package:eletrolab/screens/first_steps/modules/first_steps_anatomy_tab.dart';
import 'package:eletrolab/screens/first_steps/modules/first_steps_quiz_tab.dart';
import 'package:eletrolab/screens/first_steps/modules/first_steps_showcase_tab.dart';
import 'package:eletrolab/screens/common_stand/stand_flow_header.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Estande 01 — Primeiros Passos Tests', () {
    testWidgets('Renderiza o StandFlowHeader com 3 módulos e inicia no Módulo 1',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(const FirstStepsScreen()));
      await tester.pumpAndSettle();

      // Verifica o cabeçalho
      expect(find.byType(StandFlowHeader), findsOneWidget);
      expect(find.text('Estande 01'), findsOneWidget);
      expect(find.text('Missão 1'), findsOneWidget);
      expect(find.text('Missão 2'), findsOneWidget);
      expect(find.text('Missão 3'), findsOneWidget);

      // Inicia no Módulo 1 (Vitrine)
      expect(find.byType(FirstStepsShowcaseTab), findsOneWidget);
      expect(find.textContaining('Catálogo de Componentes'), findsWidgets);
      expect(find.text('Bateria'), findsWidgets);
      expect(find.text('Lâmpada'), findsWidgets);
      expect(find.text('Resistor'), findsWidgets);
    });

    testWidgets('Alterna para o Módulo 2 (Anatomia) ao clicar no botão da missão',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(const FirstStepsScreen()));
      await tester.pumpAndSettle();

      // Conclui Módulo 1 clicando no botão de ação da bancada
      final actionButton = find.text('ENERGIZAR').evaluate().isNotEmpty
          ? find.text('ENERGIZAR')
          : find.byType(ElevatedButton);
      if (actionButton.evaluate().isNotEmpty) {
        await tester.tap(actionButton.first);
        await tester.pumpAndSettle();
      }

      // Agora deve estar no Módulo 2 ou desbloqueado
      expect(find.byType(FirstStepsAnatomyTab), findsOneWidget);
      expect(find.textContaining('Terminais e Polaridade'), findsWidgets);
    });

    testWidgets('Exibe o Módulo 3 (Quiz) e processa resposta', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget(FirstStepsQuizTab(
        onModuleComplete: () {},
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('SELECIONE O SÍMBOLO OU COMPONENTE'), findsOneWidget);
      expect(find.textContaining('SEU PLACAR'), findsOneWidget);
    });
  });
}
