import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/praca_maquete/praca_maquete_screen.dart';
import 'package:eletrolab/screens/praca_maquete/missions/praca_maquete_m1.dart';
import 'package:eletrolab/screens/praca_maquete/missions/praca_maquete_m2.dart';
import 'package:eletrolab/screens/praca_maquete/missions/praca_maquete_m3.dart';
import 'package:eletrolab/screens/praca_maquete/missions/praca_maquete_m4.dart';
import 'package:eletrolab/screens/praca_maquete/missions/praca_maquete_m5.dart';

void main() {
  group('Estande 11 — Praça da Maquete Coletiva (Equipe Urbana) Tests', () {
    testWidgets('M1 fecha disjuntor da vila residencial em paralelo',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracaMaqueteM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 1 · Casas Iluminadas'), findsOneWidget);
      expect(find.text('MAQUETE EM ESPERA'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Fechar Disjuntor Residencial'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Fechar Disjuntor Residencial'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('REDE RESIDENCIAL ATIVA'), findsOneWidget);
    });

    testWidgets('M2 comprova tolerância a falhas na iluminação pública',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracaMaqueteM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 2 · Rua em Funcionamento'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Simular Queima do Poste 2'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Simular Queima do Poste 2'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Poste 2 em Manutenção (3/4 Acesos)'), findsOneWidget);
    });

    testWidgets('M3 conecta estufa e portão na malha compartilhada',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracaMaqueteM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 3 · Horta e Portão'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Integrar Estufa Bio-Tech'));
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.widgetWithText(FilledButton, 'Integrar Portão da Escola'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SUBSISTEMAS URBANOS CONECTADOS'), findsOneWidget);
    });

    testWidgets('M4 audita e resolve as 3 pendências elétricas pré-feira',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracaMaqueteM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 4 · Inspeção Final'), findsOneWidget);
      expect(find.text('FALHA DE REDE DETECTADA'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Reconectar Jumper Principal'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.widgetWithText(FilledButton, 'Substituir Fusível Rompido'));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.widgetWithText(FilledButton, 'Rearmar Chave Geral da Praça'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CIDADE 100% ENERGIZADA!'), findsOneWidget);
    });

    testWidgets('M5 aciona cerimônia com Chave Mestra de Inauguração',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PracaMaqueteM5(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 5 · Visita da Comunidade'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'ENERGIZAR MAQUETE COLETIVA'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'ENERGIZAR MAQUETE COLETIVA'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CIDADE ALPHA ENERGIZADA (100%)'), findsOneWidget);
    });

    testWidgets('PracaMaqueteScreen carrega coordenador com cabeçalho',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PracaMaqueteScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('PRAÇA DA MAQUETE'), findsOneWidget);
      expect(find.text('Missão 1 · Casas Iluminadas'), findsOneWidget);
    });
  });
}
