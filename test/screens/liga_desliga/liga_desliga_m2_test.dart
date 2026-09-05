import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/liga_desliga/missions/liga_desliga_m2.dart';

void main() {
  group('LigaDesligaM2 (Dois Cartazes) Widget Tests', () {
    testWidgets('Renderiza os dois cartazes (Cartaz A e Cartaz B) lado a lado',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM2(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifica presença de ambos os cartazes
      expect(find.text('CARTAZ A'), findsOneWidget);
      expect(find.text('CARTAZ B'), findsOneWidget);
      expect(find.text('Montagem 1: Alavanca Aberta'), findsOneWidget);
      expect(find.text('Montagem 2: Alavanca Fechada'), findsOneWidget);

      // Ambas as opções de aposta existem para ambos os cartazes (2 de cada)
      expect(find.text('VAI ACENDER'), findsNWidgets(2));
      expect(find.text('FICARÁ APAGADA'), findsNWidgets(2));

      // Inicialmente não completado
      expect(completed, isFalse);
    });

    testWidgets('Exige seleção nos dois cartazes antes de energizar',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM2(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Clica em Energizar sem selecionar nada
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      expect(energizeBtn, findsOneWidget);
      await tester.tap(energizeBtn);
      await tester.pump();

      // Verifica mensagem de aviso
      expect(
        find.text(
          'Por favor, registre sua previsão para ambos os cartazes antes de energizar!',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Valida fluxo de previsão correta e diálogo de feedback',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM2(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Seleciona Cartaz A: Ficará Apagada (primeiro botão "FICARÁ APAGADA")
      final apagaBtns = find.text('FICARÁ APAGADA');
      await tester.tap(apagaBtns.first);
      await tester.pumpAndSettle();

      // Seleciona Cartaz B: Vai Acender (segundo botão "VAI ACENDER")
      final acendeBtns = find.text('VAI ACENDER');
      await tester.tap(acendeBtns.last);
      await tester.pumpAndSettle();

      // Clica em Energizar
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      await tester.tap(energizeBtn);
      await tester.pump();

      // Aguarda revelação e feedback
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 100));

      // Diálogo da Profª Volts deve estar aberto
      expect(find.textContaining('Excelente previsão!'), findsOneWidget);

      // Clica no botão de ação do diálogo
      final continuarBtn = find.text('CONTINUAR');
      expect(continuarBtn, findsOneWidget);
      await tester.tap(continuarBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(completed, isTrue);
    });
  });
}
