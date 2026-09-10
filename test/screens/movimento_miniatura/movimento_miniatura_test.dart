import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m1.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m2.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m3.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m4.dart';
import 'package:eletrolab/screens/movimento_miniatura/missions/movimento_miniatura_m5.dart';

void main() {
  group('Estande 06 — Movimento em Miniatura (Motor CC) Tests', () {
    testWidgets('M1 renderiza Motor CC na Protoboard e permite conexão',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM1(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 1 · Primeiro Giro'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Conectar Motor CC na Protoboard'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Conectar Motor CC na Protoboard'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Motor Conectado na Protoboard'), findsOneWidget);
    });

    testWidgets('M2 permite inverter polaridade do Motor CC na Protoboard',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 2 · Troca de Sentido'), findsOneWidget);
      expect(find.textContaining('Polaridade Direta'), findsOneWidget);

      await tester.tap(find.textContaining('Polaridade Direta'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Polaridade Invertida'), findsOneWidget);
    });

    testWidgets('M3 instala e aciona Pushbutton em série com Motor CC',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 3 · Botão de Partida'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Instalar Pushbutton na Protoboard'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Instalar Pushbutton na Protoboard'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Pushbutton Instalado na Vala'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'PRESSIONAR BOTÃO (TESTE)'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'PRESSIONAR BOTÃO (TESTE)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'BOTÃO PRESSIONADO (ON)'), findsOneWidget);
    });

    testWidgets('M4 instala Transistor NPN e LED indicador de status',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 4 · Chaveamento & Indicador'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Instalar Transistor NPN'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Conectar LED Indicador'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Instalar Transistor NPN'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(FilledButton, 'Conectar LED Indicador'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Transistor NPN Instalado'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'LED Indicador Verde Conectado'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'DISPARAR BASE NPN'), findsOneWidget);
    });

    testWidgets('M5 instala Ponte H e comanda canais D0 e D1',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovimentoMiniaturaM5(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Missão 5 · Ponte H Bidirecional'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Instalar Ponte H na Protoboard'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Instalar Ponte H na Protoboard'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.widgetWithText(FilledButton, 'Ponte H Conectada (4x NPN)'), findsOneWidget);
      expect(find.textContaining('CANAL D0: HORÁRIO'), findsOneWidget);
      expect(find.textContaining('CANAL D1: ANTI-HORÁRIO'), findsOneWidget);

      await tester.tap(find.textContaining('CANAL D1: ANTI-HORÁRIO'));
      await tester.pump(const Duration(milliseconds: 200));
    });
  });
}
