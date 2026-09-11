import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/horta_monitorada/horta_monitorada_screen.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m1.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m2.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m3.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m4.dart';
import 'package:eletrolab/screens/horta_monitorada/missions/horta_monitorada_m5.dart';

void main() {
  group('Estande 09 — Horta Monitorada (Equipe Bio-Tech) Tests', () {
    testWidgets('M1 renderiza bancada e permite ajustar potenciômetro',
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

      expect(find.text('Missão 1 · Brilho Ajustável'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('LUZ BAIXA (SUBILUMINADO)'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);

      // Ajusta o slider para zona ideal (60%)
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('M2 permite alternar iluminação solar e registrar LDR',
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

      expect(find.text('Missão 2 · Sensor de Ambiente'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Alternar para Noite Escura'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Alternar para Noite Escura'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('NOITE: LUZ AUTOMÁTICA ATIVA'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Alternar para Dia Pleno'), findsOneWidget);
    });

    testWidgets('M3 permite armar automação noturna LDR + LED',
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

      expect(find.text('Missão 3 · Luz da Estufa'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Armar Automação (OFF)'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Armar Automação (OFF)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Automação Armada (ON)'), findsOneWidget);
      expect(find.text('NOITE: LUZ AUTOMÁTICA ATIVA'), findsOneWidget);
    });

    testWidgets('M4 permite carregar capacitor e simular queda de energia',
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

      expect(find.text('Missão 4 · Energia por Instantes'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Carregar Capacitor (5V)'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Carregar Capacitor (5V)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('CARREGANDO CAPACITOR'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Simular Queda de Energia'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('RESERVA EM DESCARGA'), findsOneWidget);
    });

    testWidgets('M5 comissionamento integrado da estufa inteligente',
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

      expect(find.text('Missão 5 · Painel da Horta'), findsOneWidget);
      expect(find.text('SISTEMA INTEGRADO OPERANTE'), findsOneWidget);
    });

    testWidgets('HortaMonitoradaScreen carrega coordenador com cabeçalho',
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

      expect(find.text('HORTA MONITORADA'), findsOneWidget);
      expect(find.text('Missão 1 · Brilho Ajustável'), findsOneWidget);
    });
  });
}
