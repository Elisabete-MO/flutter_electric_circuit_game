import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/portao_escola/portao_escola_screen.dart';
import 'package:eletrolab/screens/portao_escola/missions/portao_escola_m1.dart';
import 'package:eletrolab/screens/portao_escola/missions/portao_escola_m2.dart';
import 'package:eletrolab/screens/portao_escola/missions/portao_escola_m3.dart';
import 'package:eletrolab/screens/portao_escola/missions/portao_escola_m4.dart';
import 'package:eletrolab/screens/portao_escola/missions/portao_escola_m5.dart';

void main() {
  group('Estande 10 — Portão da Escola (Equipe Automação) Tests', () {
    testWidgets('M1 aciona botão de comando e fecha contato NA do relé',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortaoEscolaM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 1 · O Relé Responde'), findsOneWidget);
      expect(find.text('PORTÃO FECHADO (STANDBY)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Pressionar Botão de Comando'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Pressionar Botão de Comando'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CONTATO NA FECHADO'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Botão Pressionado (Bobina ON)'), findsOneWidget);
    });

    testWidgets('M2 valida barreira de isolamento galvânico do relé',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortaoEscolaM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 2 · Dois Circuitos Isolados'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Atestar Isolamento do Relé'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Atestar Isolamento do Relé'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Isolamento Galvânico Atestado'), findsOneWidget);
    });

    testWidgets('M3 conecta giroflex de sinalização ao contato NA',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortaoEscolaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 3 · Luz de Sinalização'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Conectar Giroflex ao Contato NA'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Conectar Giroflex ao Contato NA'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Giroflex Conectado ao NA'), findsOneWidget);
    });

    testWidgets('M4 permite acionar motor redutor do portão deslizante',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortaoEscolaM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 4 · Portão em Movimento'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Acionar Motor do Portão'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Acionar Motor do Portão'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('MOTOR EM MOVIMENTO (ABRINDO)'), findsOneWidget);
    });

    testWidgets('M5 testa comando de abertura e botão de emergência',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PortaoEscolaM5(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 5 · Botão do Visitante'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Botoeira de Abertura (Verde)'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Botoeira de Abertura (Verde)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MOTOR EM MOVIMENTO (ABRINDO)'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Parada de Emergência (Vermelho)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('PARADA DE EMERGÊNCIA (NF ABERTO)'), findsOneWidget);
    });

    testWidgets('PortaoEscolaScreen carrega coordenador com cabeçalho',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PortaoEscolaScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('PORTÃO DA ESCOLA'), findsOneWidget);
      expect(find.text('Missão 1 · O Relé Responde'), findsOneWidget);
    });
  });
}
