import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ui_scale.dart';
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
    final scale = context.uiScale;

    return Container(
      constraints: BoxConstraints(
        minHeight: scale.size(StandFlowTokens.headerHeight, min: 58, max: 96),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(16, min: 10, max: 28),
        vertical: scale.spacing(8, min: 4, max: 14),
      ),
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
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: scale.icon(22, min: 18, max: 32),
                ),
                tooltip: 'Voltar ao Mapa',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),

              if (!isCompact) ...[
                const SizedBox(width: 4),
                const EletroLabHeaderBrand(compact: true),
                SizedBox(width: scale.spacing(12, min: 8, max: 20)),
                // Badge do Estande
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: scale.spacing(10, min: 6, max: 16),
                    vertical: scale.spacing(4, min: 2, max: 8),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042920),
                    borderRadius: BorderRadius.circular(
                      scale.size(8, min: 6, max: 12),
                    ),
                    border: Border.all(
                      color: StandFlowTokens.primaryGreen.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Text(
                    'Estande ${standNumber.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontFamily: GoogleFonts.rajdhani().fontFamily,
                      fontSize: scale.font(13, min: 11, max: 18),
                      fontWeight: FontWeight.bold,
                      color: StandFlowTokens.accentGreen,
                    ),
                  ),
                ),
                SizedBox(width: scale.spacing(16, min: 10, max: 24)),
              ],

              // 2. Pílulas de Navegação das Missões
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalMissions, (index) {
                      final missionNumber = index + 1;
                      final isCurrent = currentMissionNumber == missionNumber;
                      final isCompleted = completedMissionNumbers.contains(
                        missionNumber,
                      );
                      final isUnlocked = unlockedMissionNumbers.contains(
                        missionNumber,
                      );

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: scale.spacing(4, min: 2, max: 8),
                        ),
                        child: _buildMissionPill(
                          context: context,
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
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white70,
                    size: scale.icon(22, min: 18, max: 32),
                  ),
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
    required BuildContext context,
    required int missionNumber,
    required bool isCurrent,
    required bool isCompleted,
    required bool isUnlocked,
  }) {
    final scale = context.uiScale;
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
      icon = Icon(
        Icons.check_circle_rounded,
        color: StandFlowTokens.accentGreen,
        size: scale.icon(14, min: 12, max: 20),
      );
    } else if (isUnlocked) {
      bg = const Color(0xFF1E293B);
      border = const Color(0xFF334155);
      text = Colors.white70;
    } else {
      bg = const Color(0xFF0F172A);
      border = const Color(0xFF1E293B);
      text = const Color(0xFF475569);
      icon = Icon(
        Icons.lock_rounded,
        color: const Color(0xFF475569),
        size: scale.icon(13, min: 11, max: 18),
      );
    }

    return InkWell(
      onTap: isUnlocked ? () => onSelectMission?.call(missionNumber) : null,
      borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(10, min: 7, max: 18),
          vertical: scale.spacing(6, min: 4, max: 12),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
          border: Border.all(color: border, width: isCurrent ? 1.8 : 1.0),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: StandFlowTokens.primaryGreen.withValues(alpha: 0.35),
                    blurRadius: scale.size(8, min: 5, max: 14),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              SizedBox(width: scale.spacing(4, min: 2, max: 8)),
            ],
            Text(
              'Missão $missionNumber',
              style: TextStyle(
                fontFamily: GoogleFonts.rajdhani().fontFamily,
                fontSize: scale.font(13, min: 11, max: 18),
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
