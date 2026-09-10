import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m1.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m2.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m3.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m4.dart';
import 'package:eletrolab/screens/circuito_seguro/missions/circuito_seguro_m5.dart';

void main() {
  group('Estande 08 — Circuito Seguro (Equipe Segurança) Tests', () {
    testWidgets('M1 renderiza bancada e permite remover fio de curto',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 1 · Alerta de Curto'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('CURTO-CIRCUITO'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Remover Fio de Curto'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Remover Fio de Curto'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SEGURO (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Fio de Curto Removido'), findsOneWidget);
    });

    testWidgets('M2 permite testar continuidade e reparar cabo rompido',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 2 · Continuidade & Fio Rompido'), findsOneWidget);
      expect(find.text('ABERTO (OFF)'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Testar com Pontas de Prova'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Testar com Pontas de Prova'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(OutlinedButton, 'Ocultar Pontas de Teste'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Reparar Cabo Rompido'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SEGURO (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Cabo Reparado (Contínuo)'), findsOneWidget);
    });

    testWidgets('M3 permite substituir fusível fundido por fusível 100mA',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 3 · Fusível Didático'), findsOneWidget);
      expect(find.text('FUSÍVEL ROMPIDO'), findsOneWidget);

      await tester.tap(find.textContaining('Fusível Rápido 100mA'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SEGURO (OK)'), findsOneWidget);
    });

    testWidgets('M4 permite conectar buzzer e armar chave de segurança',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 4 · Proteção & Sinalização Dupla'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Conectar Buzzer de Alarme'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Armar Chave de Segurança'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Conectar Buzzer de Alarme'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(FilledButton, 'Armar Chave de Segurança'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SEGURO (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Chave de Segurança: ARMADA'), findsOneWidget);
    });

    testWidgets('M5 audita e resolve 3 falhas na vistoria pré-feira',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircuitoSeguroM5(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 5 · Vistoria Geral da Equipe'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '1. Remover Curto-Circuito'), findsOneWidget);

      // Resolver falha 1
      await tester.tap(find.widgetWithText(FilledButton, '1. Remover Curto-Circuito'));
      await tester.pump(const Duration(milliseconds: 200));

      // Resolver falha 2
      await tester.tap(find.widgetWithText(FilledButton, '2. Trocar Fusível Fundido'));
      await tester.pump(const Duration(milliseconds: 200));

      // Resolver falha 3
      await tester.tap(find.widgetWithText(FilledButton, '3. Reparar Cabo Rompido'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('SEGURO (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '1. Curto Sanado (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '2. Fusível Íntegro 100mA (OK)'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '3. Cabo Contínuo (OK)'), findsOneWidget);
    });
  });
}
