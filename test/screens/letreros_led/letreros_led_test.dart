import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m1.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m2.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m3.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m4.dart';
import 'package:eletrolab/screens/letreros_led/missions/letreros_led_m5.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Estande 05 — Letreiros LED Tests', () {
    testWidgets('M1 renderiza Protoboard, Bateria 9V e Letreiro SAÍDA', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(LetrerosLedM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Placa de Saída'), findsOneWidget);
      expect(find.textContaining('LED na Protoboard'), findsWidgets);
    });

    testWidgets('M2 permite inverter polaridade do LED na Protoboard', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(LetrerosLedM2(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('LED Invertido'), findsWidgets);
      final flipBtn = find.textContaining('Girar LED na Protoboard');
      expect(flipBtn, findsOneWidget);

      await tester.tap(flipBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Sentido Direto'), findsWidgets);
    });

    testWidgets('M3 exibe 3 hipóteses de falhas para diagnóstico', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(LetrerosLedM3(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Investigação de Falhas'), findsOneWidget);
      expect(find.textContaining('H1: Fechar Jumper Aberto'), findsOneWidget);
      expect(find.textContaining('H2: Alinhar Resistor no Ramo'), findsOneWidget);
      expect(find.textContaining('H3: Inverter LED na Protoboard'), findsOneWidget);
    });

    testWidgets('M4 permite selecionar resistores de 68Ω, 680Ω e 6.8kΩ', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(LetrerosLedM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Selecione o Resistor'), findsOneWidget);
      expect(find.textContaining('680 Ω (Ideal / 10.3 mA)'), findsOneWidget);

      await tester.tap(find.textContaining('680 Ω (Ideal / 10.3 mA)'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('10.3mA'), findsWidgets);
    });

    testWidgets('M5 renderiza letreiros duplos e ramos independentes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(LetrerosLedM5(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Montar Ramo ENTRADA'), findsOneWidget);
      expect(find.textContaining('Montar Ramo SAÍDA'), findsOneWidget);

      await tester.tap(find.textContaining('Montar Ramo ENTRADA'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.textContaining('Montar Ramo SAÍDA'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Ramo ENTRADA Ativo'), findsOneWidget);
      expect(find.textContaining('Ramo SAÍDA Ativo'), findsOneWidget);
    });
  });
}
