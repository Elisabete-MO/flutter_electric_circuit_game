import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/liga_desliga/missions/liga_desliga_m4.dart';

void main() {
  group('LigaDesligaM4 (Chave no lugar errado) Widget Tests', () {
    testWidgets(
        'Renderiza estado inicial com desvio em paralelo e slot alvo em série',
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
            body: LigaDesligaM4(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Verifica presença de componentes e placas
      expect(find.text('FONTE 4.5V'), findsOneWidget);
      expect(find.text('LÂMPADA'), findsOneWidget);
      expect(find.text('DESVIO EM PARALELO'), findsOneWidget);
      expect(find.text('PONTO DE CORTE EM SÉRIE'), findsOneWidget);
      expect(find.text('COLOCAR EM SÉRIE'), findsOneWidget);

      // Roteiro de investigação (WorkbenchInvestigationStepperCard)
      expect(find.text('Roteiro de investigação'), findsOneWidget);
      expect(find.text('Notar que chave aberta não apaga a luz'), findsOneWidget);
      expect(find.text('Reposicionar chave para o ramo em série'), findsOneWidget);
      expect(find.text('Testar controle da lâmpada (ligar e desligar)'), findsOneWidget);

      expect(completed, isFalse);
    });

    testWidgets(
        'No desvio inútil, a lâmpada ignora a chave aberta e continua acesa',
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
            body: LigaDesligaM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      // Lâmpada deve estar iluminada mesmo com chave aberta
      expect(find.text('ILUMINADA'), findsOneWidget);
      expect(find.text('IGNORA A CHAVE!'), findsOneWidget);
    });

    testWidgets(
        'Validação é bloqueada enquanto a chave estiver no desvio',
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
            body: LigaDesligaM4(
              onMissionComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      expect(energizeBtn, findsOneWidget);
      await tester.tap(energizeBtn);
      await tester.pump();

      expect(
        find.textContaining('A chave ainda está no desvio inútil em paralelo'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Mover para série habilita o controle real da lâmpada e valida com sucesso',
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
            body: LigaDesligaM4(
              onMissionComplete: () => completed = true,
            ),
          ),
        ),
      );
      await tester.pump();

      // Clica no botão para colocar em série
      final moveBtn = find.text('COLOCAR EM SÉRIE');
      expect(moveBtn, findsOneWidget);
      await tester.tap(moveBtn);
      await tester.pump();

      // Agora a chave está em série (estava aberta inicialmente)
      expect(find.text('CHAVE EM SÉRIE (CORRETO)'), findsOneWidget);
      expect(find.text('DESVIO DESATIVADO'), findsOneWidget);
      // Como estava aberta, agora a lâmpada APAGOU de verdade!
      expect(find.text('APAGADA'), findsOneWidget);

      // Alterna a chave para fechar e acender a lâmpada
      final toggleBtn = find.text('INTERRUPTOR');
      expect(toggleBtn, findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pump();

      // Lâmpada acende sob comando!
      expect(find.text('ILUMINADA'), findsOneWidget);

      // Clica em Energizar e Validar
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      await tester.tap(energizeBtn);
      await tester.pump();

      // Verifica diálogo da Profª Volts
      expect(find.textContaining('Excelente correção!'), findsOneWidget);

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
            body: LigaDesligaM4(
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

      expect(find.text('FONTE 4.5V'), findsOneWidget);
      expect(find.text('LÂMPADA'), findsOneWidget);
      expect(find.text('DESVIO INÚTIL'), findsOneWidget);

      // Alterna de volta para Físico 3D
      final fisBtn = find.text('Físico 3D');
      expect(fisBtn, findsOneWidget);
      await tester.tap(fisBtn);
      await tester.pump();
    });
  });
}
