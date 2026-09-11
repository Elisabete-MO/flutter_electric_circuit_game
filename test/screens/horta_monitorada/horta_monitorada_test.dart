import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/common_stand/stand_flow_header.dart';
import 'package:eletrolab/screens/horta_monitorada/horta_monitorada_screen.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m1.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m2.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m3.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m4.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m5.dart';

void main() {
  group('Estande 09 — Horta Monitorada (Equipe Bio-Tech) Tests', () {
    testWidgets('M1 renderiza split-view e permite ajustar potenciômetro de iluminação',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HortaMonitoradaM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 1 · Luz de Cultivo'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('LUZ FRACA'), findsOneWidget);

      // Deslizar o potenciômetro para aumentar a luz
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('M2 permite simular solo seco e úmido na sonda resistiva',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HortaMonitoradaM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 2 · Sonda de Umidade'), findsOneWidget);
      expect(find.text('ALERTA: SOLO SECO'), findsOneWidget);

      // Deslizar umidade para > 65%
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(150, 0));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SOLO HIDRATADO'), findsOneWidget);
    });

    testWidgets('M3 aciona exaustores e normaliza temperatura',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HortaMonitoradaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 3 · Ventilação Térmica'), findsOneWidget);
      expect(find.text('TEMPERATURA ELEVADA'), findsOneWidget);

      // Ligar a chave
      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget);
      await tester.tap(switchWidget);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('VENTILAÇÃO ATIVA'), findsOneWidget);
      expect(find.text('Temp. Estufa: 23.5°C'), findsOneWidget);
    });

    testWidgets('M4 dispara ciclo de irrigação e hidrata solo',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HortaMonitoradaM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 4 · Bomba de Irrigação'), findsOneWidget);
      expect(find.text('ALERTA: SOLO SECO'), findsOneWidget);

      final pumpBtn = find.widgetWithText(FilledButton, 'ACIONAR REGADOR');
      expect(pumpBtn, findsOneWidget);
      await tester.tap(pumpBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('REGANDO CANTEIRO...'), findsOneWidget);

      // Esperar ciclo da bomba terminar
      await tester.pump(const Duration(milliseconds: 1300));
      expect(find.text('SOLO REIDRATADO'), findsOneWidget);
    });

    testWidgets('M5 executa simulação de cenários ambientais no barramento geral',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HortaMonitoradaM5(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 5 · Painel Integrado'), findsOneWidget);
      expect(find.text('ESTUFA INTELIGENTE 100%'), findsOneWidget);

      // Testar seleção de cenários
      final solForteChip = find.text('2. Sol Forte');
      expect(solForteChip, findsOneWidget);
      await tester.tap(solForteChip);
      await tester.pump(const Duration(milliseconds: 200));

      final soloSecoChip = find.text('3. Solo Seco');
      expect(soloSecoChip, findsOneWidget);
      await tester.tap(soloSecoChip);
      await tester.pump(const Duration(milliseconds: 200));

      final noiteChip = find.text('4. Noite');
      expect(noiteChip, findsOneWidget);
      await tester.tap(noiteChip);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Auditoria Final do Estande:'), findsOneWidget);
    });

    testWidgets('HortaMonitoradaScreen coordena o fluxo de missões',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HortaMonitoradaScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(StandFlowHeader), findsOneWidget);
      expect(find.text('Missão 1 · Luz de Cultivo'), findsOneWidget);
    });
  });
}
