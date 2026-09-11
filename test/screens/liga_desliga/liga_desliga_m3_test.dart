import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/liga_desliga/missions/liga_desliga_m3.dart';

void main() {
  group('LigaDesligaM3 (Bancada de Investigação) Widget Tests', () {
    testWidgets('Renderiza bancada com placas de identificação e console de etiquetagem',
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
            body: LigaDesligaM3(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifica presença de placas e badges
      expect(find.text('FONTE 9V'), findsOneWidget);
      expect(find.text('CHAVE 1'), findsNWidgets(2)); // Na lousa e no console
      expect(find.text('CHAVE 2'), findsNWidgets(2)); // Na lousa e no console
      expect(find.text('LUMINÁRIA A'), findsOneWidget);
      expect(find.text('LUMINÁRIA B'), findsOneWidget);

      // Console de etiquetagem com opções táteis
      expect(find.text('Luminária A'), findsNWidgets(2)); // 1 para cada chave
      expect(find.text('Luminária B'), findsNWidgets(2)); // 1 para cada chave

      // Botão flutuante de Dica do Prof. Volts
      expect(find.byTooltip('Dica do Professor Volts'), findsOneWidget);

      // Card de Stepper do Progresso da Investigação
      expect(find.text('Progresso da investigação'), findsOneWidget);
      expect(find.text('Teste a chave 1'), findsOneWidget);
      expect(find.text('Observe a luminária'), findsOneWidget);
      expect(find.text('Teste a chave 2'), findsOneWidget);
      expect(find.text('Registre as associações'), findsOneWidget);

      expect(completed, isFalse);
    });

    testWidgets('Exige testar ambas as chaves antes de validar', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Clica em Energizar e Validar sem testar
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      expect(energizeBtn, findsOneWidget);
      await tester.tap(energizeBtn);
      await tester.pump();

      // Mensagem de rigor científico
      expect(
        find.textContaining('Para uma investigação científica justa, teste ambas as chaves'),
        findsOneWidget,
      );
    });

    testWidgets('Exige atribuir etiquetas após testar chaves', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Alterna Chave 1 e Chave 2 (via botão de alternar do console)
      final alternarBtns = find.text('DESLIGADA');
      expect(alternarBtns, findsNWidgets(2));
      await tester.tap(alternarBtns.first);
      await tester.pump();
      await tester.tap(alternarBtns.last);
      await tester.pump();

      // Clica em Energizar e Validar sem atribuir etiquetas
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      await tester.tap(energizeBtn);
      await tester.pump();

      expect(
        find.textContaining('Por favor, atribua a etiqueta para ambas as chaves'),
        findsOneWidget,
      );
    });

    testWidgets('Valida fluxo completo com sucesso e feedback da Profª Volts',
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
            body: LigaDesligaM3(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // 1. Testa Chave 1
      final alternarBtns = find.text('DESLIGADA');
      await tester.tap(alternarBtns.first);
      await tester.pump();

      // 2. Testa Chave 2
      await tester.tap(alternarBtns.last);
      await tester.pump();

      // 3. Atribui etiquetas: Chave 1 -> Luminária A, Chave 2 -> Luminária B
      final lumABtns = find.text('Luminária A');
      await tester.tap(lumABtns.first); // Chave 1
      await tester.pump();

      final lumBBtns = find.text('Luminária B');
      await tester.tap(lumBBtns.last); // Chave 2
      await tester.pump();

      // 4. Energiza e Valida
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      await tester.tap(energizeBtn);
      await tester.pump();

      // Verifica diálogo da Profª Volts
      expect(find.textContaining('Muito bem! Você testou cada controle individualmente'), findsOneWidget);

      // Clica em Continuar no diálogo
      final continuarBtn = find.text('CONTINUAR');
      expect(continuarBtn, findsOneWidget);
      await tester.tap(continuarBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(completed, isTrue);
    });

    testWidgets('Alterna entre modo Físico e Esquemático', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LigaDesligaM3(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Alterna para Esquemático
      final esqBtn = find.text('Esquemático');
      expect(esqBtn, findsOneWidget);
      await tester.tap(esqBtn);
      await tester.pump();

      // Verifica presença dos rótulos esquemáticos
      expect(find.text('FONTE 9V'), findsOneWidget);
      expect(find.text('CHAVE 1'), findsWidgets);
      expect(find.text('LUMINÁRIA A'), findsWidgets);

      // Alterna de volta para Físico 3D
      final fisBtn = find.text('Físico 3D');
      expect(fisBtn, findsOneWidget);
      await tester.tap(fisBtn);
      await tester.pump();
    });
  });
}
