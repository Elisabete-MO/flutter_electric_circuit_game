import 'package:flutter_test/flutter_test.dart';
import 'package:eletrolab/models/first_bench_flow.dart';

void main() {
  group('FirstBenchFlowState Tests', () {
    test('Estado inicial padrão deve ter Fase 1 ativa e nenhuma concluída', () {
      final state = FirstBenchFlowState.safe();
      expect(state.currentPhaseId, equals(1));
      expect(state.completedPhaseIds, isEmpty);
      expect(state.firstBenchCompleted, isFalse);
      expect(state.maquetteLit, isFalse);
      expect(state.isUnlocked(1), isTrue);
      expect(state.isUnlocked(2), isFalse);
    });

    test('Progressão sequencial desbloqueia fases corretamente', () {
      var state = FirstBenchFlowState.safe();
      
      // Tentar ir para Fase 2 sem concluir Fase 1 não deve mudar o estado
      state = state.advanceTo(2);
      expect(state.currentPhaseId, equals(1));

      // Marcar Fase 1 como concluída
      state = state.markCompleted(1);
      expect(state.completedPhaseIds.contains(1), isTrue);
      expect(state.currentPhaseId, equals(2));
      expect(state.isUnlocked(2), isTrue);
      expect(state.isUnlocked(3), isFalse);

      // Concluir Fase 2
      state = state.markCompleted(2);
      expect(state.currentPhaseId, equals(3));

      // Concluir Fase 3
      state = state.markCompleted(3);
      expect(state.currentPhaseId, equals(4));

      // Concluir Fase 4 (Maquete acende)
      state = state.markCompleted(4);
      expect(state.firstBenchCompleted, isTrue);
      expect(state.maquetteLit, isTrue);
    });

    test('Fases concluídas podem ser repetidas sem apagar progresso', () {
      var state = const FirstBenchFlowState(
        currentPhaseId: 4,
        completedPhaseIds: {1, 2, 3},
      );

      // Repetir Fase 1
      state = state.advanceTo(1);
      expect(state.currentPhaseId, equals(1));
      expect(state.completedPhaseIds, equals({1, 2, 3}));
    });

    test('Serialização e desserialização via JSON', () {
      const state = FirstBenchFlowState(
        currentPhaseId: 3,
        completedPhaseIds: {1, 2},
        snapshotVersion: 1,
      );

      final json = state.toJson();
      final restored = FirstBenchFlowState.fromJson(json);

      expect(restored, equals(state));
    });

    test('JSON corrompido ou nulo retorna estado inicial seguro', () {
      expect(FirstBenchFlowState.fromJson(null), equals(FirstBenchFlowState.safe()));
      expect(FirstBenchFlowState.fromJson({'invalid': true}), equals(FirstBenchFlowState.safe()));
      expect(FirstBenchFlowState.fromJson({'currentPhaseId': 'invalido'}), equals(FirstBenchFlowState.safe()));
    });
  });
}
