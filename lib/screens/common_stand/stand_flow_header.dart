import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/eletrolab_header_brand.dart';
import 'stand_flow_tokens.dart';

/// Cabeçalho padronizado e responsivo para fluxos de missões nos estandes.
class StandFlowHeader extends StatelessWidget {
  final String standName;
  final int standNumber;
  final int currentMissionNumber;
  final Set<int> completedMissionNumbers;
  final Set<int> unlockedMissionNumbers;
  final int totalMissions;
  final ValueChanged<int>? onSelectMission;
  final VoidCallback? onBack;
  final VoidCallback? onHelpTap;

  const StandFlowHeader({
    super.key,
    required this.standName,
    required this.standNumber,
    required this.currentMissionNumber,
    required this.completedMissionNumbers,
    required this.unlockedMissionNumbers,
    this.totalMissions = 5,
    this.onSelectMission,
    this.onBack,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: StandFlowTokens.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.92),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 750;

          return Row(
            children: [
              // 1. Botão de Voltar à esquerda
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Voltar ao Mapa',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              if (!isCompact) ...[
                const SizedBox(width: 4),
                const EletroLabHeaderBrand(compact: true),
                const SizedBox(width: 12),
                // Badge do Estande
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042920),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: StandFlowTokens.primaryGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Estande ${standNumber.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: StandFlowTokens.accentGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // 2. Pílulas de Navegação das Missões
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalMissions, (index) {
                      final missionNumber = index + 1;
                      final isCurrent = currentMissionNumber == missionNumber;
                      final isCompleted = completedMissionNumbers.contains(missionNumber);
                      final isUnlocked = unlockedMissionNumbers.contains(missionNumber);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildMissionPill(
                          missionNumber: missionNumber,
                          isCurrent: isCurrent,
                          isCompleted: isCompleted,
                          isUnlocked: isUnlocked,
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // 3. Botão de Ajuda
              if (onHelpTap != null)
                IconButton(
                  icon: const Icon(Icons.help_outline_rounded, color: Colors.white70),
                  tooltip: 'Ajuda da Missão',
                  onPressed: onHelpTap,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMissionPill({
    required int missionNumber,
    required bool isCurrent,
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    Color bg;
    Color border;
    Color text;
    Widget? icon;

    if (isCurrent) {
      bg = StandFlowTokens.primaryGreen;
      border = StandFlowTokens.accentGreen;
      text = Colors.black;
    } else if (isCompleted) {
      bg = const Color(0xFF064E3B);
      border = StandFlowTokens.primaryGreen.withValues(alpha: 0.6);
      text = Colors.white;
      icon = const Icon(Icons.check_circle_rounded, color: StandFlowTokens.accentGreen, size: 14);
    } else if (isUnlocked) {
      bg = const Color(0xFF1E293B);
      border = const Color(0xFF334155);
      text = Colors.white70;
    } else {
      bg = const Color(0xFF0F172A);
      border = const Color(0xFF1E293B);
      text = const Color(0xFF475569);
      icon = const Icon(Icons.lock_rounded, color: Color(0xFF475569), size: 13);
    }

    return InkWell(
      onTap: isUnlocked ? () => onSelectMission?.call(missionNumber) : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: isCurrent ? 1.8 : 1.0),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: StandFlowTokens.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 4),
            ],
            Text(
              'Missão $missionNumber',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
