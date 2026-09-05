import 'package:flutter/foundation.dart';

/// Modelo genérico de estado de progressão de missões para estandes do EletroLab.
@immutable
class StandFlowState {
  final int currentMissionNumber;
  final Set<int> completedMissionNumbers;
  final int totalMissions;
  final int snapshotVersion;

  const StandFlowState({
    this.currentMissionNumber = 1,
    this.completedMissionNumbers = const {},
    this.totalMissions = 5,
    this.snapshotVersion = 1,
  });

  /// Estado inicial seguro (Missão 1 ativa e nenhuma concluída).
  factory StandFlowState.initial({int totalMissions = 5}) => StandFlowState(
        currentMissionNumber: 1,
        completedMissionNumbers: const {},
        totalMissions: totalMissions,
      );

  bool get isStandCompleted => completedMissionNumbers.length >= totalMissions;

  Set<int> get unlockedMissionNumbers =>
      List.generate(totalMissions, (i) => i + 1)
          .where((number) => isUnlocked(number))
          .toSet();

  bool isUnlocked(int missionNumber) {
    if (missionNumber < 1 || missionNumber > totalMissions) return false;
    if (missionNumber == 1) return true;
    return completedMissionNumbers.contains(missionNumber - 1);
  }

  StandFlowState advanceTo(int missionNumber) {
    final target = missionNumber.clamp(1, totalMissions);
    if (!isUnlocked(target)) {
      return this;
    }
    return copyWith(currentMissionNumber: target);
  }

  StandFlowState markCompleted(int missionNumber) {
    final newCompleted = {...completedMissionNumbers, missionNumber};
    var nextMission = currentMissionNumber;
    if (missionNumber == currentMissionNumber && missionNumber < totalMissions) {
      nextMission = missionNumber + 1;
    }
    return copyWith(
      completedMissionNumbers: newCompleted,
      currentMissionNumber: nextMission,
    );
  }

  StandFlowState copyWith({
    int? currentMissionNumber,
    Set<int>? completedMissionNumbers,
    int? totalMissions,
    int? snapshotVersion,
  }) {
    return StandFlowState(
      currentMissionNumber: currentMissionNumber ?? this.currentMissionNumber,
      completedMissionNumbers:
          completedMissionNumbers ?? this.completedMissionNumbers,
      totalMissions: totalMissions ?? this.totalMissions,
      snapshotVersion: snapshotVersion ?? this.snapshotVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentMissionNumber': currentMissionNumber,
        'completedMissionNumbers': completedMissionNumbers.toList(),
        'totalMissions': totalMissions,
        'snapshotVersion': snapshotVersion,
      };

  factory StandFlowState.fromJson(Map<String, dynamic> json) {
    return StandFlowState(
      currentMissionNumber: (json['currentMissionNumber'] as num?)?.toInt() ?? 1,
      completedMissionNumbers:
          ((json['completedMissionNumbers'] as List<dynamic>?) ?? [])
              .map((e) => (e as num).toInt())
              .toSet(),
      totalMissions: (json['totalMissions'] as num?)?.toInt() ?? 5,
      snapshotVersion: (json['snapshotVersion'] as num?)?.toInt() ?? 1,
    );
  }
}
