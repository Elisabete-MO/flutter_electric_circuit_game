import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eletrolab/screens/ruas_maquete/missions/ruas_maquete_m4.dart';
import 'package:eletrolab/screens/ruas_maquete/ruas_maquete_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestable(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('Estande 04 — Missão 4 Responsividade e Preservação', () {
    final resolutions = <String, Size>{
      '1920x1080 Desktop FHD': const Size(1920, 1080),
      '1366x768 Desktop HD': const Size(1366, 768),
      '1024x768 Tablet 4:3': const Size(1024, 768),
      '956x440 Mobile Landscape Wide': const Size(956, 440),
      '844x390 Mobile Landscape iPhone': const Size(844, 390),
      '740x360 Mobile Landscape Compact': const Size(740, 360),
      '390x844 Mobile Portrait iPhone': const Size(390, 844),
      '360x740 Mobile Portrait Android': const Size(360, 740),
    };

    for (final entry in resolutions.entries) {
      testWidgets('M4 renderiza em ${entry.key} sem overflow', (tester) async {
        await tester.binding.setSurfaceSize(entry.value);
        await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {})));
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Poste Alameda'), findsOneWidget);
        expect(find.textContaining('Casa 1'), findsOneWidget);
        expect(find.textContaining('Casa 2'), findsOneWidget);
        expect(find.textContaining('Poste Avenida'), findsOneWidget);
        expect(find.text('Barramento Paralelo'), findsWidgets);
      });
    }

    testWidgets('M4 fluxo completo com simulação e preservação de estado', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 768));
      bool completed = false;

      await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {
        completed = true;
      })));
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Estado inicial
      expect(find.text('0mA'), findsOneWidget);

      // 2. Conectar barramento
      final busFinder = find.text('Barramento Paralelo').first;
      await tester.tap(busFinder);
      await tester.pump(const Duration(milliseconds: 100));

      // 4 ramos ativos = 360mA
      expect(find.text('360mA'), findsOneWidget);

      // 3. Desligar Casa 1
      final house1Finder = find.textContaining('Casa 1');
      await tester.tap(house1Finder.first);
      await tester.pump(const Duration(milliseconds: 100));

      // 3 ramos ativos = 270mA
      expect(find.text('270mA'), findsOneWidget);

      // 4. Religando Casa 1
      await tester.tap(house1Finder.first);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('360mA'), findsOneWidget);

      // 5. Validar missão
      final validateBtn = find.text('Energizar e validar');
      expect(validateBtn, findsOneWidget);
      await tester.tap(validateBtn);
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('concluída com êxito'), findsOneWidget);

      // Confirmar no diálogo
      final confirmBtn = find.text('Continuar');
      if (confirmBtn.evaluate().isNotEmpty) {
        await tester.tap(confirmBtn);
        await tester.pump(const Duration(milliseconds: 100));
        expect(completed, isTrue);
      }
    });

    testWidgets('M4 drawer em modo paisagem compacto (956x440) abre e fecha sem perder estado', (tester) async {
      await tester.binding.setSurfaceSize(const Size(956, 440));
      await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 100));

      // Conectar barramento antes de abrir drawer
      final busFinder = find.text('Barramento Paralelo').first;
      await tester.tap(busFinder);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('360mA'), findsOneWidget);

      // Botão Instruções
      final instrBtn = find.text('Instruções');
      expect(instrBtn, findsOneWidget);
      await tester.tap(instrBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Drawer aberto: objetivo visível
      expect(find.textContaining('Etapas de Eletrificação'), findsOneWidget);

      // Fechar drawer
      final closeBtn = find.byTooltip('Fechar instruções');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pump(const Duration(milliseconds: 100));

      // Estado do circuito continua 100% preservado
      expect(find.text('360mA'), findsOneWidget);
    });

    testWidgets('M4 não contém emojis em textos ou botões', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1366, 768));
      await tester.pumpWidget(buildTestable(RuasMaqueteM4(onMissionComplete: () {})));
      await tester.pump(const Duration(milliseconds: 100));

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );

      for (final tw in textWidgets) {
        final text = tw.data ?? tw.textSpan?.toPlainText() ?? '';
        expect(
          emojiRegex.hasMatch(text),
          isFalse,
          reason: 'Encontrado emoji no texto: "$text"',
        );
      }
    });

    testWidgets('RuasMaqueteScreen navegação compacta e header responsivo', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(buildTestable(const RuasMaqueteScreen()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
      // Controle unificado "Estande 04"
      expect(find.text('Estande 04'), findsOneWidget);
      // Seletor compacto de missão
      expect(find.textContaining('‹ Missão 1 de 5 ›'), findsOneWidget);
    });
  });
}
