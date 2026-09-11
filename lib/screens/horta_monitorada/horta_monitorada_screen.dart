import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/progress_controller.dart';
import '../../widgets/glass_container.dart';
import '../common_stand/stand_flow_header.dart';
import '../common_stand/stand_flow_state.dart';
import 'missions/horta_monitorada_m1.dart';
import 'missions/horta_monitorada_m2.dart';
import 'missions/horta_monitorada_m3.dart';
import 'missions/horta_monitorada_m4.dart';
import 'missions/horta_monitorada_m5.dart';

/// Coordenador do fluxo de missões do Estande 09 — Horta Monitorada (Equipe Bio-Tech).
class HortaMonitoradaScreen extends ConsumerStatefulWidget {
  const HortaMonitoradaScreen({super.key});

  @override
  ConsumerState<HortaMonitoradaScreen> createState() =>
      _HortaMonitoradaScreenState();
}

class _HortaMonitoradaScreenState extends ConsumerState<HortaMonitoradaScreen> {
  StandFlowState _flowState = StandFlowState.initial(totalMissions: 5);

  void _onMissionCompleted(int missionNumber) {
    final nextState = _flowState.markCompleted(missionNumber);
    setState(() {
      _flowState = nextState;
    });

    if (missionNumber == 5) {
      ref
          .read(progressControllerProvider.notifier)
          .markAsCompleted('estande9', stars: 3);
      ref
          .read(progressControllerProvider.notifier)
          .markAsCompleted('horta_monitorada', stars: 3);
      _showCompletionDialog();
    }
  }

  void _navigateToMission(int missionNumber) {
    if (_flowState.isUnlocked(missionNumber)) {
      setState(() {
        _flowState = _flowState.advanceTo(missionNumber);
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassContainer(
            borderRadius: 24,
            accentColor: const Color(0xFF16A34A),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.eco_rounded,
                  color: Color(0xFF16A34A),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'ESTANDE 09 CONCLUÍDO!',
                  style: TextStyle(
                    fontFamily: GoogleFonts.rajdhani().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Parabéns! A Equipe Bio-Tech dominou a automação agrícola: divisor de tensão com potenciômetro, sensoriamento com LDR, acionamento de LED Grow Light e reserva com capacitor!',
                  style: TextStyle(
                    fontFamily: GoogleFonts.outfit().fontFamily,
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => StandNavigator.navigateBackToFairMap(context),
                  icon: const Icon(Icons.map_rounded),
                  label: Text(
                    'RETORNAR AO MAPA',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          StandNavigator.navigateBackToFairMap(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/floor.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                StandFlowHeader(
                  standName: 'HORTA MONITORADA',
                  standNumber: 9,
                  currentMissionNumber: _flowState.currentMissionNumber,
                  completedMissionNumbers: _flowState.completedMissionNumbers,
                  unlockedMissionNumbers: _flowState.unlockedMissionNumbers,
                  totalMissions: 5,
                  onSelectMission: _navigateToMission,
                  onBack: () => StandNavigator.navigateBackToFairMap(context),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildCurrentMissionWidget(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentMissionWidget() {
    return switch (_flowState.currentMissionNumber) {
      1 => HortaMonitoradaM1(
          key: const ValueKey(1),
          onMissionComplete: () => _onMissionCompleted(1),
        ),
      2 => HortaMonitoradaM2(
          key: const ValueKey(2),
          onMissionComplete: () => _onMissionCompleted(2),
        ),
      3 => HortaMonitoradaM3(
          key: const ValueKey(3),
          onMissionComplete: () => _onMissionCompleted(3),
        ),
      4 => HortaMonitoradaM4(
          key: const ValueKey(4),
          onMissionComplete: () => _onMissionCompleted(4),
        ),
      5 => HortaMonitoradaM5(
          key: const ValueKey(5),
          onMissionComplete: () => _onMissionCompleted(5),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
