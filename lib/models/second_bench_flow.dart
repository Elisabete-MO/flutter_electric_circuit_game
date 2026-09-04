import 'package:flutter/foundation.dart';

/// Modelo de estado do fluxo do Segundo Estande (4 Fases).
///
/// Mantém as invariantes do fluxo pedagógico:
/// - Fases válidas de 1 a 4.
/// - Progressão desbloqueada sequencialmente.
/// - Suporte a snapshot versionado e desserialização segura.
@immutable
class SecondBenchFlowState {
  static const String storageKey = 'second_bench_flow_v1';
  static const int currentVersion = 1;

  final int currentPhaseId;
  final Set<int> completedPhaseIds;
  final int snapshotVersion;

  const SecondBenchFlowState({
    this.currentPhaseId = 1,
    this.completedPhaseIds = const {},
    this.snapshotVersion = currentVersion,
  });

  /// Estado inicial padrão (Fases 1, 2 e 3 concluídas, Fase 4 ativa e desbloqueada).
  factory SecondBenchFlowState.safe() => const SecondBenchFlowState(
        currentPhaseId: 4,
        completedPhaseIds: {1, 2, 3},
      );

  /// Indica se o segundo estande foi concluído por completo (Fase 4 concluída).
  bool get secondBenchCompleted => completedPhaseIds.contains(4);

  /// Indica se a maquete está iluminada (derivado de `secondBenchCompleted`).
  bool get maquetteLit => secondBenchCompleted;

  /// Verifica se uma fase específica está desbloqueada.
  /// A Fase N exige que a Fase N-1 esteja concluída.
  bool isUnlocked(int phaseId) {
    if (phaseId < 1 || phaseId > 4) return false;
    if (phaseId == 1) return true;
    return completedPhaseIds.contains(phaseId - 1);
  }

  /// Avança ou navega para uma fase específica se ela estiver desbloqueada.
  SecondBenchFlowState advanceTo(int phaseId) {
    final target = phaseId.clamp(1, 4);
    if (!isUnlocked(target)) {
      return this;
    }
    return copyWith(currentPhaseId: target);
  }

  /// Marca uma fase como concluída.
  /// Se a fase concluída for a fase atual e houver uma próxima fase (1..3),
  /// o fluxo avança `currentPhaseId` automaticamente para a próxima fase.
  SecondBenchFlowState markCompleted(int phaseId) {
    final validPhase = phaseId.clamp(1, 4);
    if (!isUnlocked(validPhase)) {
      return this;
    }
    final newCompleted = {...completedPhaseIds, validPhase};
    int nextPhase = currentPhaseId;
    if (validPhase == currentPhaseId && validPhase < 4) {
      nextPhase = validPhase + 1;
    }
    return copyWith(
      completedPhaseIds: newCompleted,
      currentPhaseId: nextPhase,
    );
  }

  /// Reseta o progresso mantendo o estado inicial seguro.
  SecondBenchFlowState reset() {
    return const SecondBenchFlowState();
  }

  SecondBenchFlowState copyWith({
    int? currentPhaseId,
    Set<int>? completedPhaseIds,
    int? snapshotVersion,
  }) {
    return SecondBenchFlowState(
      currentPhaseId: (currentPhaseId ?? this.currentPhaseId).clamp(1, 4),
      completedPhaseIds: completedPhaseIds ?? this.completedPhaseIds,
      snapshotVersion: snapshotVersion ?? this.snapshotVersion,
    );
  }

  /// Converte o estado para JSON serializável.
  Map<String, dynamic> toJson() {
    return {
      'currentPhaseId': currentPhaseId,
      'completedPhaseIds': completedPhaseIds.toList()..sort(),
      'snapshotVersion': snapshotVersion,
    };
  }

  /// Desserializa o JSON com recuperação segura em caso de erros ou dados corrompidos.
  factory SecondBenchFlowState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SecondBenchFlowState.safe();
    try {
      final version = (json['snapshotVersion'] as num?)?.toInt() ?? currentVersion;
      final rawPhaseId = (json['currentPhaseId'] as num?)?.toInt() ?? 1;
      final currentPhaseId = rawPhaseId.clamp(1, 4);

      final rawCompleted = json['completedPhaseIds'];
      final Set<int> completedPhaseIds = {};
      if (rawCompleted is List) {
        for (final item in rawCompleted) {
          if (item is num) {
            final phase = item.toInt();
            if (phase >= 1 && phase <= 4) {
              completedPhaseIds.add(phase);
            }
          }
        }
      }

      return SecondBenchFlowState(
        currentPhaseId: currentPhaseId,
        completedPhaseIds: completedPhaseIds,
        snapshotVersion: version,
      );
    } catch (_) {
      return SecondBenchFlowState.safe();
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecondBenchFlowState &&
        other.currentPhaseId == currentPhaseId &&
        other.snapshotVersion == snapshotVersion &&
        _setEquals(other.completedPhaseIds, completedPhaseIds);
  }

  @override
  int get hashCode => Object.hash(
        currentPhaseId,
        snapshotVersion,
        Object.hashAll(completedPhaseIds.toList()..sort()),
      );

  static bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    return a.containsAll(b);
  }
}
