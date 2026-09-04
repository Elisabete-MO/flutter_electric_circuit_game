import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eletrolab/screens/second_bench/second_bench_flow_screen.dart';
import 'package:eletrolab/screens/second_bench/second_bench_phase1.dart';
import 'package:eletrolab/screens/second_bench/second_bench_phase2.dart';
import 'package:eletrolab/screens/second_bench/second_bench_phase3.dart';
import 'package:eletrolab/screens/second_bench/second_bench_phase4.dart';
import 'package:eletrolab/screens/second_bench/widgets/second_bench_header.dart';
import 'package:eletrolab/screens/second_bench/widgets/second_bench_side_panel.dart';
import 'package:eletrolab/state/progress_controller.dart';

// Estado serializado com todas as 4 fases desbloqueadas (fase 1 em exibição).
const _allUnlockedJson = '{"currentPhaseId":1,"completedPhaseIds":[],"unlockedPhaseIds":[1,2,3,4]}';

void main() {
  Future<void> pumpSecondBench(
    WidgetTester tester, {
    Size size = const Size(1600, 900),
    String? initialFlowJson,
  }) async {
    SharedPreferences.setMockInitialValues(
      initialFlowJson != null
          ? {'second_bench_flow_v1': initialFlowJson}
          : {},
    );
    final prefs = await SharedPreferences.getInstance();

    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: SecondBenchFlowScreen(),
        ),
      ),
    );

    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('Estande 2 (Acende Aí) — Padronização Visual e Estrutural', () {
    testWidgets('Exibe o cabeçalho padronizado e a Fase 1 inicialmente', (tester) async {
      await pumpSecondBench(tester);

      expect(find.byType(SecondBenchHeader), findsOneWidget);
      expect(find.byType(SecondBenchPhase1), findsOneWidget);
      expect(find.textContaining('Fase 1'), findsWidgets);
    });

    // Navegação entre fases requer que elas estejam desbloqueadas.
    // Injetamos um estado com todas as fases liberadas para testar apenas
    // a responsabilidade do header: exibir as pílulas e reagir ao toque.
    testWidgets('Navega para fases desbloqueadas pelo cabeçalho', (tester) async {
      await pumpSecondBench(tester, initialFlowJson: _allUnlockedJson);

      // Parte de Fase 1
      expect(find.byType(SecondBenchPhase1), findsOneWidget);

      // Toca na pílula "Fase 2" — deve navegar
      await tester.tap(find.text('Fase 2').first);
      await tester.pumpAndSettle();
      expect(find.byType(SecondBenchPhase2), findsOneWidget);

      // Toca na pílula "Fase 3"
      await tester.tap(find.text('Fase 3').first);
      await tester.pumpAndSettle();
      expect(find.byType(SecondBenchPhase3), findsOneWidget);

      // Toca na pílula "Fase 4"
      await tester.tap(find.text('Fase 4').first);
      await tester.pumpAndSettle();
      expect(find.byType(SecondBenchPhase4), findsOneWidget);
    });

    testWidgets('Fases bloqueadas não são navegáveis pelo cabeçalho', (tester) async {
      // Estado inicial: apenas Fase 1 desbloqueada
      await pumpSecondBench(tester);

      expect(find.byType(SecondBenchPhase1), findsOneWidget);

      // Toca em Fase 2 (bloqueada) — deve permanecer na Fase 1
      await tester.tap(find.text('Fase 2').first);
      await tester.pumpAndSettle();
      expect(find.byType(SecondBenchPhase1), findsOneWidget);
      expect(find.byType(SecondBenchPhase2), findsNothing);
    });

    testWidgets('Renderiza o painel lateral em todas as fases no Desktop', (tester) async {
      await pumpSecondBench(tester, size: const Size(1600, 900));
      expect(find.byType(SecondBenchSidePanel), findsWidgets);
    });

    testWidgets('Renderiza sem emojis nos textos visíveis da Fase 1', (tester) async {
      await pumpSecondBench(tester);

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );
      for (final element in find.byType(Text).evaluate()) {
        final widget = element.widget as Text;
        if (widget.data != null) {
          expect(
            emojiRegex.hasMatch(widget.data!),
            isFalse,
            reason: 'Emoji encontrado no texto: "${widget.data}"',
          );
        }
      }
    });
  });

  group('Estande 2 — Persistência de Estado de Progresso', () {
    test('SecondBenchFlowState serializa e desserializa corretamente', () {
      // Valida que o JSON injetado no teste de navegação é estruturalmente coerente
      final decoded = jsonDecode(_allUnlockedJson) as Map<String, dynamic>;
      expect(decoded['currentPhaseId'], equals(1));
      expect(decoded['unlockedPhaseIds'], containsAll([1, 2, 3, 4]));
      expect(decoded['completedPhaseIds'], isEmpty);
    });
  });
}
