import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m1.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m2.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m3.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m4.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m5.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Estande 04 — Ruas da Maquete (Iluminação Pública) Tests', () {
    testWidgets('M1 renderiza o Primeiro Poste da Alameda e Bateria 4.5V', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Poste 1 (Alameda)'), findsOneWidget);
      expect(find.textContaining('Bateria 4.5V'), findsWidgets);
      expect(find.textContaining('TENSÃO:'), findsOneWidget);
    });

    testWidgets('M1 permite desrosquear e rosquear a lâmpada do poste', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('(Rosqueada)'), findsOneWidget);

      final lampFinder = find.textContaining('Poste 1 (Alameda)');
      await tester.tap(lampFinder);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('(Desrosqueada)'), findsOneWidget);

      await tester.tap(lampFinder);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('(Rosqueada)'), findsOneWidget);
    });

    testWidgets('M2 exibe ligação em série, mini-voltímetro de 2.25V e zero questionário', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM2(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      // Deve ter o voltímetro digital exibindo 2.25 V
      expect(find.textContaining('VOLTÍMETRO:'), findsOneWidget);
      expect(find.textContaining('2.25 V'), findsOneWidget);

      // Não deve ter mais o formulário de perguntas teóricas
      expect(find.textContaining('Pergunta de Investigação Física:'), findsNothing);

      // Botão de alternar ponta de prova do voltímetro
      final switchBtn = find.textContaining('Medir Outro');
      expect(switchBtn, findsOneWidget);

      await tester.tap(switchBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Poste 2 (Avenida)'), findsWidgets);
    });

    testWidgets('M2 permite desrosquear poste 1 para comprovar o apagão cascata em série', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM2(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      final lamp1Finder = find.text('Poste 1 (Alameda)');
      expect(lamp1Finder, findsWidgets);

      await tester.tap(lamp1Finder.first);
      await tester.pump(const Duration(milliseconds: 200));

      // Com o poste 1 desrosqueado, o voltímetro mede 0.00 V (circuito aberto)
      expect(find.textContaining('0.00 V'), findsOneWidget);
      expect(find.textContaining('(Desrosqueada)'), findsOneWidget);
    });

    testWidgets('M3 renderiza Poste Alameda, Casa Residencial e Nó de Kirchhoff', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM3(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Poste Alameda (Ramal 1)'), findsOneWidget);
      expect(find.textContaining('Casa Residencial (Ramal 2)'), findsOneWidget);
      expect(find.textContaining('Nó de Kirchhoff (+)'), findsOneWidget);
      expect(find.textContaining('Barramento de Retorno (-)'), findsOneWidget);

      // Tocar no nó para plugar
      final nodeFinder = find.textContaining('Nó de Kirchhoff (+)');
      await tester.tap(nodeFinder);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('(Conectado)'), findsOneWidget);
    });

    testWidgets('M4 renderiza 4 ramos em paralelo e soma de correntes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Poste Alameda'), findsOneWidget);
      expect(find.textContaining('Casa 1'), findsOneWidget);
      expect(find.textContaining('Casa 2'), findsOneWidget);
      expect(find.textContaining('Poste Avenida'), findsOneWidget);
      expect(find.text('Barramento Paralelo'), findsOneWidget);

      // Conectar barramento paralelo
      final busFinder = find.text('Barramento Paralelo');
      await tester.tap(busFinder);
      await tester.pump(const Duration(milliseconds: 200));

      // 4 ramos ativos somam 360mA
      expect(find.text('360mA'), findsOneWidget);
    });

    testWidgets('M5 permite simular manutenção na Casa 01 sem apagar vizinhos', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      await tester.pumpWidget(buildTestable(RuasMaqueteM5(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Casa 01 (Alvo)'), findsOneWidget);
      expect(find.textContaining('Casa 02 (Vizinha)'), findsOneWidget);

      // Tocar na Casa 01 para abrir o disjuntor de manutenção
      final house1Finder = find.textContaining('Casa 01 (Alvo)');
      await tester.tap(house1Finder);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('(Desligada)'), findsOneWidget);
      // Os outros 3 ramos continuam ativos (3 * 90 = 270mA)
      expect(find.textContaining('270mA'), findsOneWidget);

      // Testar botão de validação
      final energizeBtn = find.text('ENERGIZAR E VALIDAR BANCADA');
      expect(energizeBtn, findsOneWidget);
      await tester.tap(energizeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Inspeção do Bairro Aprovada!'), findsOneWidget);
    });

    testWidgets('Todas as 5 missões renderizam em tela compacta (1024x600) sem overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 600));

      await tester.pumpWidget(buildTestable(RuasMaqueteM1(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestable(RuasMaqueteM2(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestable(RuasMaqueteM3(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(buildTestable(RuasMaqueteM5(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
    });
  });
}
