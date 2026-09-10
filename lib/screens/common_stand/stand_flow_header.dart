import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ui_scale.dart';
import '../../widgets/eletrolab_header_brand.dart';
import 'stand_flow_tokens.dart';

/// Cabeçalho padronizado e balanceado em 3 zonas (Identidade, Stepper Central e Progresso/Ações)
/// para os fluxos de missões nos estandes do EletroLab.
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
  final VoidCallback? onSettingsTap;

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
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.uiScale;

    return Container(
      constraints: BoxConstraints(
        minHeight: scale.size(StandFlowTokens.headerHeight, min: 58, max: 88),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scale.spacing(12, min: 8, max: 24),
        vertical: scale.spacing(6, min: 4, max: 12),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF0B1120),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: scale.size(10, min: 6, max: 18),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final showFullBrand = w >= 1180;
          final showStandName = w >= 1020 && standName.isNotEmpty;
          final isCompact = w < 840;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ===============================================================
              // 1. ZONA ESQUERDA — Identidade, Voltar & Contexto do Estande
              // ===============================================================
              _buildLeftIdentityZone(
                context,
                scale,
                showFullBrand: showFullBrand,
                showStandName: showStandName,
              ),

              SizedBox(width: scale.spacing(8, min: 4, max: 16)),

              // ===============================================================
              // 2. ZONA CENTRAL — Stepper / Linha do Tempo das Missões
              // ===============================================================
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(totalMissions, (index) {
                        final missionNumber = index + 1;
                        final isCurrent = currentMissionNumber == missionNumber;
                        final isCompleted = completedMissionNumbers.contains(missionNumber);
                        final isUnlocked = unlockedMissionNumbers.contains(missionNumber);
                        final isNextUnlocked = unlockedMissionNumbers.contains(missionNumber + 1);

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMissionPill(
                              context: context,
                              missionNumber: missionNumber,
                              isCurrent: isCurrent,
                              isCompleted: isCompleted,
                              isUnlocked: isUnlocked,
                            ),
                            // Trilha conectora entre as missões
                            if (missionNumber < totalMissions && !isCompact)
                              Container(
                                width: scale.spacing(8, min: 3, max: 14),
                                height: 2,
                                margin: EdgeInsets.symmetric(
                                  horizontal: scale.spacing(2, min: 1, max: 4),
                                ),
                                decoration: BoxDecoration(
                                  color: (isCompleted && isNextUnlocked)
                                      ? StandFlowTokens.primaryGreen.withValues(alpha: 0.6)
                                      : const Color(0xFF334155).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),

              SizedBox(width: scale.spacing(8, min: 4, max: 16)),

              // ===============================================================
              // 3. ZONA DIREITA — Progresso Global & Ações Úteis
              // ===============================================================
              _buildRightProgressAndActionsZone(context, scale, isCompact),
            ],
          );
        },
      ),
    );
  }

  /// Zona esquerda: Botão voltar, logo institucional e badge temático do estande
  Widget _buildLeftIdentityZone(
    BuildContext context,
    UiScale scale, {
    required bool showFullBrand,
    required bool showStandName,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão de Retorno estilizado
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(scale.size(10, min: 8, max: 16)),
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: Container(
              padding: EdgeInsets.all(scale.spacing(6, min: 4, max: 10)),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(scale.size(10, min: 8, max: 16)),
                border: Border.all(color: const Color(0xFF334155), width: 1.0),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: scale.icon(20, min: 16, max: 28),
              ),
            ),
          ),
        ),

        // Brand Compacto (sem o subtítulo longo para economizar espaço horizontal)
        if (showFullBrand) ...[
          SizedBox(width: scale.spacing(8, min: 4, max: 14)),
          const EletroLabHeaderBrand(compact: true, showSubtitle: false),
          SizedBox(width: scale.spacing(8, min: 4, max: 14)),
          Container(
            height: scale.size(20, min: 16, max: 28),
            width: 1.2,
            color: const Color(0xFF334155).withValues(alpha: 0.6),
          ),
        ],

        SizedBox(width: scale.spacing(8, min: 4, max: 14)),

        // Badge Inteligente do Estande (Número + Nome Temático)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: scale.spacing(9, min: 6, max: 14),
            vertical: scale.spacing(5, min: 3, max: 8),
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF042920),
                Color(0xFF064E3B),
              ],
            ),
            borderRadius: BorderRadius.circular(scale.size(10, min: 8, max: 16)),
            border: Border.all(
              color: StandFlowTokens.primaryGreen.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: StandFlowTokens.primaryGreen.withValues(alpha: 0.12),
                blurRadius: scale.size(6, min: 4, max: 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.developer_board_rounded,
                color: StandFlowTokens.accentGreen,
                size: scale.icon(15, min: 12, max: 20),
              ),
              SizedBox(width: scale.spacing(5, min: 3, max: 8)),
              Text(
                'Estande ${standNumber.toString().padLeft(2, '0')}',
                style: GoogleFonts.rajdhani(
                  fontSize: scale.font(13, min: 11.5, max: 18),
                  fontWeight: FontWeight.bold,
                  color: StandFlowTokens.accentGreen,
                  letterSpacing: 0.5,
                ),
              ),
              if (showStandName) ...[
                Text(
                  ' · ',
                  style: GoogleFonts.rajdhani(
                    fontSize: scale.font(13, min: 11, max: 18),
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: scale.size(130, min: 90, max: 200),
                  ),
                  child: Text(
                    standName.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                      fontSize: scale.font(12, min: 10.5, max: 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Pílula individual da missão com estados refinados
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
      icon = Icon(
        Icons.bolt_rounded,
        color: Colors.black,
        size: scale.icon(14, min: 12, max: 18),
      );
    } else if (isCompleted) {
      bg = const Color(0xFF064E3B);
      border = StandFlowTokens.primaryGreen.withValues(alpha: 0.6);
      text = Colors.white;
      icon = Icon(
        Icons.check_circle_rounded,
        color: StandFlowTokens.accentGreen,
        size: scale.icon(13, min: 11, max: 18),
      );
    } else if (isUnlocked) {
      bg = const Color(0xFF1E293B);
      border = const Color(0xFF475569);
      text = Colors.white;
      icon = Icon(
        Icons.play_circle_outline_rounded,
        color: Colors.white70,
        size: scale.icon(13, min: 11, max: 18),
      );
    } else {
      bg = const Color(0xFF1E293B).withValues(alpha: 0.45);
      border = const Color(0xFF334155).withValues(alpha: 0.5);
      text = const Color(0xFF94A3B8);
      icon = Icon(
        Icons.lock_outline_rounded,
        color: const Color(0xFF64748B),
        size: scale.icon(12, min: 10, max: 16),
      );
    }

    return InkWell(
      onTap: isUnlocked ? () => onSelectMission?.call(missionNumber) : null,
      borderRadius: BorderRadius.circular(scale.size(16, min: 12, max: 24)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: scale.spacing(9, min: 6, max: 16),
          vertical: scale.spacing(5, min: 4, max: 10),
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
              SizedBox(width: scale.spacing(4, min: 2, max: 6)),
            ],
            Text(
              'Missão $missionNumber',
              style: GoogleFonts.rajdhani(
                fontSize: scale.font(12.5, min: 11, max: 17),
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zona direita: Card de progresso global e botões de suporte
  Widget _buildRightProgressAndActionsZone(
    BuildContext context,
    UiScale scale,
    bool isCompact,
  ) {
    final completedCount = completedMissionNumbers.length;
    final progressFraction = totalMissions > 0 ? completedCount / totalMissions : 0.0;
    final isFullyCompleted = completedCount == totalMissions;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Card de Progresso da Jornada
        if (!isCompact) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: scale.spacing(8, min: 6, max: 14),
              vertical: scale.spacing(4, min: 3, max: 8),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(scale.size(10, min: 8, max: 14)),
              border: Border.all(
                color: isFullyCompleted
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF334155),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFullyCompleted
                      ? Icons.emoji_events_rounded
                      : Icons.military_tech_rounded,
                  color: isFullyCompleted
                      ? const Color(0xFFF59E0B)
                      : StandFlowTokens.accentGreen,
                  size: scale.icon(16, min: 13, max: 22),
                ),
                SizedBox(width: scale.spacing(5, min: 3, max: 8)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedCount/$totalMissions',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: scale.font(12, min: 10.5, max: 15),
                      ),
                    ),
                    SizedBox(height: scale.spacing(2, min: 1, max: 4)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        width: scale.size(44, min: 32, max: 64),
                        height: scale.size(3, min: 2.5, max: 5),
                        child: LinearProgressIndicator(
                          value: progressFraction,
                          backgroundColor: const Color(0xFF334155),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFullyCompleted
                                ? const Color(0xFFF59E0B)
                                : StandFlowTokens.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: scale.spacing(4, min: 2, max: 8)),
        ],

        // Botão de Ajuda
        if (onHelpTap != null)
          IconButton(
            icon: Icon(
              Icons.help_outline_rounded,
              color: Colors.white70,
              size: scale.icon(19, min: 15, max: 26),
            ),
            tooltip: 'Ajuda da Missão',
            onPressed: onHelpTap,
          ),

        // Botão de Configurações
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: Colors.white60,
            size: scale.icon(18, min: 14, max: 24),
          ),
          tooltip: 'Configurações',
          onPressed: onSettingsTap ?? () => Navigator.of(context).pushNamed('/settings'),
        ),
      ],
    );
  }
}
