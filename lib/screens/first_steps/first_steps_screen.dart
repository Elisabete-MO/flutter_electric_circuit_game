import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ui_scale.dart';
import '../../widgets/tech_grid_background.dart';
import '../common_stand/stand_flow_header.dart';
import 'modules/first_steps_anatomy_tab.dart';
import 'modules/first_steps_quiz_tab.dart';
import 'modules/first_steps_showcase_tab.dart';

/// Estande 01 — Primeiros Passos (Equipe Tutorial).
///
/// Apresentação visual, interativa e pedagógica dos componentes básicos da eletricidade,
/// símbolos esquemáticos, anatomia dos terminais e desafio de fixação do Prof. Volts.
class FirstStepsScreen extends StatefulWidget {
  final VoidCallback? onPhaseComplete;

  const FirstStepsScreen({
    super.key,
    this.onPhaseComplete,
  });

  @override
  State<FirstStepsScreen> createState() => _FirstStepsScreenState();
}

class _FirstStepsScreenState extends State<FirstStepsScreen> {
  int _currentModuleNumber = 1;
  final Set<int> _completedModuleNumbers = {};
  final Set<int> _unlockedModuleNumbers = {1};

  void _onModuleComplete(int moduleNumber) {
    setState(() {
      _completedModuleNumbers.add(moduleNumber);
      if (moduleNumber < 3) {
        _unlockedModuleNumbers.add(moduleNumber + 1);
        _currentModuleNumber = moduleNumber + 1;
      } else {
        widget.onPhaseComplete?.call();
      }
    });
  }

  void _showHelpDialog() {
    final scale = context.uiScale;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded,
                color: Color(0xFF10B981), size: 28),
            const SizedBox(width: 10),
            Text(
              'Guia do Estande 01',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: scale.font(20, min: 16, max: 24),
              ),
            ),
          ],
        ),
        content: Text(
          'Bem-vindo ao Estande 01 — Primeiros Passos!\n\n'
          '1. Módulo 1: Conheça os 8 componentes essenciais e alterne entre o modo Físico e Esquemático.\n'
          '2. Módulo 2: Entenda a anatomia dos terminais, polaridade (+ / -) e nós elétricos.\n'
          '3. Módulo 3: Teste seus conhecimentos no desafio de perguntas do Prof. Volts.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: scale.font(14, min: 12, max: 18),
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ENTENDI',
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        backgroundColor: const Color(0xFF0B1120),
        body: TechGridBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Cabeçalho Padronizado do Estande
                StandFlowHeader(
                  standName: 'Primeiros Passos',
                  standNumber: 1,
                  totalMissions: 3,
                  currentMissionNumber: _currentModuleNumber,
                  completedMissionNumbers: _completedModuleNumbers,
                  unlockedMissionNumbers: _unlockedModuleNumbers,
                  onSelectMission: (missionNum) =>
                      setState(() => _currentModuleNumber = missionNum),
                  onHelpTap: _showHelpDialog,
                  onBack: () => StandNavigator.navigateBackToFairMap(context),
                ),
                // Conteúdo do Módulo Ativo
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentModule(),
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

  Widget _buildCurrentModule() {
    switch (_currentModuleNumber) {
      case 1:
        return FirstStepsShowcaseTab(
          key: const ValueKey('module_1_showcase'),
          onModuleComplete: () => _onModuleComplete(1),
        );
      case 2:
        return FirstStepsAnatomyTab(
          key: const ValueKey('module_2_anatomy'),
          onModuleComplete: () => _onModuleComplete(2),
        );
      case 3:
        return FirstStepsQuizTab(
          key: const ValueKey('module_3_quiz'),
          onModuleComplete: () => _onModuleComplete(3),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
